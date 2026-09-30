# Agent Brief — Pas Foto + Dokumen Offline

Status: **Kandidat utama** (skor 16/20)
Asal: [[rangkuman_app]] Bagian 4
Tanggal: 30 Sep 2026

---

## Konsep

Toolkit dokumen lokal untuk orang Indonesia yang butuh **pas foto, KTP, ijazah, dan dokumen PDF** dalam format yang bisa diupload ke situs pemerintah / kampus / perusahaan.

Positioning 1 kalimat:
> **"Offline. Tanpa akun. Pas foto 3x4, KTP, dan compress PDF langsung ke ukuran yang diminta."**

Bukan "pas foto app". Tapi **alat untuk submit dokumen**.

---

## Kenapa kandidat ini dipilih

| Fakta | Data |
|---|---|
| User sudah terbiasa bayar | Nuts Mobile Rp 93.000 (4,9★), Coocent Rp 399.000 (5,0★) |
| Search "ubah ukuran foto 3x4" | Cuma **12 hasil**, semua tanpa install count |
| Long-tail belum taken | "kompres pdf offline", "cetak foto", "ukuran foto cetak" |
| Skill yang dipakai | 100% reuse dari Blueprint A (foto/processing) |
| IAP punya alasan jelas | Batas ukuran file untuk upload situs gov, bukan sekadar "remove ads" |

Revenue projection: IAP one-time bisa **10x** banner-only timestamp, karena user punya urgensi/task yang jelas, bukan sekadar pakai gratisan.

---

## Risiko utama (read sebelum mulai)

| Risiko | Detail | Mitigasi |
|---|---|---|
| 🔴 **Trigger rendah** | Orang butuh pas foto saatDaftar kerja/sekolah, bukan harian. Festival session pendek | Jangan andalkan DAU. Optic revenue per install, bukan ARPDAU |
| 🟡 **Frekuensi rendah = banner jelek** | eCPM ID interstitial $0.12-0.55, banner $0.02-0.10. 2-3 session/hari = impression sangat sedikit | Fokus IAP. Banner hanya sebagai fallback, janganAds-first design |
| 🟡 **Scope creep ke "all-in-one"** | Kalau jadi "toolkit lengkap", langsungwana Smallpdf. Jangan | **Fokus 1 job: submit dokumen.** 5-7 fitur, bukan 25 |
| 🟡 **Kompetitor global masuk** | Coocent sudah di Rp 399.000 dan punya fitur AI | Beat via lokalisasi (format KTP/pas foto Indonesia) + offline, bukan via fitur |

---

## Target pengguna

**Persona utama — Job seeker / poker fresher**
- Lagi daftar kerja, butuh pas foto 3x4 + scan KTP + ijazah jadi PDF
- Sering upload ke gov site yang reject kalau ukuran file > 500KB
- Nggak mau daftar akun, nggak mau upload dokumen pribadi ke server stranger

**Persona sekunder — Admin HR / TU sekolah**
- Butuh crop KTP bulk, ubah ke PDF, cetak
- Volume tinggi, punya alasan upgrade

**Persona ketiga — Orang yang ngurus dokumen sendiri (KTP, SIM, paspor)**
- Sekali-sekali, tapi urgensinya tinggi → willing to pay

---

## Feature set

### MVP (Phase 1) — WAJIB ada, ini yang bikin rank top-3
1. **Pas foto 3x4 & 4x6** — crop presisi + background polos (putih/biru/abu)
2. **Crop KTP / SIM** — auto-detect edge, straighten perspective
3. **Kompres foto ke KB** — slider target ukuran (100KB / 200KB / 500KB)
4. **Foto → PDF** — beberapa foto jadi 1 PDF A4
5. **Kompres PDF** — target ukuran file
6. **Simpan hasil ke Gallery** — user harus bisa submit hasilnya
7. **Offline 100%** — tidak ada network call sama sekali

### Phase 2
8. Tambah halaman PDF (hapus halaman, extract halaman)
9. Gabung beberapa PDF
10. Watermark PDF
11. Batch: crop 20 KTP sekaligus
12. Preset ukuran Indonesia (KTP, pas foto, ijazah, akta, Surat Izin)

### Jangan bikin (v1)
- ❌ OCR
- ❌ AI background removal
- ❌ Cloud sync
- ❌ Akun
- ❌ PDF ke Word/Excel (itu feat Smallpdf/INTSIG, jangan masuk)

---

## Monetisasi

| Model | Detail |
|---|---|
| **IAP one-time (utama)** | Rp 29.000-49.000. Unlock: batch, compress PDF, watermark, tanpa batas export |
| **Ads (fallback)** | 1 banner bawah (non-intrusive) di free tier. JANGAN interstitial — session terlalu pendek, akan kena retention + jelek review |
| **Ads (alternatif)** | Rewarded ad untuk user yang mau batch 1x tanpa bayar. Ini cara baik monetisasi tanpa bunuh UX |

Struktur free tier harus **genuinely usable** — 1-2 fitur inti gratis, sisanya IAP. Jangan trial 7 hari, itu cuma menurunkan trust dan bikin uninstall.

---

## ASO plan

### Metadata
| Field | Isi | Catatan |
|---|---|---|
| Title (30 char) | `Pas Foto 3x4 & Kompres PDF` | 2 head term,顺序 by volume |
| Short description (80 char) | `Buat pas foto, crop KTP, kompres PDF ke ukuran upload. 100% offline.` | Keyword natural, no stuffing |
| Long description | Bawa long-tail 5-7x natural | Play Store **index full text** unlike iOS |

### Long-tail target (semua harus muncul natural di deskripsi)
```
ukuran foto          pas foto 3x4        pas foto 4x6
ubah ukuran foto     buat foto ktp        crop ktp
foto paspor          ganti latar foto     background foto polos
kompres foto         compress pdf         kompres pdf offline
foto ke pdf          pdf ke foto          ukuran foto cetak
```

### Strategi ranking
- **Head term** ("pas foto") → **jangan kejar**. Incumbent sudah di 4,8★ dengan install besar
- **Long-tail** ("kompres pdf offline", "ukuran foto cetak") → **inilah target utama**. 12 hasil, tidak ada yang backlink
- Data pendukung: target 3-4 kata long-tail = **+32% organic install dalam 60 hari** vs head term
- Sekali top-3 di long-tail biasanya bertahan, karena kompetitor cuma kejar head term

### Screenshot strategy
Slide 1 = hasil akhir, bukan UI. Tampilkan "3x4 standar 3x4 cm" + ukuran file. Orang beli hasil, bukan fitur.

---

## Competitive teardown

| App | Rating | Install | Kelemahan yang bisa diserbu |
|---|---|---|---|
| Pas foto (sirane) | 4,8★ | — | Ranking #1, tapi UI_nbisa di-infer |
| Pas Foto 3x4 4x6 (StedyWorks) | 4,6★ | — | Sudah lokal, jadi pasti ada fitur lokal juga |
| Foto Paspor & ID (KX Camera) | 4,9★ | — | |
| Foto ID & Paspor (Nuts Mobile) | 4,9★ | paid Rp 93k | Sudah legacy, UI mungkin kuno |
| ID Photo Pro | — | — | |
| Kompres File PDF (SmartApps38) | 4,9★ | **10 jt+** | ❌ Jangan tandingi head-on, ini yg bikin unbeatable |

**Insight:** kompetitor pas foto global tidak tahu format Indonesia (KTP, KKB, akta format tertentu). Sinergi: **preset Indonesia** + offline + harga lokal = walpaper.

---

## Kill criteria (hentikan kalau salah satu ini terjadi)

- ❌ Google Trends Indonesia untuk "pas foto"/"ukuran foto" **turun** dalam 12 bulan terakhir
- ❌ Total volume 10 long-tail keyword < 500 searches/bulan (AppTweak/Applyra, filter Indonesia)
- ❌ Top 10 di head term semua rating > 4,2★ DAN install > 100rb (meaning they're defended)
- ❌ Target 1-2% IAP conversion — kalau user nggak willing to pay Rp 30rb untuk task yang mereka butuh, monetization model salah

Before invest 4 minggu: cek dulu. Jangan skip.

---

## Tech notes

- Flutter (stack utama)
- Image processing: `image` package atau native (OpenCV) untuk edge detection KTP
- PDF: `syncfusion_flutter_pdf` (free quota) atau `pdf` package
- Compress: `flutter_image_compress`
- **WAJIB**: processing di-device, tidak ada upload. Ini selling point utama dan sekaligus bikin privacy policy-mu singkat.
- Offline = fitur, bukan batasan. Jangan tambah INTERNET permission di v1 kalau bisa dihindari.

---

## Kenapa ini lebih baik dari "App Note" (yang ditolak)

| Faktor | App Note | Pas Foto |
|---|---|---|
| Trigger | "Nanti aja" | Deadline upload |
| Urgensi | 0 | Tinggi |
| IAP | "Remove ads" (lemah) | "Bisa submit" (kuat) |
| UserGenerated data | Ya, tapi nggak pernah dibuka | Ya, dan dibuka untuk submit |
| Monetisasi | Banner $300-1.200/bln @10K DAU | IAP, revenue per install |

---

## Cross-reference

- [[rangkuman_app]] — scanning lengkap + scoring
- [[agents_rabbangunan]] — kandidat alternatif (17/20, tapi demand belum terbukti)
- [[ide_camera_app]] — Batch 1 item #4 "Photo to PDF" dan #9 "ID Card Cropper" **sudah anticipating ide ini**. Ini rekomendasi nyambung dengan ide lama.
