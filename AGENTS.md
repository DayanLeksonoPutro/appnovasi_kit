# AGENTS.md — appnovasi_kit (Flutter Boilerplate / Framework)

> Nama package: **`appnovasi_kit`** (final). `AppConfig` = objek konfigurasi publik satu-satunya.

## 1. Apa itu repo ini

Repo ini adalah **Flutter package/framework yang dimaintenance**, BUKAN app standalone.
Tujuannya: app baru cukup menambahkan dependency ini + mengisi satu objek konfigurasi,
lalu aplikasi sudah "setengah jadi".

Ada dua audiens yang berbeda:

- **Maintainer** — bekerja di dalam repo ini, mengubah/menambah fitur package.
- **Consumer** — app turunan yang meng-`import 'package:appnovasi_kit/appnovasi_kit.dart'` dan hanya
  menyediakan konfigurasi. Consumer tidak boleh menyentuh `lib/src/`.

## 2. Prinsip inti: "Config-only integration"

Target utama: app baru mencapai ~50% siap hanya dengan (1) menambah dependency dan
(2) mengisi `AppConfig`.

Setiap fitur baru harus dites dengan pertanyaan: *"Bisakah consumer memakainya tanpa
mengedit kode internal package?"* Jika tidak, desainnya salah.

## 3. Tech Stack

- Flutter SDK: `>= 3.35.0` (diuji pada 3.44.4)
- Dart: `>= 3.12.2`
- State management: **Provider** (ChangeNotifier)
- Storage lokal: **Hive** (WAJIB, default satu-satunya storage key-value & objek)
- Routing: **go_router**
- i18n: `flutter_localizations` + `intl` (file `.arb`)
- Font: font bundled di package (mis. Inter/Poppins) + override lewat `AppConfig`
- Monetisasi: `google_mobile_ads`, `in_app_purchase`
- Lain: `share_plus`, `url_launcher`, `package_info_plus`

> Repo ini **single package** (`appnovasi_kit`) + folder `example/`. Tidak pakai Melos
> kecuali nanti benar-benar perlu multi-package.

## 4. Struktur folder (feature-first ringan)

```
lib/
  appnovasi_kit.dart      # BARREL publik — satu-satunya pintu keluar API
  src/
    core/                 # AppConfig, AppKit, AppKitApp, DI/registry provider, util
    services/             # storage, theme, locale, ads, iap, share, rate
    features/             # modul feature-first (settings, ...)
    widgets/              # widget bersama (ShareButton, RateButton, AdBanner)
    routing/              # konfigurasi go_router + guard
  l10n/                   # file .arb + gen/ (generated, jangan diedit manual)
assets/fonts/             # font bundled (Poppins)
example/                  # app konsumen contoh (bukti integrasi config-only)
test/
```

Aturan:
- `src/` bersifat **private**. Hanya boleh diekspos lewat barrel `lib/appnovasi_kit.dart`.
- Apa pun yang tidak ada di barrel = internal, bebas diubah tanpa menyentuh versioning breaking.
- Feature-first: tiap feature memiliki provider, widget, dan model sendiri.
- Hindari single-file `main.dart` besar. Single-file hanya boleh untuk `example/`.

## 5. Kontrak API publik (yang dilihat consumer)

Permukaan API yang boleh dipakai consumer:
- `AppKit.initialize(AppConfig config)` — setup awal (ads, storage, iap).
- `AppKitApp(...)` — root widget pembungkus `MaterialApp` (theme, locale, router).
- Widget siap pakai: `ShareButton`, `RateButton`, dll.
- Service yang diakses lewat Provider: `StorageService`, `ThemeController`,
  `LocaleController`, `AdService`, `PurchaseService`.

Aturan:
- Menambah item baru = **non-breaking**.
- Mengubah/menghapus tanda tangan yang sudah ada = **breaking** (lihat §9).

## 6. Konfigurasi & konstanta

Semua nilai yang berbeda antar-app HARUS lewat `AppConfig`, tidak boleh hardcode di `lib/`:

- `appName`, `packageId`
- Theme: `seedColor`, `lightTheme`, `darkTheme`
- Font: `fontFamily` (default dari package, consumer boleh override)
- Locale: `supportedLocales`, `defaultLocale`
- AdMob: `bannerUnitId`, `interstitialUnitId`, `appOpenUnitId`, (android/ios terpisah)
- IAP: daftar `productIds`
- Store: `playStoreUrl`, `appStoreUrl`, `privacyPolicyUrl`, `termsUrl`

Package sudah menyediakan **theme default & font bundled**, jadi consumer hanya perlu
mengoverride lewat `AppConfig` bila ingin berbeda (config-only).

**Jangan pernah** menaruh ID rahasia/API key langsung di `lib/` atau commit ke repo.
Nilai non-rahasia (AdMob unit ID, product ID) tetap lewat `AppConfig` agar konsisten.

## 7. Konvensi kode

- File & folder: `snake_case`.
- Class/enum/typedef: `PascalCase`.
- Variabel/fungsi: `camelCase`.
- Konstanta: `lowerCamelCase` (bukan SCREAMING_CASE), kecuali enum.
- Provider: expose `ChangeNotifier` via `ChangeNotifierProvider`; pakai `context.watch/read/select`.
  Hindari `context.read` di dalam `build`.
- Import: urutkan dart → package → relative. Gunakan barrel `appnovasi_kit.dart` untuk export publik.
- Tanpa komentar kecuali diminta. Kode harus self-documenting.
- Tidak ada `print`; gunakan logger terpusat.

## 8. Commands

```bash
flutter pub get
flutter analyze
flutter test
dart format .

flutter run -d <device>          # jalankan example app
flutter build appbundle --release

flutter gen-l10n                 # regenerate lokalisasi
```

## 9. Versioning & rilis

- Ikuti **Semantic Versioning** (`MAJOR.MINOR.PATCH`).
- Setiap perubahan breaking → naikkan MAJOR + catat di `CHANGELOG.md`.
- Perubahan pada area ter-private (`src/` yang tidak diekspor) → biasanya PATCH.
- Rilis: update `CHANGELOG.md` → bump `pubspec.yaml` version → tag git.
- Consumer memakai dependency via git tag atau private pub, bukan `path`.

## 10. Testing

- `test/` untuk unit test service & controller.
- Widget test untuk widget publik (`ShareButton`, dll.).
- Wajib jalankan `flutter analyze` dan `flutter test` sebelum menganggap task selesai.
- Feature baru sebaiknya punya minimal satu test.

## 11. Do's & Don'ts

Do:
- Tambah API lewat barrel `appnovasi_kit.dart`.
- Bungkus semua config ke `AppConfig`.
- Jaga `example/` tetap bisa jalan sebagai bukti integrasi.

Don't:
- Mengekspor file `src/` langsung dari luar barrel.
- Hardcode AdMob/product ID/secret di `lib/`.
- Menambah dependency berat tanpa alasan.
- Mengubah API publik tanpa bump versi & changelog.

## 12. Secrets

- Signing key, keystore, API key → TIDAK di repo; dokumentasikan di `docs/`.
- Android/iOS app ID AdMob diletakkan di manifest native app konsumen, bukan package.

## 13. Cara pakai untuk consumer (config-only)

Contoh `example/` adalah bukti integrasi. Alur tiap project baru:

1. `flutter create --org com.appnovasi project_baru`
2. Tambahkan dependency:
   - Dev: `appnovasi_kit: { path: ../boilerplate_flutter }`
   - Rilis: `appnovasi_kit: ^0.1.0` (package publik di pub.dev; app turunan tetap privat)
3. Isi konfigurasi di satu file (`lib/app_config.dart`):
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
4. `main.dart` tipis:
   ```dart
   Future<void> main() async {
     await AppKit.initialize(appConfig);
     runApp(const AppKitApp(config: appConfig, home: HomePage()));
   }
   ```
5. Pakai widget/service siap pakai, mis. `ShareButton`, `RateButton`, `AdBanner`,
   `context.read<ThemeController>().toggle()`, `context.read<LocaleController>()`.

Langkah native yang tetap manual per-project (tidak bisa di package):
- AdMob **App ID** di `AndroidManifest.xml` (`com.google.android.gms.ads.APPLICATION_ID`)
  dan `Info.plist` (`GADApplicationIdentifier`).
- Activity/billing product ID di Play Console, keystore/signing.

## 14. Pending decisions (perlu diisi saat setup)

- [ ] go_router sebagai default (atau Navigator bawaan)?

## 15. Distribusi & publikasi

- Package `appnovasi_kit` **publik di pub.dev** (portofolio). App turunan konsumen tetap privat.
- Rilis ke pub.dev:
  ```bash
  flutter pub publish --dry-run   # validasi
  flutter pub publish
  ```
- Wajib update `CHANGELOG.md` + bump `version` di `pubspec.yaml` sebelum publish.
- Karena publik: **jangan pernah** commit secret/API key/signing ke repo atau ke `lib/`.
- `publish_to: none` harus dihapus dari `pubspec.yaml` sebelum publish pertama.
