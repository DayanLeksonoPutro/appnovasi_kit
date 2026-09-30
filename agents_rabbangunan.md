# Agent Brief — Kalkulator RAB Bangunan

Status: **Kandidat alternatif** (skor 17/20 —competition terkuat, tapi demand belum terbukti)
Asal: [[rangkuman_app]] Bagian 3.1
Tanggal: 30 Sep 2026

---

## Konsep

Kalkulator Rencana Anggaran Biaya (RAB) untuk pemilik rumah, mandor, dan pemborong — hitung kebutuhan material + estimasi biaya **offline**, simpan hasil, share list belanja ke WhatsApp.

Positioning 1 kalimat:
> **"Hitung RAB bangun rumah tanpa Internet. Simpan, share ke tukang,支配 budget tidak jebol."**

---

## Kenapa kandidat ini dipilih

| Fakta | Data |
|---|---|
| Incumbent utama | Kalkulator Bangunan & Material (BONGSOJOYO) — **500+ install, 0 review** |
| Kompetitor lain | Kalkulator Material Bangunan (ARDStudio), SeptaLabs — tanpa install count |
| Update terakhir incumbent | 8 Mei 2026 (aktif, tapi tidak traction) |
| Willingness to pay | RAB = keputusan involve jutaan rupiah._margin of error mahal. |
| Skill | Reuse Blueprint B (kalkulator trader) — sudah terbukti 2x |

**7 kompetitor di ceruk ini, tapi nol yang punya traction.** Ini bukan pasar sehat, ini pasar yang belum terjadi.

---

## ⚠️ Risiko utama (WAJIB baca)

| Risiko | Detail | Mitigasi |
|---|---|---|
| 🔴 **Demand mungkin memang kecil** | 500+ install setelah update Mei 2026 = mungkin bukan "belum digarap", tapi memang tidak ada yang cari | **Validasi dulu sebelum coding.** Cek volume keyword "kalkulator RAB" di Indonesia. Kalau < 500/bulan, gugur |
| 🔴 **Incumbent fitur-nya sudah lengkap** | 10 fitur: rangka besi, cat, baja ringan, cor dak, plafon, hebel, bata roster, keramik, plesteran, + share WhatsApp. Plus disclaimer SNI. | ❌ Jangan compete "lebih lengkap". ✅ **Menang lewat ASO, bukan fitur** |
| 🟡 **Akurasi = liability** | Salah hitung RAB = user rugi millions. Satu review 1★_bad = 50 review Susah balik | Tampilkan disclaimer. Simpan asumsi/koefisien di dalam app. Test dengan tukang sungguhan |
| 🟡 **Monetisasi ad-based jelek** | eCPM ID banner $0.02-0.10, interstitial $0.12-0.55. Kalkulator = session 30 detik | **Harus IAP, bukan ads** |
| 🟡 **Tidak daily-use** | Seseorang hitung RAB saat renovasi saja, lalu app tidak dibuka 2 bulan | Framing: revenue per install, bukan ARPDAU. Dan listing harus tetap terinstall untuk "reference" |

---

## Target pengguna

**Persona utama — Pemilik rumah yang renovasi**
- Punya uang, tidak paham технические termos
- Takut dikira tukang atau di bawah-overbudget
- Suka angka"RAB ini Rp 85 juta" — confident dalam angka

**Persona sekunder — Mandor / pemborong**
- Butuh hitungan cepat untuk material di lapangan
- Syaratnya: **harus offline**, tidak ada sinyal di lokasi

**Persona ketiga — Tukang sendiri**
--cek jumlah*Dus keramik* atau*tonase besi* sebelum beli ke toko
- Already ada化合物nya: "tanya tukang lain" / "youtube". Tapi tidak instan dan tidak trustworthy

---

## Feature set

### MVP (Phase 1) — 4 kalkulator inti
1. **Kalkulator Cat** — luas dinding (kurangi pintu/jendela) → liter, galon, pail
2. **Kalkulator Keramik** — luas lantai + waste margin 5% → keping + dus
3. **Kalkulator Cor Dak** — volume m³ → semen, pasir, batu split
4. **Kalkulator Bata Merah** — luas dinding → ribuan keping

### Phase 2
5. Rangka besi struktural (tulangan, begel, tonase)
6. Baja ringan / atap (truss, spandek)
7. Plafon PVC & gypsum
8. Hebel vs bata merah comparison
9. Plesteran & acian
10. **RAB lengkap** (gabung semua item, grand total)
11. **Simpan RAB + export/share ke WhatsApp** ← ini yang bikin orang balik
12. Update harga material (dari user / regional)

### Jangan bikin (v1)
- ❌ AI anything
- ❌ Cloud sync
- ❌ Akun
- ❌ Order material (bisa di فيدي future)
- ❌ Gambar technical / blueprint parser

---

## Monetisasi

| Model | Detail |
|---|---|
| **IAP one-time (utama)** | Rp 39.000-79.000. Unlock: semua kalkulator advanced, RAB lengkap, simpan/export. Reasoning: user yang butuh semua fitur = user yang sedang renovasi = punya budget |
| **Ads** | Banner bawah, free tier cukup 2-3 kalkulator. JANGAN interstitial — session 20 detik, akan kena policy review dan review jelek |
| **Upsell point** | "Pakai Kalkulator Besi" — taruh di hasil kalkulator cor, sebagai cross-sell natural ke IAP |

Struktur: free tier **cukup untuk orang casual** (cari tau "cat berapa liter"), IAP untuk yang **serius renovasi**.

---

## ASO plan — INI PRIORITAS UTAMA

Karena incumbent sudah fitur lengkap, **satu-satunya cara menang adalah metadata dan keyword coverage.**

### Metadata
| Field | Isi |
|---|---|
| Title (30 char) | `Kalkulator RAB Bangunan` |
| Short description (80 char) | `Hitung RAB, cat, keramik, besi, cor dak. Offline. Share ke tukang via WA.` |
| Long description | Wajib contain semua nama material **dengan variasi ejaan** — orang search "besi" dan "baja" dan "tulangan" untuk hal yang sama |

### Long-tail target
```
kalkulator rab         hitung material bangun     kalkulator cat
kalkulator keramik     hitung besi                kalkulator cor dak
rab rumah              hitung biaya renovasi       kalkulator bata merah
kalkulator plafon      kalkulator hebel            hitung kebutuhan cat
kalkulator baja ringan  rab bangunan               kalkulator mandibular
```

### Angle ASO yang bisa dipakai
Incumbent pakai kata "RAB" di title. Tapi **banyak user tidak tahu istilah itu.** Yang mereka search:
- "**hitung cat**" (bukan "kalkulator cat")
- "**berapa banyak keramik**"
- "**biaya bangun rumah**"
- "**cor dak butuh semen berapa**"

Buat title/deskripsi yang **menggunakan bahasa awam, bukan istilah teknik**. Ini celah ASO-nya.

---

## Competitive teardown

| App | Install | Rating | Weakness |
|---|---|---|---|
| **Kalkulator Bangunan & Material** (BONGSOJOYO) | 500+ | 0 review | Async. 10 fitur tapi tidak ter-backlink, tidak di-backlink, tidak ter-review. **UI mungkin bagus tapi tidak ada yang menemukan** |
| Kalkulator Material Bangunan (ARDStudio) | — | — | Tidak terlihat traction |
| Kalkulator Material & Bangunan (SeptaLabs) | — | — | Idem |
| Kalkulator Konstruksi AI Pro (BilgeCode) | — | 4,7★ | English-first, istilah teknik. Tidak lokal |
| Kalkulator Biaya Konstruksi (FourthPointer) | paid | — | English |
| Kalkulator Konstruksi Sipil (CpcTech) | — | 4,6★ | Bahasa Inggris |

**Insight: sebagian besar kompetitor global berbahasa Inggris dan pakai istilah teknik.** Yang local-first (bahasa Indonesia) cuma 1 dan belum traction. Ini window.

---

## Kill criteria (hentikan kalau salah satu terjadi)

- ❌ Volume "kalkulator RAB", "kalkulator bangunan", "hitung cat" di Indonesia < 500 searches/bulan → **gugur, pindah ke Pas Foto**
- ❌ Incumbent BONGSOJOYO release fitur baru dalam 3 bulan terakhir dan mulai dapat traction (install naik ke 10K) → celah tertutup
- ❌uration Testing: 3 tukang sungguhan pakai, hasilnya meleset dari perhitungan mereka → **akurasi tidak achievable, gugur**

**Kill criteria ini serius.** Kalau RAB-nya salah, orang merugi dan review-mu hancur. Lebih baik tidak bikin.

---

## Tech notes

- Flutter
- State: Riverpod (konsisten dengan app lain)
- Local storage: Hive / Isar (RAB yang disimpan user = data lokal, no server)
- Export/share: `share_plus` → share teks ke WhatsApp
- **WAJIB**: 100% offline, tidak ada API harga dari server. Kalau perlu update harga → user input sendiri (self-referential, tetap offline)
- Decision log / calculation trace: user bisa lihat step-by-step. Ini membangun trust.

---

## Kenapa ini **belum** jadi kandidat utama

Skor 17/20 vs Pas Foto 16/20, tapi:
- **Pas Foto** = demand-nya terbukti (user sudah bayar Rp 93rb-399rb), monetisasi jelas, skill 100% reuse
- **Kalkulator RAB** = demand-nya *mungkin* ada tapi belum ada yang klik, dan akurasi = liability yang besar

Killed risk-nya lebih tinggi. Baru pindah ke sini kalau Pas Foto gagal kill-criteria-nya.

---

## Cross-reference

- [[rangkuman_app]] — scanning + scoring
- [[agents_pasfoto]] — kandidat utama
- AGENTS.md — "Blueprint B — Niche calculator" yang sudah terbukti (Forex Calculator, Forex Smart Money, Kalkulator Slametan)
