## 0.2.0

* `PermissionService` (berbasis `permission_handler`) + re-export `Permission`,
  `PermissionStatus`, `PermissionWithService` dari barrel.
* Feature onboarding config-only: `OnboardingConfig`, `OnboardingPage`,
  `OnboardingScreen`, `OnboardingGate`, `OnboardingController`.
* `AppConfig.onboarding` — onboarding otomatis tampil sekali lewat `OnboardingGate`
  saat `AppKitApp(home: ...)` dipakai.
* Bottom navigation config-only: `BottomNavConfig`, `NavTab`, `AppShell`, dan
  `AppRouter.createShell` (`StatefulShellRoute.indexedStack`).
* `AppConfig.navigation` — `AppKitApp` menyusun shell + bottom nav otomatis dari
  daftar `NavTab` dan `routes` (nested navigator per tab).
* `AppColorTheme` + `defaultColorThemes` (8 warna universal) & `AppConfig.colorThemes`;
  `ThemeController` menyimpan pilihan warna tema (`setColorTheme`).
* `AppFontSize` (small/normal/large) + `AppFont`/`defaultFonts`; `AppConfig.defaultFontSize`
  & `AppConfig.fonts`; `ThemeController` menyimpan pilihan ukuran & jenis font, dan
  `AppKitApp` menerapkannya global (textScaler + fontFamily).
* `AboutScreen` (logo, versi, deskripsi, share, rate, more apps, website,
  privacy, terms) & `SettingsScreen` (pilih tema System/Light/Dark + warna tema
  + bahasa, extensible via `extra`).
* `AppTitle` (AppBar "NamaApp versi") & `AppVersionText` berbasis `AppInfoService`.
* `RateIconButton` (melengkapi `ShareIconButton`) untuk dipakai di `AppBar.actions`.
* `LinkService` (url_launcher) + `AppConfig.description/logoAsset/moreAppsUrl/websiteUrl`.
* i18n EN/ID untuk label onboarding, about, dan settings.

## 0.1.0

* Rilis awal `appnovasi_kit`.
* `AppConfig` (appName, packageId, theme, font, locale, AdMob, IAP, store URL).
* `AppKit.initialize` + `AppKitApp`.
* Services: `StorageService` (Hive), `ThemeController`, `LocaleController`,
  `AdService`, `PurchaseService`, `ShareService`, `RateService`.
* Widgets: `ShareButton`, `ShareIconButton`, `RateButton`, `AdBanner`.
* i18n EN/ID, font Poppins bundled, routing helper go_router.
* Example app config-only.
