# AI App Onboarding Template

## Tujuan

Dokumen ini dipakai untuk membantu AI, developer baru, atau tim produk memahami cara kerja app yang dibangun di atas `appnovasi_kit`.

Tujuan utamanya:

- AI fokus ke fitur nyata app, bukan membongkar framework
- perubahan dibuat di project app, bukan di package core
- semua branding dan config diatur lewat `AppConfig`
- fitur custom dibuat di app sesuai kebutuhan bisnis

---

## Prinsip utama

### 1. Ini adalah project app, bukan package core

Project ini harus diperlakukan sebagai app consumer dari `appnovasi_kit`.

Jangan:

- mengedit file di `lib/src/` package
- menambahkan logic framework di package core
- mengubah behavior global yang seharusnya diatur via config

Lakukan:

- membuat feature khusus app di `lib/` project app
- mengisi `AppConfig` untuk brand, theme, content, dan routing
- menambahkan screen, feature, dan service khusus app

---

### 2. Config-first architecture

Semua yang bersifat unik per app harus lewat konfigurasi, bukan hardcode.

Contoh yang harus masuk ke config:

- nama app
- slogan
- package ID
- support email
- URL legal
- warna utama
- font default
- locale yang didukung
- onboarding
- navigation tabs
- copy welcome / hero / legal

Jika fitur belum ada di config, pertimbangkan apakah itu memang perlu dibuat sebagai field konfigurasi.

---

### 3. Fokus pada produk, bukan boilerplate

AI atau developer baru tidak perlu memahami seluruh internals package.

Yang perlu dipahami cukup:

- project ini memakai `appnovasi_kit`
- core app setup sudah ada
- app baru tinggal mengisi config dan menambahkan screen/feature khusus
- `AppKit.initialize(...)` dan `AppKitApp(...)` adalah entry point utama

---

## Struktur kerja yang dianjurkan

```text
lib/
  app_config.dart
  main.dart
  features/
    home/
    profile/
    auth/
    dashboard/
  widgets/
    custom_card.dart
    custom_header.dart
  services/
    api_service.dart
    analytics_service.dart
  routes/
    app_routes.dart
```

Aturan:

- `appnovasi_kit` dipakai sebagai framework dasar
- app-specific logic diletakkan di project app, bukan di package core
- semua screen custom dibuat sesuai kebutuhan bisnis
- routing dan navigation tetap mengikuti pattern yang ada di package

---

## Entry point yang harus dipahami

### Setup utama

```dart
Future<void> main() async {
  await AppKit.initialize(appConfig);

  runApp(
    AppKitApp(
      config: appConfig,
      routes: {
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
      },
    ),
  );
}
```

### Konfigurasi utama

```dart
final appConfig = AppConfig(
  brand: BrandConfig(
    appName: 'Nama App',
    packageId: 'com.example.app',
    description: 'Deskripsi app',
    slogan: 'Slogan app',
    supportEmail: 'hello@example.com',
  ),
  theme: ThemeConfig(
    seedColor: const Color(0xFF4F46E5),
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
      'en': 'Build better products',
      'id': 'Bangun produk yang lebih baik',
    }),
  ),
  supportedLocales: const [Locale('en'), Locale('id')],
  defaultLocale: const Locale('en'),
);
```

---

## Batasan kerja AI / developer baru

### Diperbolehkan

- membuat feature baru di project app
- membuat screen dan widget baru
- menambahkan service khusus app
- mengubah copy dan konfigurasi app
- menambahkan route / navigation custom
- menghubungkan data API dan state management app

### Tidak diperbolehkan tanpa alasan jelas

- mengubah behavior internal `appnovasi_kit`
- menambah hardcoded config yang seharusnya ada di `AppConfig`
- mengubah service global yang sudah disediakan package
- mengubah desain framework tanpa diskusi
- menambah dependency besar tanpa rasionalisasi bisnis

---

## Panduan tugas untuk AI

Saat menerima task, AI harus bertanya/menilai hal berikut:

1. Apakah task ini spesifik untuk app ini atau framework? 
   - Jika spesifik untuk app: buat di project app
   - Jika framework umum: evaluasi apakah harus ditambah ke `appnovasi_kit`

2. Apakah task bisa diselesaikan dengan config? 
   - Jika ya, pakai `AppConfig` atau config object

3. Apakah task memerlukan screen baru? 
   - Jika ya, buat screen di project app

4. Apakah task memerlukan logic bisnis baru? 
   - Jika ya, buat service/model khusus app

5. Apakah task perlu tambahan localization atau copy? 
   - Jika ya, tambahkan ke `ContentConfig` dan `LocalizedText`

---

## Workflow rekomendasi

### Saat bikin feature baru

1. Tentukan apakah feature itu app-specific atau framework-wide
2. Kalau app-specific, buat di `lib/features/...`
3. Apabila perlu branding/tampilan, hubungkan ke `ThemeConfig`
4. Apabila perlu copy UI, masukkan ke `ContentConfig`
5. Kalau perlu route, daftarkan di router app
6. Uji dengan `flutter analyze` dan `flutter test`

---

## Daftar yang harus ada di app baru

Setiap app baru minimal harus punya:

- `lib/app_config.dart`
- `lib/main.dart`
- route utama app
- screen home
- feature folder sesuai kebutuhan
- konfigurasi brand/theme/content
- locale default yang jelas

---

## Checklist sebelum selesai

- [ ] semua brand info sudah lewat `BrandConfig`
- [ ] semua styling utama lewat `ThemeConfig`
- [ ] semua copy user-facing lewat `ContentConfig`
- [ ] tidak ada hardcode app identity di widget atau screen
- [ ] app-specific feature dibuat di project app, bukan package core
- [ ] route dan navigation jelas
- [ ] locale sudah diatur
- [ ] build dan test sudah dijalankan

---

## Template singkat untuk AI / tim baru

```md
# Project Name

## Architecture
This project uses appnovasi_kit as the base framework.
All app identity and behavior that differ per project are configured in AppConfig.

## Rules
- Do not edit package source in lib/src/
- Add app-specific features under lib/features/
- Use BrandConfig, ThemeConfig, and ContentConfig for app identity
- Keep the app configurable and reusable

## Main entry
- AppKit.initialize(appConfig)
- AppKitApp(config: appConfig, routes: {...})

## Custom feature flow
- create screen
- create model/service if needed
- register route
- add copy to ContentConfig if user-facing
- use theme values from ThemeConfig
```

---

## Kesimpulan

AI harus dibimbing untuk memahami bahwa project ini adalah app consumer dari `appnovasi_kit`, bukan framework yang perlu dibongkar.

Dengan cara ini, AI akan fokus pada:

- fitur bisnis
- perilaku app
- branding dan copy
- route dan UX
- integrasi API dan state

Bukan pada boilerplate atau internal package.
