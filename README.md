# appnovasi_kit

Flutter boilerplate framework untuk mempercepat pembuatan app Play Store.
Integrasi **config-only**: tambahkan dependency, isi satu `AppConfig`, aplikasi langsung siap setengah jalan.

- Package publik: `appnovasi_kit`
- Contoh integrasi lengkap: folder [`example/`](example/)

## Fitur

- Tema Material 3: mode **light/dark/system**, **8 warna tema** universal, **ukuran font**
  (small/default/large), dan **jenis font** — semuanya bisa diganti user dari Settings.
- Font **Poppins** bundled; seed color, font, dan daftar pilihannya bisa dioverride lewat `AppConfig`.
- Multi-bahasa (i18n) EN/ID, locale dapat dipilih user.
- Storage lokal **Hive** (satu-satunya storage).
- **Onboarding** config-only (tampil sekali, tersimpan otomatis).
- **Bottom navigation** otomatis via go_router `StatefulShellRoute.indexedStack`.
- **Permission** (`permission_handler`) dibungkus `PermissionService`.
- **AboutScreen** & **SettingsScreen** siap pakai.
- AdMob (banner, interstitial, app open) & in-app purchase.
- Widget siap pakai: `ShareButton`, `ShareIconButton`, `RateButton`, `RateIconButton`,
  `AdBanner`, `AppTitle`, `AppVersionText`.
- Service via Provider: `StorageService`, `ThemeController`, `LocaleController`,
  `PermissionService`, `LinkService` (url_launcher), `AppInfoService` (package_info_plus),
  `AdService`, `PurchaseService`, `ShareService`, `RateService`.

## Instalasi

```yaml
dependencies:
  appnovasi_kit: ^0.2.0
```

Saat pengembangan (lokal):

```yaml
dependencies:
  appnovasi_kit:
    path: ../boilerplate_flutter
```

## Mulai cepat

1. Isi konfigurasi di satu file:

   ```dart
   import 'package:appnovasi_kit/appnovasi_kit.dart';
   import 'package:flutter/material.dart';

   const appConfig = AppConfig(
     appName: 'Project Baru',
     packageId: 'com.appnovasi.project_baru',
     description: 'Deskripsi singkat aplikasi.',
     logoAsset: 'assets/logo.png', // opsional
     supportedLocales: [Locale('en'), Locale('id')],
     defaultLocale: Locale('en'),
     // AdMob
     bannerUnitId: 'ca-app-pub-xxx/yyy',
     interstitialUnitId: 'ca-app-pub-xxx/zzz',
     // IAP
     productIds: ['remove_ads'],
     // Store & tautan
     playStoreUrl: 'https://play.google.com/store/apps/details?id=...',
     appStoreUrl: 'https://apps.apple.com/app/id...',
     moreAppsUrl: 'https://play.google.com/store/apps/developer?id=...',
     websiteUrl: 'https://example.com',
     privacyPolicyUrl: 'https://example.com/privacy',
     termsUrl: 'https://example.com/terms',
     // Onboarding (opsional)
     onboarding: OnboardingConfig(
       pages: [
         OnboardingPage(
           title: 'Selamat datang',
           description: 'Jelajahi fitur utama aplikasi.',
           icon: Icons.waving_hand,
         ),
       ],
     ),
     // Bottom navigation (opsional)
     navigation: BottomNavConfig(
       tabs: [
         NavTab(
           label: 'Home',
           icon: Icons.home_outlined,
           selectedIcon: Icons.home,
           path: '/home',
         ),
         NavTab(label: 'About', icon: Icons.info_outline, path: '/about'),
         NavTab(
           label: 'Settings',
           icon: Icons.settings_outlined,
           path: '/settings',
         ),
       ],
     ),
   );
   ```

2. `main.dart` tipis:

   ```dart
   Future<void> main() async {
     await AppKit.initialize(appConfig);
     runApp(
       AppKitApp(
         config: appConfig,
         routes: {
           '/home': (context) => const HomePage(),
           '/about': (context) => const AboutScreen(),
           '/settings': (context) => const SettingsScreen(),
         },
       ),
     );
   }
   ```

   Tanpa `navigation`, cukup:
   `AppKitApp(config: appConfig, home: HomePage())`.

## Navigasi (bottom nav)

Jika `AppConfig.navigation` diisi, `AppKitApp` otomatis membangun
`StatefulShellRoute.indexedStack` dari daftar `NavTab` + `routes`:

- tiap `NavTab.path` menjadi satu branch (state tiap tab terjaga);
- route lain yang ber-prefix path tab otomatis menjadi child di branch tersebut
  (nested navigator);
- route di luar tab menjadi top-level (tampil di atas shell).

Ingin mengatur router sendiri? Gunakan `AppRouter.createShell(...)`:

```dart
final router = AppRouter.createShell(
  navigation: appConfig.navigation!,
  routes: {
    '/home': (context) => const HomePage(),
    '/settings': (context) => const SettingsScreen(),
  },
);
AppKitApp(config: appConfig, routerConfig: router);
```

Helper `AppRouter.create(...)` juga tersedia untuk routing biasa (tanpa shell).

## Onboarding

Onboarding tampil **sekali** di awal, lalu lanjut ke halaman utama. Status disimpan di Hive
lewat `OnboardingController`. Otomatis aktif saat `AppKitApp(home: ...)` atau saat shell
bottom nav dipakai. Bisa juga dipasang manual:

```dart
OnboardingGate(child: HomePage())

// reset agar tampil lagi:
context.read<OnboardingController>().reset();
```

## Permission

```dart
final permission = context.read<PermissionService>();
if (await permission.ensure(Permission.camera)) {
  // izin diberikan
}
```

`Permission`, `PermissionStatus`, dan `PermissionWithService` di-re-export dari package.

## Halaman siap pakai

- `AboutScreen`: logo, versi (dari `package_info_plus`), deskripsi, share, rate, more apps,
  website, privacy policy, dan terms. Bisa ditambah item dengan `AboutScreen(extra: [...])`.
- `SettingsScreen`: pilih mode tema (system/light/dark), warna tema, ukuran font, jenis font,
  dan bahasa. Bisa ditambah item dengan `SettingsScreen(extra: [...])`.
- `AppTitle` & `AppVersionText`: judul AppBar "NamaApp versi" dan label versi.

## Kustomisasi tampilan

```dart
const appConfig = AppConfig(
  appName: 'App',
  packageId: 'com.app',
  seedColor: Color(0xFF0EA5E9), // warna default
  colorThemes: [ // pilihan warna yang tampil di Settings
    AppColorTheme(name: 'Brand', seedColor: Color(0xFF0EA5E9)),
    AppColorTheme(name: 'Emerald', seedColor: Color(0xFF10B981)),
  ],
  fonts: [ // pilihan jenis font
    AppFont(name: 'Default'), // mengikuti fontFamily
    AppFont(name: 'Serif', fontFamily: 'serif'),
  ],
  defaultFontSize: AppFontSize.normal,
  fontFamily: 'Poppins', // font default package
);
```

## Setup native (per project)

Beberapa hal tidak bisa dari package dan tetap diatur di app konsumen:

- AdMob **App ID** di `AndroidManifest.xml` (`com.google.android.gms.ads.APPLICATION_ID`) dan
  `Info.plist` (`GADApplicationIdentifier`).
- `permission_handler`: deklarasikan `<uses-permission>` di `AndroidManifest.xml` dan usage
  description (mis. `NSCameraUsageDescription`) di `Info.plist`. Set `compileSdk` Android
  minimal 37 (`compileSdk = maxOf(flutter.compileSdkVersion, 37)`).
- Android `minSdk` minimal 23.
- Product ID IAP & signing dikonfigurasi di Play Console.

## Development

```bash
flutter pub get
flutter analyze
flutter test
dart format .
flutter gen-l10n

cd example && flutter run -d <device>   # jalankan example app
```

## Versi & rilis

- Mengikuti **Semantic Versioning**. Perubahan breaking menaikkan MAJOR dan dicatat di
  [`CHANGELOG.md`](CHANGELOG.md).
- Rilis ke pub.dev:

  ```bash
  flutter pub publish --dry-run   # validasi
  flutter pub publish
  ```
