/**
 * API-Football proxy.
 *
 * Tətbiq API-Football-a birbaşa yox, bu funksiyaya müraciət edir:
 *   https://europe-west1-footballapp-7a3f7.cloudfunctions.net/api/fixtures?date=...
 *
 * - API açarı tətbiqdə yoxdur, Secret Manager-də saxlanılır (API_FOOTBALL_KEY).
 * - Yalnız login olmuş istifadəçilər (Firebase ID token) sorğu göndərə bilər.
 * - Yalnız tətbiqin işlətdiyi endpoint-lər açıqdır.
 * - Cavablar yaddaşda keşlənir ki, gündəlik API limiti tez bitməsin.
 */

import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

initializeApp();

const apiFootballKey = defineSecret("API_FOOTBALL_KEY");
const UPSTREAM = "https://v3.football.api-sports.io";

/** İcazə verilən endpoint-lər və keş müddəti (saniyə). */
export const ROUTES: Readonly<Record<string, number>> = {
  "/fixtures": 60, // canlı hesablar tez dəyişir
  "/fixtures/headtohead": 24 * 60 * 60,
  "/standings": 60 * 60,
  "/teams": 7 * 24 * 60 * 60,
  "/players/squads": 24 * 60 * 60,
};

// MARK: - Keş

interface CacheEntry {
  body: string;
  expiresAt: number;
}

const MAX_CACHE_ENTRIES = 500;
const cache = new Map<string, CacheEntry>();

function cached(key: string, now: number): string | undefined {
  const entry = cache.get(key);
  if (!entry) return undefined;
  if (entry.expiresAt <= now) {
    cache.delete(key);
    return undefined;
  }
  return entry.body;
}

function store(key: string, body: string, ttlSeconds: number, now: number): void {
  if (cache.size >= MAX_CACHE_ENTRIES) {
    // Ən köhnə qeydi sil (Map əlavə olunma sırasını saxlayır).
    const oldest = cache.keys().next().value;
    if (oldest !== undefined) cache.delete(oldest);
  }
  cache.set(key, { body, expiresAt: now + ttlSeconds * 1000 });
}

// MARK: - Köməkçilər

/** API-Football xəta olanda da 200 qaytarır; xəta `errors` sahəsindədir. Belə cavab keşlənmir. */
export function hasApiErrors(body: string): boolean {
  try {
    const errors = (JSON.parse(body) as { errors?: unknown }).errors;
    if (Array.isArray(errors)) return errors.length > 0;
    if (errors && typeof errors === "object") return Object.keys(errors).length > 0;
    return false;
  } catch {
    return true;
  }
}

/** "/fixtures?date=2024-10-19" → path və query hissəsi. */
export function splitUrl(url: string): { path: string; query: string } {
  const index = url.indexOf("?");
  const rawPath = index === -1 ? url : url.slice(0, index);
  const path = rawPath.length > 1 ? rawPath.replace(/\/+$/, "") : rawPath;
  return { path, query: index === -1 ? "" : url.slice(index) };
}

/** Tətbiqin `ErrorModel`-i bu formanı oxuyur: { statusmessage, status_code }. */
function errorBody(status: number, message: string) {
  return { statusmessage: message, status_code: status, success: false };
}

// MARK: - Funksiya

export const api = onRequest(
  {
    region: "europe-west1", // Bakıya ən yaxın region
    secrets: [apiFootballKey],
    invoker: "public", // giriş yoxlamasını özümüz edirik (ID token)
    maxInstances: 3, // gözlənilməz xərcə qarşı
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).json(errorBody(405, "Method not allowed"));
      return;
    }

    const { path, query } = splitUrl(req.url);
    const ttl = ROUTES[path];
    if (ttl === undefined) {
      res.status(404).json(errorBody(404, "Unknown endpoint"));
      return;
    }

    // 1. İstifadəçi login olubmu?
    const token = /^Bearer (.+)$/.exec(req.get("Authorization") ?? "")?.[1];
    if (!token) {
      res.status(401).json(errorBody(401, "Please sign in to continue."));
      return;
    }
    try {
      await getAuth().verifyIdToken(token);
    } catch {
      res.status(401).json(errorBody(401, "Your session has expired. Please sign in again."));
      return;
    }

    // 2. Keşdə varsa API-yə getmə.
    const key = path + query;
    const now = Date.now();
    const hit = cached(key, now);
    if (hit !== undefined) {
      res.set("X-Cache", "HIT").type("application/json").send(hit);
      return;
    }

    // 3. API-Football-a açarla sorğu.
    try {
      const upstream = await fetch(UPSTREAM + key, {
        headers: { "x-apisports-key": apiFootballKey.value() },
        signal: AbortSignal.timeout(20_000),
      });
      const body = await upstream.text();

      if (upstream.ok && !hasApiErrors(body)) {
        store(key, body, ttl, now);
      } else {
        logger.warn("Upstream returned an error", { path, status: upstream.status });
      }
      res.status(upstream.status).set("X-Cache", "MISS").type("application/json").send(body);
    } catch (error) {
      logger.error("Upstream request failed", { path, error: String(error) });
      res.status(502).json(errorBody(502, "Football data is temporarily unavailable."));
    }
  },
);
