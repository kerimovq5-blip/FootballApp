# FootballApp

Canlı oyunlar, liqa cədvəlləri, klub və oyunçu məlumatları göstərən iOS tətbiqi.
Data [API-Football](https://www.api-football.com) (api-sports.io) xidmətindən gəlir.
Tətbiq API-yə birbaşa yox, Firebase Cloud Functions-dakı proxy vasitəsilə müraciət edir
(bax: [Backend](#backend-firebase-cloud-functions)).

## Tələblər

| | Versiya |
|---|---|
| Xcode | 26+ |
| iOS (minimum) | 16.0 |
| Swift | 5 (Default Actor Isolation: `MainActor`) |
| Paketlər (SPM) | Firebase Auth, RxSwift / RxCocoa / RxRelay |

## Layihəni ilk dəfə qurmaq

1. Repo-nu klonla:
   ```bash
   git clone https://github.com/kerimovq5-blip/FootballApp.git
   cd FootballApp
   ```
2. API açarı lazım **deyil**: o, serverdə saxlanılır. Real datanı görmək üçün
   tətbiqdə hesab yaradıb daxil olmaq kifayətdir.
3. `FootballApp.xcodeproj`-u aç. Xcode paketləri özü yükləyəcək
   (ilk dəfə bir neçə dəqiqə çəkə bilər).
4. Simulator seç və **Cmd + R**.

> ⚠️ API açarı, token, sertifikat və ya başqa gizli məlumatları heç vaxt
> commit etmə və zip ilə paylaşma. Köhnə `FootballApp/Core/Secrets.swift` faylın
> qalıbsa, onu sil: artıq istifadə olunmur.

## Mock rejimi

İnternetsiz, login olmadan və ya API limitini xərcləmədən işləmək üçün:

**Product → Scheme → Edit Scheme… → Run → Arguments → Arguments Passed On Launch**
bölməsinə `-useMockData` əlavə et.

Servislərin hansının mock, hansının real olduğu
[`Core/AppEnvironment.swift`](FootballApp/Core/AppEnvironment.swift)-də seçilir.

## API limitləri

Pulsuz plan gündə **100 sorğu** verir və yalnız köhnə mövsümləri açır.
Bu səbəbdən [`Core/APIConfig.swift`](FootballApp/Core/APIConfig.swift)-də:

- `season = 2024`
- `demoDate = "2024-10-19"` (Home bu tarixin oyunlarını göstərir)

Ödənişli plana keçəndə `season`-u cari mövsümə dəyiş və `demoDate`-i `nil` et.

Cavablar iki yerdə keşlənir, ona görə eyni ekranı təkrar açmaq API limitini xərcləmir:
- **tətbiqdə** (`APIFootballClient`, yaddaş + disk): keşi silmək üçün tətbiqi silib yenidən qur;
- **proxy-də** (`functions/src/index.ts`, `ROUTES`): bütün istifadəçilər üçün ortaq.

## Backend (Firebase Cloud Functions)

```
iOS tətbiq ──(Firebase ID token)──▶ Cloud Function `api` ──(API açarı)──▶ API-Football
```

- Kod: [`functions/src/index.ts`](functions/src/index.ts)
- URL: `https://europe-west1-footballapp-7a3f7.cloudfunctions.net/api` (`APIConfig.baseURL`)
- API açarı Google Secret Manager-də `API_FOOTBALL_KEY` adı ilə saxlanılır.
- Yalnız login olmuş istifadəçilər və yalnız tətbiqin işlətdiyi endpoint-lər
  (`/fixtures`, `/fixtures/headtohead`, `/standings`, `/teams`, `/players/squads`) qəbul olunur.

### İlk quraşdırma (bir dəfə)

Cloud Functions üçün Firebase layihəsi **Blaze** planında olmalıdır
(Firebase Console → ⚙️ → Usage and billing). Pulsuz limit bu tətbiq üçün kifayətdir,
amma kart bağlamaq tələb olunur. **Budget alert** qurmağı unutma.

```bash
npm install -g firebase-tools
firebase login
firebase functions:secrets:set API_FOOTBALL_KEY   # açarı soruşacaq
```

### Deploy

```bash
cd functions
npm ci
npm run deploy
```

Log-lar: `npm run logs` və ya Firebase Console → Functions → Logs.


## Layihənin quruluşu

```
FootballApp/
├── Core/
│   ├── Navigation/       Coordinator-lar (bütün ekran keçidləri buradadır)
│   ├── Utils/            Extension-lar və təkrar istifadə olunan view-lar
│   ├── Validator/        Form yoxlamaları
│   ├── APIConfig.swift   Mövsüm, tarix, liqa siyahısı
│   └── AppEnvironment    Servislərin seçildiyi yeganə yer (mock / live)
├── Networking/           NetworkManager, API client, DTO-lar, mapper
├── AuthModule/           Firebase Auth
├── StartModule, SignInModule, SignUpModule
├── HomeModule/           Home, Explore, Standing, Profile
├── MatchDetailModule/
├── ClubModule/
├── PlayerModule/
├── SearchModule/
└── NotificationsModule/
```

### Arxitektura qısaca

- **MVVM + Coordinator.** ViewController ekranı çəkir, ViewModel datanı hazırlayır,
  Coordinator ekranlar arası keçidi idarə edir. ViewController başqa ekranı özü açmır.
- **Servislər protokol arxasındadır** (`HomeProviding`, `ClubProviding` və s.).
  Hər birinin `Mock…` və `API…` versiyası var, `AppEnvironment` hansının işlədiləcəyini seçir.
- **Şəbəkə:** `NetworkManager` (async/await) → `APIFootballClient` (keş + endpoint-lər)
  → `APIFootballMapper` (DTO → ekran modeli).

## İş qaydası

- `main`-ə birbaşa push etmə. Hər iş üçün ayrıca branch aç:
  `feature/axtaris-debounce`, `fix/standing-scroll` və s.
- İş bitəndə **Pull Request** aç, komanda yoldaşın baxsın, sonra birləşdir.
- Commit mesajı qısa və nə etdiyini desin: `Fix league tab bar scrolling past last tab`.
- Build zamanı SwiftLint xəbərdarlıqlarına bax, yenilərini əlavə etmə.

## Komanda

- Kerimov Qehreman
- Servan
