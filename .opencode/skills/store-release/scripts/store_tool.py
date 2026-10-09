#!/usr/bin/env python3
"""Validate, render and link-check a store.json (Google Play listing source of truth).

Usage:
    python3 store_tool.py validate <app-root>
    python3 store_tool.py render   <app-root>          # -> store/store-listing.md + metadata/android/*.txt
    python3 store_tool.py links    <app-root>          # network check of every URL
    python3 store_tool.py web      <app-root>          # -> store/web/privacy.html + terms.html
    python3 store_tool.py init     <app-root>          # scaffold store/store.json from app config

All commands exit non-zero on hard errors so they can gate a release.
"""

from __future__ import annotations

import argparse
import html
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

LIMITS = {
    "title": 30,
    "short_description": 80,
    "full_description": 4000,
}

REQUIRED_PATHS = [
    "app.package_id",
    "app.app_name",
    "app.default_locale",
    "listing.title",
    "listing.short_description",
    "listing.full_description",
    "contact.email",
    "contact.privacy_policy_url",
    "release.version",
    "release.version_code",
]

PLACEHOLDER_MARKERS = ("REPLACE_ME", "example.com", "YOUR-", "<")


def dig(data: dict, path: str, default=None):
    cur = data
    for part in path.split("."):
        if not isinstance(cur, dict) or part not in cur:
            return default
        cur = cur[part]
    return cur


def load(app_root: Path) -> dict:
    path = app_root / "store" / "store.json"
    if not path.is_file():
        sys.exit(f"store.json not found: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def report(errors: list[str], warnings: list[str], notes: list[str]) -> int:
    for w in warnings:
        print(f"WARN  {w}")
    for n in notes:
        print(f"NOTE  {n}")
    for e in errors:
        print(f"ERROR {e}")
    if errors:
        print(f"\n{len(errors)} error(s), {len(warnings)} warning(s) -> NOT ready to upload")
        return 1
    print(f"\nOK  0 errors, {len(warnings)} warning(s) -> ready to paste into Play Console")
    return 0


def cmd_validate(app_root: Path) -> int:
    data = load(app_root)
    errors: list[str] = []
    warnings: list[str] = []
    notes: list[str] = []

    for path in REQUIRED_PATHS:
        if dig(data, path) in (None, ""):
            errors.append(f"missing required field: {path}")

    for field, limit in LIMITS.items():
        value = dig(data, f"listing.{field}") or ""
        if value and len(value) > limit:
            errors.append(f"listing.{field} is {len(value)} chars, Play limit is {limit}")
        elif value:
            notes.append(f"listing.{field}: {len(value)}/{limit} chars")

    for loc in dig(data, "listing.localizations") or []:
        if not isinstance(loc, dict) or not loc.get("locale"):
            errors.append("listing.localizations entries need a 'locale'")
            continue
        locale = loc["locale"]
        for field, limit in LIMITS.items():
            value = loc.get(field) or ""
            if value and len(value) > limit:
                errors.append(
                    f"localization {locale}: {field} is {len(value)} chars, Play limit is {limit}")
            elif value:
                notes.append(f"localization {locale}.{field}: {len(value)}/{limit} chars")
        if not loc.get("full_description"):
            warnings.append(f"localization {locale} has no full description")

    keywords = dig(data, "listing.keywords") or []
    if not isinstance(keywords, list):
        errors.append("listing.keywords must be a list of strings")
        keywords = []
    for kw in keywords:
        if not isinstance(kw, str) or not kw.strip():
            errors.append(f"invalid keyword entry: {kw!r}")
        if kw and kw.lower() in dig(data, "listing.title", "").lower().split():
            warnings.append(f"keyword '{kw}' already present in the title (no extra reach)")
    if dig(data, "listing.title") and keywords:
        covered = [kw for kw in keywords if kw.lower() in (dig(data, "listing.title") or "").lower()]
        if len(covered) > 6:
            warnings.append(f"{len(covered)} keywords already inside a 30-char title, check redundancy")

    url_fields = ["privacy_policy_url", "terms_url", "website", "store_url"]
    for field in url_fields:
        url = dig(data, f"contact.{field}")
        if not url:
            continue
        if not str(url).startswith("https://"):
            errors.append(f"contact.{field} must be https:// (got {url})")
        if any(marker in str(url) for marker in PLACEHOLDER_MARKERS):
            errors.append(f"contact.{field} still contains a placeholder: {url}")

    assets = dig(data, "assets") or {}
    for key, expected in (("icon_512", (512, 512)), ("feature_graphic", (1024, 500))):
        rel = assets.get(key)
        if not rel:
            warnings.append(f"assets.{key} not declared")
            continue
        p = app_root / rel
        if not p.is_file():
            errors.append(f"assets.{key} missing file: {rel}")
            continue
        try:
            from PIL import Image

            with Image.open(p) as im:
                if im.size != expected:
                    errors.append(f"assets.{key} is {im.size}, expected {expected}")
                if key == "icon_512":
                    if im.mode not in ("RGB", "P"):
                        errors.append("assets.icon_512 must be opaque (RGB), Play rejects alpha")
                    if p.stat().st_size > 1024 * 1024:
                        errors.append("assets.icon_512 exceeds the 1 MB Play limit")
                else:
                    notes.append(f"assets.{key} ok")
        except ImportError:
            notes.append("Pillow not installed, skipped image dimension checks")

    for key in ("screenshots", "feature_graphics"):
        for rel in assets.get(key, []) or []:
            if not (app_root / rel).is_file():
                warnings.append(f"asset not generated yet: {rel}")

    release = dig(data, "release") or {}
    if not release.get("version_code"):
        errors.append("release.version_code must be a positive integer")
    if release.get("contains_ads") is None:
        errors.append("release.contains_ads must be answered (true/false)")
    if not release.get("data_safety"):
        errors.append("release.data_safety is required for Play Console")
    else:
        ds = release["data_safety"]
        collected = ds.get("collects") or []
        shared = ds.get("shared") or []
        if bool(collected) != bool(shared):
            errors.append("release.data_safety: if collects is empty then shared must be empty")
        notes.append(
            f"data safety: collects={collected or 'nothing'}, shared={shared or 'nothing'}"
        )
    if release.get("in_app_purchases") and not (app_root / "android" / "key.properties").exists():
        warnings.append("in_app_purchases=true but android/key.properties not found (signing not set up)")

    version = release.get("version")
    if version:
        pubspec = app_root / "pubspec.yaml"
        if pubspec.is_file():
            pub_version = None
            for line in pubspec.read_text(encoding="utf-8").splitlines():
                if line.startswith("version:"):
                    pub_version = line.split(":", 1)[1].strip()
                    break
            if pub_version and not pub_version.startswith(f"{version}+"):
                errors.append(
                    f"release.version '{version}' does not match pubspec.yaml version '{pub_version}'"
                )
            else:
                notes.append(f"pubspec version matches release.version ({pub_version})")

    return report(errors, warnings, notes)


def cmd_render(app_root: Path) -> int:
    data = load(app_root)
    app = data.get("app", {})
    listing = data.get("listing", {})
    contact = data.get("contact", {})
    assets = data.get("assets", {})
    release = data.get("release", {})

    def block(text: str) -> str:
        return (text or "").strip()

    md = f"""# Store listing — {app.get('app_name', '?')}

> Generated from `store/store.json` by `store_tool.py render`. Edit the JSON, not this file.
> Play Console field order: Store settings → Main store listing.

## Identity

| Field | Value |
|---|---|
| Package / app ID | `{app.get('package_id', '')}` |
| App name | {app.get('app_name', '')} |
| Default language | {app.get('default_locale', '')} |
| Category | {app.get('category', '')} |
| Tags | {', '.join(app.get('tags', []) or []) or '—'} |
| Content rating | {app.get('content_rating', '—')} |
| Version | `{release.get('version', '')}` ({release.get('version_code', '')}) |
| Track | {release.get('track', 'internal')} |

## Store settings

- App or game: **{'App' if not release.get('contains_ads') else 'App or game'}**
- Free app: **{'yes' if not release.get('paid', False) else 'no'}**
- Contains ads: **{'yes' if release.get('contains_ads') else 'no'}**
- In-app purchases: **{'yes' if release.get('in_app_purchases') else 'no'}**
- Government app: no · Financial features: no · Ads ID: **no** (no advertising SDK, therefore no
  `com.google.android.gms.permission.AD_ID` permission and no Data safety entry)

## Main store listing

**App name ({len(listing.get('title', ''))}/30)**

{block(listing.get('title', ''))}

**Short description ({len(listing.get('short_description', ''))}/80)**

{block(listing.get('short_description', ''))}

**Full description ({len(listing.get('full_description', ''))}/4000)**

```text
{block(listing.get('full_description', ''))}
```

**Keyword field** (Play counts keywords not already in title/description; put them all here)

{', '.join(listing.get('keywords', []) or []) or '—'}

## Contact details

| Field | Value |
|---|---|
| Email | {contact.get('email', '')} |
| Phone | {contact.get('phone', '—')} |
| Website | {contact.get('website', '—')} |
| Privacy policy URL | {contact.get('privacy_policy_url', '')} |
| Terms URL | {contact.get('terms_url', '—')} |

## Graphics

| Asset | Spec | Path |
|---|---|---|
| App icon | 512×512 PNG, opaque | `{assets.get('icon_512', 'store/assets/icon_512.png')}` |
| Feature graphic | 1024×500 PNG/JPG | `{assets.get('feature_graphic', 'store/assets/feature_graphic_1024x500.png')}` |
| Phone screenshots | 2–8, min 320 px short side | {len(assets.get('screenshots', []) or [])} declared |
| 7" / 10" tablet | optional | {len(assets.get('feature_graphics', []) or [])} declared |

{screenshot_plan(listing)}

{localizations_section(listing)}

## Data safety

```json
{json.dumps(release.get('data_safety', {}), indent=2, ensure_ascii=False)}
```

## Review notes / declarations

{block(listing.get('review_notes', '')) or '—'}
"""
    out = app_root / "store" / "store-listing.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(md, encoding="utf-8")
    print(f"wrote {out}")

    meta = app_root / "store" / "metadata" / "android"
    meta.mkdir(parents=True, exist_ok=True)
    files = {
        "title.txt": listing.get("title", ""),
        "short_description.txt": listing.get("short_description", ""),
        "full_description.txt": listing.get("full_description", ""),
    }
    for name, content in files.items():
        (meta / name).write_text(content + "\n", encoding="utf-8")
        print(f"wrote {meta / name}")
    for loc in listing.get("localizations") or []:
        locale = str(loc.get("locale") or "unknown")
        target = meta / locale
        target.mkdir(parents=True, exist_ok=True)
        loc_files = {
            "title.txt": loc.get("title", ""),
            "short_description.txt": loc.get("short_description", ""),
            "full_description.txt": loc.get("full_description", ""),
        }
        for name, content in loc_files.items():
            (target / name).write_text(str(content) + "\n", encoding="utf-8")
            print(f"wrote {target / name}")
    return 0


def screenshot_plan(listing: dict) -> str:
    plan = listing.get("screenshot_plan") or []
    if not plan:
        return ""
    lines = ["## Screenshot plan", "", "| # | Frame (bold caption) | Shows |", "|---|---|---|"]
    for i, shot in enumerate(plan, start=1):
        lines.append(f"| {i} | {shot.get('caption', '')} | {shot.get('shows', '')} |")
    return "\n".join(lines) + "\n"


def localizations_section(listing: dict) -> str:
    locs = listing.get("localizations") or []
    if not locs:
        return ""
    lines = [
        "## Localized store listings",
        "",
        "Play Console: Main store listing → each language gets its **own full budget**",
        "(30 + 80 + 4,000). A locale you do not define gets Google's machine translation,",
        "which costs conversion. Publish only the languages you actually support in-app.",
        "",
    ]
    for loc in locs:
        code = loc.get("locale", "?")
        lines += [
            f"### `{code}`",
            "",
            f"- App name ({len(loc.get('title', ''))}/30): `{loc.get('title', '')}`",
            f"- Short description ({len(loc.get('short_description', ''))}/80): "
            f"`{loc.get('short_description', '')}`",
            f"- Full description ({len(loc.get('full_description', ''))}/4000), first 170 characters:",
            "",
            "```text",
            str(loc.get("full_description", ""))[:170],
            "```",
            "",
            "```text",
            str(loc.get("full_description", "")),
            "```",
            "",
        ]
    return "\n".join(lines) + "\n"


def cmd_links(app_root: Path) -> int:
    data = load(app_root)
    urls = {}
    for key, value in (data.get("contact") or {}).items():
        if isinstance(value, str) and value.startswith("http"):
            urls[f"contact.{key}"] = value
    for key, value in (data.get("urls") or {}).items():
        urls[f"urls.{key}"] = value
    bad = 0
    for label, url in sorted(urls.items()):
        req = urllib.request.Request(url, method="HEAD", headers={"User-Agent": "store-link-check"})
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                status = resp.status
        except urllib.error.HTTPError as exc:
            status = exc.code
        except Exception as exc:  # noqa: BLE001 - report every transport failure
            print(f"ERROR {label}: {url} -> {exc}")
            bad += 1
            continue
        if status >= 400:
            print(f"ERROR {label}: {url} -> HTTP {status}")
            bad += 1
        else:
            print(f"OK    {label}: {url} -> HTTP {status}")
    return 1 if bad else 0


def _legal_block(data: dict, key: str, default):
    legal = data.get("legal") or {}
    value = legal.get(key)
    if value in (None, ""):
        return default
    return value


def _legal_list_html(items: list[str]) -> str:
    if not items:
        return ""
    return "<ul>" + "".join(f"<li>{html.escape(str(i))}</li>" for i in items) + "</ul>"


PAGE_CSS = """
:root { color-scheme: light dark; --fg: #1b1b1f; --muted: #5a5a66; --bg: #ffffff; --rule: #e4e4e9; --accent: #2563eb; }
@media (prefers-color-scheme: dark) { :root { --fg: #e6e6ea; --muted: #a0a0ac; --bg: #121216; --rule: #2a2a31; --accent: #7aa2ff; } }
* { box-sizing: border-box; }
body { margin: 0; background: var(--bg); color: var(--fg); font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
main { max-width: 720px; margin: 0 auto; padding: 40px 20px 80px; }
h1 { font-size: 1.7rem; line-height: 1.25; margin: 0 0 4px; }
h2 { font-size: 1.15rem; margin: 32px 0 8px; }
p, li { color: var(--fg); }
.meta { color: var(--muted); font-size: .9rem; margin-bottom: 28px; }
.muted { color: var(--muted); }
a { color: var(--accent); }
hr { border: 0; border-top: 1px solid var(--rule); margin: 40px 0; }
code { background: rgba(127,127,127,.14); padding: .1em .35em; border-radius: 4px; font-size: .9em; }
"""


def _page(lang: str, title: str, body: str, app_name: str) -> str:
    return f"""<!doctype html>
<html lang="{html.escape(lang)}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<style>{PAGE_CSS}</style>
</head>
<body>
<main>
{body}
<hr>
<p class="muted"><a href="./terms.html">Syarat &amp; Ketentuan</a> · <a href="./privacy.html">Kebijakan Privasi</a> · {html.escape(app_name)}</p>
</main>
</body>
</html>
"""


def cmd_web(app_root: Path) -> int:
    data = load(app_root)
    app = data.get("app", {})
    contact = data.get("contact", {})
    release = data.get("release", {})
    app_name = app.get("app_name", "Aplikasi")
    package_id = app.get("package_id", "")
    email = contact.get("email", "")
    lang = app.get("default_locale", "id") or "id"
    effective = _legal_block(data, "effective_date", "1 Januari 2026")
    offline = _legal_block(data, "offline", True)

    permissions = _legal_block(
        data,
        "permissions",
        [
            "Kamera — hanya saat Anda memfoto atau memindai dokumen, dan hanya setelah Anda mengizinkan.",
            "Galeri/Foto — hanya untuk membaca atau menyimpan gambar yang Anda pilih atau buat.",
        ]
        if offline
        else [],
    )
    data_collected = _legal_block(data, "data_collected", [])
    data_shared = _legal_block(data, "data_shared", [])

    local_note = _legal_block(
        data,
        "intro_note",
        "Semua foto dan dokumen diproses sepenuhnya di perangkat Anda. Konten tersebut "
        "tidak pernah diunggah ke server kami, karena aplikasi ini tidak memiliki server."
        if offline
        else "Konten yang Anda proses hanya digunakan untuk menjalankan fitur yang Anda minta.",
    )
    network_note = _legal_block(
        data,
        "network_note",
        "Aplikasi ini tidak meminta izin <code>INTERNET</code> untuk fungsi intinya dan dapat "
        "bekerja sepenuhnya offline."
        if offline
        else "Aplikasi dapat menggunakan koneksi internet terbatas (misalnya untuk pembelian "
        "dalam aplikasi melalui Google Play); konten foto/dokumen tidak dikirim.",
    )
    third_party = _legal_block(
        data,
        "third_parties",
        ["Pembelian dalam aplikasi, bila ada, diproses oleh Google Play. Google dapat menerima "
         "data transaksi sesuai kebijakan privasi Google."]
        if release.get("in_app_purchases")
        else ["Tidak ada SDK iklan maupun pihak ketiga yang mengumpulkan data pribadi."],
    )

    privacy_body = f"""<h1>Kebijakan Privasi {html.escape(app_name)}</h1>
<p class="meta">Berlaku sejak {html.escape(effective)}. Paket aplikasi <code>{html.escape(package_id)}</code>.</p>

<p>{html.escape(app_name)} dibuat agar bisa dipakai tanpa khawatir. {local_note}</p>

<h2>Data yang kami kumpulkan</h2>
<p>Kami <strong>tidak mengumpulkan</strong> data pribadi apa pun.</p>
{_legal_list_html(data_collected) or "<p>Tidak ada akun, login, telemetri, maupun pelacakan lokasi.</p>"}

<h2>Data yang kami bagikan</h2>
<p>Kami <strong>tidak membagikan</strong> data apa pun.</p>
{_legal_list_html(data_shared) or "<p>Tidak ada data yang dijual atau dibagikan ke pihak ketiga.</p>"}

<h2>Izin perangkat</h2>
{_legal_list_html([str(p) for p in permissions]) or "<p>Aplikasi hanya meminta izin yang benar-benar diperlukan.</p>"}

<h2>Penyimpanan</h2>
<p>Pengaturan dan riwayat disimpan secara lokal di perangkat Anda. Menghapus data aplikasi atau menghapus instalasi akan menghapus data tersebut. {network_note}</p>

<h2>Pihak ketiga</h2>
{_legal_list_html([str(t) for t in third_party])}

<h2>Anak-anak</h2>
<p>Aplikasi ini tidak diarahkan kepada anak di bawah 13 tahun dan tidak mengumpulkan data dari mereka.</p>

<h2>Perubahan</h2>
<p>Kebijakan ini dapat diperbarui. Perubahan penting akan ditandai dengan tanggal berlaku yang baru.</p>

<h2>Kontak</h2>
<p>Pertanyaan tentang privasi: <a href="mailto:{html.escape(email)}">{html.escape(email)}</a>.</p>
"""

    terms_body = f"""<h1>Syarat &amp; Ketentuan {html.escape(app_name)}</h1>
<p class="meta">Berlaku sejak {html.escape(effective)}. Paket aplikasi <code>{html.escape(package_id)}</code>.</p>

<p>Dengan mengunduh atau menggunakan {html.escape(app_name)}, Anda menyetujui syarat berikut.</p>

<h2>1. Lisensi penggunaan</h2>
<p>Anda diberi lisensi pribadi, non-eksklusif, dan tidak dapat dialihkan untuk memakai aplikasi ini sesuai aturannya. Anda tidak boleh menjual ulang, mendekompilasi, atau menyalahgunakan aplikasi.</p>

<h2>2. Konten Anda</h2>
<p>Anda memiliki seluruh hak atas foto dan dokumen yang Anda proses. Anda bertanggung jawab memastikan bahwa Anda berhak menggunakan dan menyimpan konten tersebut.</p>

<h2>3. Hasil dan batasan</h2>
<p>Aplikasi menyediakan alat bantu. Kami berusaha sebaik mungkin, tetapi tidak menjamin hasil selalu bebas kesalahan. Selalu periksa hasil sebelum mengirimkannya ke pihak ketiga.</p>

<h2>4. Tanpa jaminan</h2>
<p>Aplikasi disediakan &quot;sebagaimana adanya&quot; tanpa jaminan tersurat maupun tersirat, termasuk jaminan kelayakan untuk tujuan tertentu.</p>

<h2>5. Batasan tanggung jawab</h2>
<p>Sejauh diizinkan hukum, kami tidak bertanggung jawab atas kerugian tidak langsung, insidental, atau konsekuensial yang timbul dari penggunaan aplikasi ini.</p>

<h2>6. Perubahan</h2>
<p>Kami dapat memperbarui syarat ini. Versi yang berlaku adalah yang ditampilkan di halaman ini.</p>

<h2>7. Kontak</h2>
<p>Pertanyaan tentang syarat ini: <a href="mailto:{html.escape(email)}">{html.escape(email)}</a>.</p>
"""

    out_dir = app_root / "store" / "web"
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "privacy.html").write_text(
        _page(lang, f"Kebijakan Privasi — {app_name}", privacy_body, app_name), encoding="utf-8"
    )
    (out_dir / "terms.html").write_text(
        _page(lang, f"Syarat & Ketentuan — {app_name}", terms_body, app_name), encoding="utf-8"
    )
    print(f"wrote {out_dir / 'privacy.html'}")
    print(f"wrote {out_dir / 'terms.html'}")
    print("host these two files at the privacy_policy_url / terms_url in store.json")
    return 0


def cmd_init(app_root: Path) -> int:
    config = (app_root / "lib" / "app_config.dart").read_text(encoding="utf-8")
    scaffold = {
        "schema": 1,
        "app": {
            "package_id": "REPLACE_ME",
            "app_name": "REPLACE_ME",
            "default_locale": "id",
            "category": "REPLACE_ME",
            "tags": [],
            "content_rating": "",
        },
        "listing": {
            "title": "REPLACE_ME",
            "short_description": "REPLACE_ME",
            "full_description": "REPLACE_ME",
            "keywords": [],
            "screenshot_plan": [],
            "review_notes": "",
        },
        "contact": {
            "email": "REPLACE_ME",
            "phone": "",
            "website": "",
            "privacy_policy_url": "https://REPLACE_ME/privacy",
            "terms_url": "",
        },
        "assets": {
            "icon_512": "store/assets/icon_512.png",
            "feature_graphic": "store/assets/feature_graphic_1024x500.png",
            "screenshots": [],
            "feature_graphics": [],
        },
        "release": {
            "version": "REPLACE_ME",
            "version_code": 1,
            "track": "internal",
            "paid": False,
            "contains_ads": False,
            "in_app_purchases": False,
            "data_safety": {"collects": [], "shared": [], "encrypted_in_transit": None},
        },
        "_source": f"values below must be reconciled with {app_root}/lib/app_config.dart",
        "_app_config_keys_present": [line.strip() for line in config.splitlines() if "Config(" in line],
    }
    path = app_root / "store" / "store.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(scaffold, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"scaffolded {path}")
    return 0


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("command", choices=["validate", "render", "links", "web", "init"])
    ap.add_argument("app_root")
    args = ap.parse_args()
    app_root = Path(args.app_root).resolve()
    handlers = {
        "validate": cmd_validate,
        "render": cmd_render,
        "links": cmd_links,
        "web": cmd_web,
        "init": cmd_init,
    }
    sys.exit(handlers[args.command](app_root))


if __name__ == "__main__":
    main()