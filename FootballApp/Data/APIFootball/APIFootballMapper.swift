//
//  APIFootballMapper.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//
//  DTO → domain modeli. Bu faylda bir neçə feature-un ortaq istifadə etdiyi hissələr var
//  (oyun statusu, tarix formatları, bayraq). Feature-a aid mapping həmin feature-un
//  Data qovluğundadır: `APIFootballMapper+Home`, `+MatchDetail`, `+Standing`, `+Club`, `+Players`.
//

import Foundation

enum APIFootballMapper {

    // MARK: - Oyun (bir neçə feature işlədir)

    static func mapMatch(_ dto: FixtureDTO) -> Match {
        Match(id: dto.fixture.id,
              home: dto.teams.home.name,
              away: dto.teams.away.name,
              homeScore: dto.goals.home,
              awayScore: dto.goals.away,
              status: mapStatus(dto))
    }

    static func mapStatus(_ dto: FixtureDTO) -> MatchStatus {
        let status = dto.fixture.status
        switch status.short ?? "" {
        case "FT", "AET", "PEN", "AWD", "WO":
            return .finished
        case "1H", "2H", "ET", "LIVE":
            return .live(minute: minuteText(elapsed: status.elapsed, extra: status.extra))
        case "HT":
            return .live(minute: "HT")
        case "BT":
            return .live(minute: "BT")
        case "P":
            return .live(minute: "PEN")
        case "PST", "CANC", "ABD", "SUSP", "INT":
            return .scheduled(kickoff: status.short ?? "")
        default:
            return .scheduled(kickoff: kickoffText(dto.fixture.date))
        }
    }

    static func mapPosition(_ position: String?) -> PlayerPosition {
        switch (position ?? "").lowercased() {
        case "goalkeeper": return .goalkeeper
        case "defender": return .defender
        case "midfielder": return .midfielder
        default: return .forward
        }
    }

    static let shortDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func shortDayText(_ iso: String) -> String {
        isoParser.date(from: iso).map { shortDayFormatter.string(from: $0) } ?? ""
    }
    // MARK: - Köməkçilər

    static func minuteText(elapsed: Int?, extra: Int?) -> String {
        guard let elapsed else { return "LIVE" }
        if let extra, extra > 0 { return "\(elapsed)+\(extra)'" }
        return "\(elapsed)'"
    }

    static let isoParser: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func kickoffText(_ iso: String) -> String {
        isoParser.date(from: iso).map { timeFormatter.string(from: $0) } ?? "--:--"
    }

    static func dayText(_ iso: String) -> String {
        isoParser.date(from: iso).map { dayFormatter.string(from: $0) } ?? ""
    }

    static func flag(for league: FixtureDTO.LeagueInfo) -> String {
        flagEmoji(fromURL: league.flag)
    }

    /// Bayraq şəklindən ("…/flags/gb-eng.svg") ölkə kodunu götürüb emoji bayraq düzəldir.
    static func flagEmoji(fromURL url: String?) -> String {
        if let url,
           let file = url.split(separator: "/").last,
           let code = file.split(separator: ".").first?.split(separator: "-").first,
           let emoji = emoji(forCountryCode: String(code)) {
            return emoji
        }
        return "🌍"
    }

    static func emoji(forCountryCode code: String) -> String? {
        let upper = code.uppercased()
        guard upper.count == 2 else { return nil }
        var result = ""
        for scalar in upper.unicodeScalars {
            guard let flagScalar = UnicodeScalar(127397 + scalar.value) else { return nil }
            result.unicodeScalars.append(flagScalar)
        }
        return result
    }
}
