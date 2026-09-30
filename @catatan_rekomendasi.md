# Catatan Rekomendasi: Customization & Unik Per App

## Fokus utama
Tujuan utama package ini adalah agar satu framework bisa dipakai untuk banyak aplikasi yang memiliki identitas berbeda tanpa harus mengubah kode internal package. Untuk itu, customisasi bukan hanya soal tema, tapi juga brand, fitur, navigasi, dan konten.

## 1. BrandConfig + ThemeConfig
Ini adalah layer paling penting untuk membuat setiap app terasa unik.

### BrandConfig
Bertanggung jawab untuk identitas produk, misalnya:
- appName
- slogan
- packageId
- logoAsset
- iconAsset
- supportEmail
- websiteUrl
- privacyPolicyUrl
- termsUrl
- social media links
- playStoreUrl / appStoreUrl / moreAppsUrl

Tujuan:
- tiap app punya karakter sendiri
- tidak perlu hardcode text brand di library
- semuanya bisa dikonfigurasi di satu tempat

### ThemeConfig
Bertanggung jawab untuk ekspresi visual produk, misalnya:
- primary color
- secondary color
- background
- surface
- textPrimary
- textSecondary
- success / warning / error
- radius
- buttonHeight
- cardElevation
- fontFamily
- defaultThemeMode
- defaultFontSize

Tujuan:
- UI bisa diubah tanpa mengubah kode package
- tiap app bisa punya gaya visual yang berbeda
- brand identity dan look & feel dipisah dengan jelas

## 2. Prinsip struktur AppConfig
AppConfig sebaiknya punya elemen yang terstruktur seperti ini:

```dart
class AppConfig {
  final BrandConfig brand;
  final ThemeConfig theme;
  final List<Locale> supportedLocales;
  final Locale defaultLocale;
  final OnboardingConfig? onboarding;
  final BottomNavConfig? navigation;
}
```

Jadi:
- `brand` = identitas produk
- `theme` = visual produk
- `supportedLocales` = localization
- `onboarding` = flow awal app
- `navigation` = struktur navigasi

## 3. Kenapa ini penting
Tanpa brand/theme config yang kuat, semua aplikasi yang dibuat dengan package akan terasa mirip. Customisasi yang hanya ada di satu atau dua field tidak cukup untuk bikin produk terasa unik.

Efek yang didapat:
- package bisa dipakai untuk banyak jenis aplikasi
- tiap proyek punya karakter yang berbeda
- pengembangan app baru lebih cepat
- tidak perlu menulis ulang boilerplate untuk setiap project

## 4. Prioritas pengembangan berikutnya
Setelah `BrandConfig` dan `ThemeConfig`, langkah berikutnya yang paling berguna adalah:

1. Feature flags
   - enable/disable onboarding
   - enable/disable ads
   - enable/disable rate prompt
   - enable/disable premium features
   - enable/disable chat, wallet, login, dll.

2. NavigationConfig yang lebih kaya
   - bottom nav
   - drawer menu
   - role-based route
   - deep link route
   - custom tab config

3. ContentConfig
   - welcome text
   - hero copy
   - legal copy
   - support contact
   - app description

4. ModuleConfig
   - auth
   - dashboard
   - profile
   - checkout
   - blog/news
   - support
   - chat

5. Environment / deployment config
   - dev / staging / prod
   - API base URL
   - remote config
   - feature keys
   - analytics provider

## 5. Ide desain yang disarankan
Package sebaiknya berfungsi seperti starter kit yang bisa disusun, bukan hanya template statis. Artinya:
- default behavior tetap ada
- tetapi tiap app bisa override lewat config
- fitur tambahan bisa diaktifkan tanpa mengubah package core
- consumer hanya perlu mengisi config, bukan menulis ulang logic framework

## 6. Rekomendasi implementasi lanjut
Mulai dari 3 layer yang paling bernilai:
- `BrandConfig`
- `ThemeConfig`
- `FeatureFlags`

Setelah itu baru lanjut ke:
- `NavigationConfig`
- `ModuleConfig`
- `ContentConfig`

## 7. Tujuan akhir
Target akhir package adalah:
- satu base framework
- banyak app dengan identitas berbeda
- config-only integration untuk proyek baru
- cepat dibuat, konsisten, tetapi tetap unik

## 8. Status implementasi saat ini
Telah diimplementasikan:
- `BrandConfig` dan `ThemeConfig` pada `AppConfig`
- kompatibilitas dengan struktur lama tetap terjaga
- verifikasi lint & test sudah berjalan dengan baik

## 9. Hasil verifikasi
Proses validasi yang dilakukan:
- `flutter analyze` → berhasil tanpa issues
- `flutter test test/appnovasi_kit_test.dart --reporter expanded` → semua test passed

## 10. Kesimpulan
Brand dan theme adalah fondasi utama untuk membuat package ini truly customable. Setelah dua layer ini kuat, pengembangan selanjutnya akan lebih mudah dan lebih terarah untuk menambahkan fitur unik per aplikasi.
