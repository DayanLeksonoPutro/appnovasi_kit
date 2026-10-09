# appnovasi_kit

Flutter boilerplate framework untuk mempercepat pembuatan app Play Store.
Integrasi **config-only**: tambahkan dependency, isi satu `AppConfig`, aplikasi langsung siap setengah jalan.

- Package publik: `appnovasi_kit`
- Contoh integrasi lengkap: folder [`project/example/`](project/example/)

## Fitur

- Brand layer configurable via `BrandConfig` untuk nama app, slogan, logo, URL legal, dan kontak support.
- Theme layer configurable via `ThemeConfig` untuk warna primer, background, sistem light/dark,
  ukuran font, radius, serta preset font yang bisa dipilih user dari `SettingsScreen`.
- Content layer configurable via `ContentConfig` untuk copy seperti welcome text, hero text,
  deskripsi app, dan legal text dengan dukungan multi-bahasa.
- Font preset bundled: `Default`, `Inter`, `Poppins`, `Manrope`, `Lexend`, `Serif`, `Monospace`.
- Multi-bahasa (i18n) via `supportedLocales` + `defaultLocale`, dengan content yang bisa dipilih per locale.
- Storage lokal **Hive** (satu-satunya storage).
- **Onboarding** config-only (tampil sekali, tersimpan otomatis).
- **Bottom navigation** otomatis via go_router `StatefulShellRoute.indexedStack`.
- **Permission** (`permission_handler`) dibungkus `PermissionService`.
- **AboutScreen** & **SettingsScreen** siap pakai.
- In-app purchase (`in_app_purchase`).
- Widget siap pakai: `ShareButton`, `ShareIconButton`, `RateButton`, `RateIconButton`,
  `AppTitle`, `AppVersionText`.
- Service via Provider: `StorageService`, `ThemeController`, `LocaleController`,
  `PermissionService`, `LinkService` (url_launcher), `AppInfoService` (package_info_plus),
  `PurchaseService`, `ShareService`, `RateService`.

## Instalasi

```yaml
dependencies:
  appnovasi_kit: ^0.3.0
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

   final appConfig = AppConfig(
     brand: BrandConfig(
       appName: 'Project Baru',
       packageId: 'com.appnovasi.project_baru',
       description: 'Deskripsi singkat aplikasi.',
       logoAsset: 'assets/logo.png',
       slogan: 'Kelola semuanya dengan mudah',
       supportEmail: 'hello@projectbaru.app',
       websiteUrl: 'https://example.com',
       privacyPolicyUrl: 'https://example.com/privacy',
       termsUrl: 'https://example.com/terms',
     ),
     theme: ThemeConfig(
       accentColor: const Color(0xFF4F46E5),
       defaultThemeMode: ThemeMode.system,
       defaultFontSize: AppFontSize.normal,
       fontFamily: 'Poppins',
     ),
     content: ContentConfig(
       welcomeTitle: const LocalizedText({
         'en': 'Welcome',
         'id': 'Selamat datang',
       }),
       heroTitle: const LocalizedText({
         'en': 'Manage everything in one place',
         'id': 'Kelola semuanya dalam satu tempat',
       }),
       appDescription: const LocalizedText({
         'en': 'A modern app for daily life.',
         'id': 'Aplikasi modern untuk kehidupan sehari-hari.',
       }),
       supportEmail: 'hello@projectbaru.app',
     ),
     supportedLocales: const [Locale('en'), Locale('id')],
     defaultLocale: const Locale('en'),
     productIds: const ['remove_ads'],
     playStoreUrl: 'https://play.google.com/store/apps/details?id=...',
     appStoreUrl: 'https://apps.apple.com/app/id...',
     moreAppsUrl: 'https://play.google.com/store/apps/developer?id=...',
     onboarding: OnboardingConfig(
       pages: [
         OnboardingPage(
           title: 'Selamat datang',
           description: 'Jelajahi fitur utama aplikasi.',
           icon: Icons.waving_hand,
         ),
       ],
     ),
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
- `SettingsScreen`: pilih mode tema (system/light/dark), ukuran font, jenis font,
  dan bahasa. Bisa ditambah item dengan `SettingsScreen(extra: [...])`.
- `AppTitle` & `AppVersionText`: judul AppBar "NamaApp versi" dan label versi.

## Kustomisasi tampilan

Tema bersifat **monochrome + brand accent**: seluruh teks dan permukaan selalu hitam-di-atas-putih
(light) atau putih-di-atas-hitam (dark). Satu-satunya knob warna adalah `accentColor`, yang dipakai
penuh hanya untuk aksi utama (tombol primary, chip accent, link). Override warna netral tidak
disediakan, jadi tema gelap tidak akan pernah "bocor" warna putih.

```dart
final appConfig = AppConfig(
  brand: BrandConfig(
    appName: 'App',
    packageId: 'com.app',
  ),
  theme: ThemeConfig(
    accentColor: const Color(0xFF0EA5E9),
    defaultFontSize: AppFontSize.normal,
    fontFamily: 'Poppins',
  ),
  content: ContentConfig(
    welcomeTitle: const LocalizedText({
      'en': 'Welcome',
      'id': 'Selamat datang',
    }),
  ),
  supportedLocales: const [Locale('en'), Locale('id')],
  defaultLocale: const Locale('en'),
  fonts: const [
    AppFont(name: 'Default'),
    AppFont(name: 'Inter', fontFamily: 'Inter'),
    AppFont(name: 'Poppins', fontFamily: 'Poppins'),
    AppFont(name: 'Manrope', fontFamily: 'Manrope'),
    AppFont(name: 'Lexend', fontFamily: 'Lexend'),
  ],
);
```

## Setup native (per project)

Beberapa hal tidak bisa dari package dan tetap diatur di app konsumen:

- `permission_handler`: deklarasikan `<uses-permission>` di `AndroidManifest.xml` dan usage
  description (mis. `NSCameraUsageDescription`) di `Info.plist`. Set `compileSdk` Android
  minimal 37 (`compileSdk = maxOf(flutter.compileSdkVersion, 37)`).
- Android `minSdk` minimal 23.
- Product ID IAP & signing dikonfigurasi di Play Console.

> **Catatan AdMob:** package ini sengaja **tidak** membawa `google_mobile_ads`. Monetisasi
> iklan ditambahkan langsung di app konsumen saat sudah siap listing, agar build lebih ringan
> dan listing lebih cepat. Saat sudah siap: tambahkan `google_mobile_ads` di `pubspec.yaml` app,
> isi App ID di `AndroidManifest.xml` / `Info.plist`, lalu bungkus sendiri widget banner-nya.

## Development

```bash
flutter pub get
flutter analyze
flutter test
dart format .
flutter gen-l10n

cd project/example && flutter run -d <device>   # jalankan example app
```

## Versi & rilis

- Mengikuti **Semantic Versioning**. Perubahan breaking menaikkan MAJOR dan dicatat di
  [`CHANGELOG.md`](CHANGELOG.md).
- Rilis ke pub.dev:

  ```bash
  flutter pub publish --dry-run   # validasi
  flutter pub publish
  ```
