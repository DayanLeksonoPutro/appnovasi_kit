# appnovasi_kit

Flutter boilerplate framework untuk mempercepat pembuatan app Play Store.
Integrasi **config-only**: tambahkan dependency, isi satu `AppConfig`, aplikasi langsung setengah jadi.

## Fitur

- Tema Material 3 (light/dark) + font **Poppins** bundled, bisa dioverride.
- Multi-bahasa (i18n) dengan `flutter_localizations`, locale EN/ID bawaan.
- Penyimpanan lokal **Hive** (wajib, satu-satunya storage).
- Navigasi **go_router** dengan helper guard.
- AdMob: banner + interstitial.
- In-app purchase (`in_app_purchase`).
- Widget siap pakai: `ShareButton`, `RateButton`, `AdBanner`.
- Controller siap pakai: `ThemeController`, `LocaleController`.

## Cara pakai

1. Tambahkan dependency:

   ```yaml
   dependencies:
     appnovasi_kit:
       path: ../boilerplate_flutter   # atau git: { url: ..., ref: v0.1.0 }
   ```

2. Isi konfigurasi di satu file:

   ```dart
   const appConfig = AppConfig(
     appName: 'Project Baru',
     packageId: 'com.appnovasi.project_baru',
     supportedLocales: [Locale('en'), Locale('id')],
     defaultLocale: Locale('en'),
     bannerUnitId: 'ca-app-pub-xxx/yyy',
     productIds: ['remove_ads'],
     playStoreUrl: 'https://play.google.com/store/apps/details?id=...',
   );
   ```

3. `main.dart` tipis:

   ```dart
   Future<void> main() async {
     await AppKit.initialize(appConfig);
     runApp(const AppKitApp(config: appConfig, home: HomePage()));
   }
   ```

Lihat folder `example/` untuk contoh lengkap.

## Setup native (per project)

- AdMob App ID di `AndroidManifest.xml` (`com.google.android.gms.ads.APPLICATION_ID`) dan
  `Info.plist` (`GADApplicationIdentifier`).
- Android `minSdk` minimal 23.
- Product ID & signing dikonfigurasi di Play Console.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter gen-l10n
```
