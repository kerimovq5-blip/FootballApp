# FootballApp

Canlı oyunlar, liqa cədvəlləri, klub və oyunçu məlumatları göstərən iOS tətbiqi.
Data [API-Football](https://www.api-football.com) (api-sports.io) xidmətindən gəlir.

## Tələblər

| | Versiya |
|---|---|
| Xcode | 26+ |
| iOS (minimum) | 18.6 |
| Swift | 5 (Default Actor Isolation: `MainActor`) |
| Paketlər (SPM) | Firebase Auth, RxSwift / RxCocoa / RxRelay |

## Layihəni ilk dəfə qurmaq

1. Repo-nu klonla:
   ```bash
   git clone https://github.com/kerimovq5-blip/FootballApp.git
   cd FootballApp
   ```
2. **API açarını əlavə et.** `FootballApp/Core/Secrets.swift` faylı git-də yoxdur
   (`.gitignore`-dadır). Açarı komanda yoldaşından al və faylı belə yarat:
   ```swift
   enum Secrets {
       static let apiKey = "SƏNİN_API_AÇARIN"
   }
   ```
   Açar olmadan da tətbiq açılır, amma real data əvəzinə xəta göstərilir
   (aşağıdakı **Mock rejimi**-ndən istifadə et).
3. `FootballApp.xcodeproj`-u aç. Xcode paketləri özü yükləyəcək
   (ilk dəfə bir neçə dəqiqə çəkə bilər).
4. Simulator seç və **Cmd + R**.

> ⚠️ `Secrets.swift`, token, sertifikat və ya başqa gizli faylları heç vaxt
> commit etmə və zip ilə paylaşma.

## Mock rejimi

API açarı olmadan və ya limit xərcləmədən işləmək üçün:

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

Cavablar yaddaşda və diskdə keşlənir (`APIFootballClient`), ona görə eyni ekranı
təkrar açmaq yeni sorğu göndərmir. Keşi silmək üçün tətbiqi silib yenidən qur.

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
