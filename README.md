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
   Açar olmadan da tətbiq açılır, amma data əvəzinə xəta göstərilir.
3. `FootballApp.xcodeproj`-u aç. Xcode paketləri özü yükləyəcək
   (ilk dəfə bir neçə dəqiqə çəkə bilər).
4. Simulator seç və **Cmd + R**.

> ⚠️ `Secrets.swift`, token, sertifikat və ya başqa gizli faylları heç vaxt
> commit etmə və zip ilə paylaşma.

## API limitləri

Pulsuz plan gündə **100 sorğu** verir və yalnız köhnə mövsümləri açır.
Bu səbəbdən [`Core/Config/APIConfig.swift`](FootballApp/Core/Config/APIConfig.swift)-də:

- `season = 2024`
- `demoDate = "2024-10-19"` (Home bu tarixin oyunlarını göstərir)

Ödənişli plana keçəndə `season`-u cari mövsümə dəyiş və `demoDate`-i `nil` et.

Cavablar yaddaşda və diskdə keşlənir (`APIFootballClient`), ona görə eyni ekranı
təkrar açmaq yeni sorğu göndərmir. Keşi silmək üçün tətbiqi silib yenidən qur.

## Bildirişlər (oyun xatırlatmaları)

Oyunun yanındakı zəngə basanda oyun izlənir və başlamazdan **15 dəqiqə əvvəl** telefonda
bildiriş görünür (local notification, server lazım deyil). İcazə ilk dəfə zəngə basanda
soruşulur. Bildirişə toxunanda oyunun səhifəsi açılır. Profil → Settings → *Match reminders*
hamısını söndürür/açır.

Pulsuz API köhnə mövsümü göstərdiyi üçün bütün oyunlar bitmiş olur. Yoxlamaq üçün
scheme-ə `-testReminders` əlavə et (yalnız Debug): istənilən oyunu izləyəndə 5 saniyə
sonra bildiriş gəlir. Tətbiqi arxa plana göndər (Cmd+Shift+H) ki, banner görünsün.

Qol bildirişləri üçün server tərəfdən push (APNs) lazımdır, hələ yoxdur.

## Layihənin quruluşu (Clean Architecture)

Kod feature-lara bölünüb, hər feature-un içində isə üç qat var:

```
FootballApp/
├── App/                    Tətbiqin yığıldığı yer
│   ├── AppDelegate, SceneDelegate
│   ├── AppEnvironment      Hansı protokola hansı implementasiyanın verildiyi (DI)
│   └── Navigation/         Coordinator-lar (ekranlar arası keçid)
├── Core/                   Feature-dan asılı olmayan ortaq hissələr
│   ├── Config/             APIConfig (mövsüm, tarix), AppConfig
│   ├── Secrets.swift       API açarı (yalnız səndə, git-də yox)
│   ├── Network/            NetworkManager, EndPoint, ImageLoader
│   ├── UI/                 Ortaq komponentlər (StateView, PillTabBar, AppIcon…), extension-lar
│   ├── Errors/             UserFacingError
│   ├── Diagnostics/        Crashlytics
│   └── Utils/              CountryFlag
├── Domain/                 Bir neçə feature-un işlətdiyi modellər: Match, League, Standing,
│                           ClubReference, PlayerReference
├── Data/APIFootball/       API client, endpoint-lər, DTO-lar, ortaq mapper hissəsi
└── Features/
    ├── Home/  Explore/  Standing/  MatchDetail/  Club/  Player/  Search/
    ├── Notifications/  Profile/  Auth/
    └── <Feature>/
        ├── Domain/         Feature-un modelləri + servis protokolu (`HomeProviding` və s.)
        ├── Data/           Protokolun API implementasiyası (`APIHomeService`)
        │                   və həmin feature-un DTO → model mapping-i (`APIFootballMapper+Home`)
        └── Presentation/   ViewController, ViewModel, view-lar, cell-lər
```

### Asılılıq qaydası

```
Presentation  →  Domain  ←  Data
```

- **Domain** heç nəyə bağlı deyil: `UIKit` import etmir, DTO-nu tanımır. Rəng kimi ekran
  detalları Presentation-da extension kimi verilir (`StandingZone+Color`, `ClubResult+Color`).
- **Presentation** MVVM + Coordinator-dır: ViewController ekranı çəkir, ViewModel datanı hazırlayır,
  keçidləri Coordinator edir. Yalnız Domain protokolunu tanıyır (`HomeProviding`), API-ni yox.
  ViewModel servisi init-də alır, ona görə testdə saxta servis ötürmək olur.
- **Data** Domain protokolunu implementasiya edir, DTO-ları Domain modelinə çevirir.
- Hamısını bir-birinə **App/AppEnvironment** bağlayır.

### Yeni feature əlavə edəndə

1. `Features/<Ad>/Domain/` — model və `<Ad>Providing` protokolu.
2. `Features/<Ad>/Data/` — `API<Ad>Service` və lazım olsa `APIFootballMapper+<Ad>`.
3. `Features/<Ad>/Presentation/` — ViewModel (protokolu init-də alır) və ViewController.
4. `AppEnvironment.live`-a servisi əlavə et, coordinator-da ekranı aç.
5. `FootballAppTests/`-ə ViewModel və mapping testi yaz.

Xcode "synchronized folders" işlədir: qovluğa fayl əlavə etmək və ya köçürmək
`project.pbxproj`-u dəyişmir.

## İş qaydası

- `main`-ə birbaşa push etmə. Hər iş üçün ayrıca branch aç:
  `feature/axtaris-debounce`, `fix/standing-scroll` və s.
- İş bitəndə **Pull Request** aç, komanda yoldaşın baxsın, sonra birləşdir.
- Commit mesajı qısa və nə etdiyini desin: `Fix league tab bar scrolling past last tab`.
- Build zamanı SwiftLint xəbərdarlıqlarına bax, yenilərini əlavə etmə.

## Komanda

- Kerimov Qehreman
- Servan
