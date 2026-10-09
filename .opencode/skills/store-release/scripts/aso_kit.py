#!/usr/bin/env python3
"""ASO test kit: token audit + Play listing mock + conversion smoke-test harness.

Usage:
    python3 aso_kit.py <app-root>

Reads <app-root>/store/store.json and writes:
    <app-root>/store/aso-test/keyword-token-audit.md
    <app-root>/store/aso-test/listing-preview.html
    <app-root>/store/aso-test/cvr-smoke-test.html

Why the token audit exists: Google Play indexes the app name (30), the short
description (80), the full description (4,000) and the developer name. Play has
no comma-separated keyword field, so every term you want to rank for must occur
as a token in one of those places. This script reports, per research term, which
tokens are still missing so they can be placed in real sentences.

Listing preview mimics the three surfaces that decide conversion: the search
result card (icon + title + rating only), the listing header, and the phone
screenshot strip where only the first 2-3 screenshots are ever seen.

The smoke-test harness is a 5-second exposure followed by a short questionnaire.
Conversion rate, not keyword rank, is the lever a small app controls most, and it
can be measured with 20 people long before a Store Listing Experiment is eligible.
"""

from __future__ import annotations

import argparse
import html
import json
import re
import sys
from pathlib import Path

LIMITS = {"title": 30, "short_description": 80, "full_description": 4000}
WORD = re.compile(r"[a-z0-9]+")


def indexed_text(listing: dict) -> str:
    return " ".join([
        listing.get("title", ""),
        listing.get("short_description", ""),
        listing.get("full_description", ""),
    ]).lower()


def token_audit(store: dict) -> str:
    listing = store.get("listing", {})
    terms = listing.get("keywords") or []
    indexed = indexed_text(listing)
    out = [
        "# Token audit — research terms vs. what Play can actually index",
        "",
        "Play indexes app name + short description + full description + developer name.",
        "It has **no keyword field**: a term absent from those texts cannot rank at all.",
        "Play matches word by word, so a phrase needs every one of its tokens present",
        "somewhere in the indexed text — not necessarily adjacent.",
        "",
        "| Research term | Tokens | Missing | Verdict |",
        "|---|---|---|---|",
    ]
    work = []
    for term in terms:
        tokens = [t for t in WORD.findall(str(term).lower()) if t]
        missing = [t for t in tokens if t not in indexed]
        if not tokens:
            verdict = "no tokens"
        elif not missing:
            verdict = "covered"
        elif len(missing) == len(tokens):
            verdict = "**NOT INDEXABLE — place it in the copy**"
            work.append((term, missing))
        else:
            verdict = "partially covered"
            work.append((term, missing))
        cells = ", ".join(f"`{m}`" for m in missing) or "—"
        out.append(f"| `{term}` | {' '.join(tokens)} | {cells} | {verdict} |")
    out += ["", "## Work list: tokens still missing from the indexed text", ""]
    out += ([f"- `{term}` → {', '.join(missing)}" for term, missing in work]
            or ["- Nothing. Every research token already occurs in the indexed text."])
    out.append("")
    for loc in listing.get("localizations") or []:
        loc_text = " ".join([
            loc.get("title", ""), loc.get("short_description", ""), loc.get("full_description", ""),
        ]).lower()
        gaps = []
        for term in loc.get("keywords") or terms:
            missing = [t for t in WORD.findall(str(term).lower()) if t and t not in loc_text]
            if missing:
                gaps.append(f"`{term}` → {', '.join(missing)}")
        out += [
            f"### Locale `{loc.get('locale')}`",
            "",
            f"- budget: title {len(loc.get('title', ''))}/{LIMITS['title']}, "
            f"short {len(loc.get('short_description', ''))}/{LIMITS['short_description']}, "
            f"full {len(loc.get('full_description', ''))}/{LIMITS['full_description']}",
            "- tokens absent from this locale:",
        ]
        out += [f"  - {g}" for g in gaps] or ["  - none, every research token is present"]
        out.append("")
    return "\n".join(out) + "\n"


def shots_of(store: dict) -> list[str]:
    listing, assets = store.get("listing", {}), store.get("assets", {})
    shots = assets.get("screenshots") or [p.get("file") for p in listing.get("screenshot_plan") or []]
    return [str(s) for s in shots if s]


def rel_to_aso(shot: str) -> str:
    if shot.startswith("../"):
        return shot
    if "/" in shot:
        return f"../{shot.replace('store/', '')}"
    return f"../assets/screenshots/phone/{shot}"


def listing_html(store: dict) -> str:
    listing, assets, app = store.get("listing", {}), store.get("assets", {}), store.get("app", {})
    icon = rel_to_aso(str(assets.get("icon_512") or "assets/icon_512.png"))
    feature = rel_to_aso(str(assets.get("feature_graphic") or "assets/feature_graphic_1024x500.png"))
    plan = listing.get("screenshot_plan") or []
    strip = ""
    for i, shot in enumerate(shots_of(store)):
        cap = plan[i].get("caption", "") if i < len(plan) else ""
        strip += (f'<figure class="shot"><img src="{html.escape(rel_to_aso(shot))}" '
                  f'alt="{html.escape(cap)}"><figcaption>{i + 1}. {html.escape(cap)}</figcaption>'
                  '</figure>')
    if not strip:
        strip = ('<figure class="shot"><div class="ph">NO SCREENSHOT — Play requires 2–8 '
                 'phone screenshots.<br>Top conversion blocker.</div></figure>')
    locs = ""
    for loc in listing.get("localizations") or []:
        locs += (f'<section class="loc"><h3>{html.escape(str(loc.get("locale", "")))}</h3>'
                 f'<p class="t">{html.escape(loc.get("title", ""))} '
                 f'<small>({len(loc.get("title", ""))}/30)</small></p>'
                 f'<p class="s">{html.escape(loc.get("short_description", ""))} '
                 f'<small>({len(loc.get("short_description", ""))}/80)</small></p></section>')
    return f"""<!doctype html>
<html lang="id"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Listing preview — {html.escape(str(app.get('app_name', '')))}</title>
<style>
 body {{ font:14px/1.5 Roboto,system-ui,sans-serif; margin:0; background:#f1f3f4; color:#202124; }}
 h1 {{ font-size:18px; margin:24px 16px 8px; }}
 h2 {{ font-size:13px; text-transform:uppercase; letter-spacing:.08em; color:#5f6368;
      margin:30px 16px 8px; }}
 .wrap {{ max-width:1100px; margin:0 auto; padding:0 16px 64px; }}
 .card {{ background:#fff; border-radius:12px; padding:14px; margin-bottom:10px; display:flex; gap:14px; }}
 .card img {{ width:64px; height:64px; border-radius:16px; }}
 .meta {{ flex:1; min-width:0; }}
 .meta .t {{ font-size:15px; font-weight:500; margin:0 0 2px; }}
 .meta .s, .meta .r, .loc .s {{ color:#5f6368; font-size:12px; margin:0; }}
 .meta .r {{ margin-top:4px; }}
 .phone {{ width:360px; margin:0 auto; background:#fff; border-radius:24px; overflow:hidden;
           box-shadow:0 1px 3px rgba(0,0,0,.2); }}
 .hero {{ display:flex; gap:16px; padding:16px; align-items:center; }}
 .hero img {{ width:80px; height:80px; border-radius:20px; }}
 .hero .t {{ font-size:18px; margin:0; }}
 .hero .s {{ color:#5f6368; font-size:13px; margin:4px 0 0; }}
 .strip {{ display:flex; gap:8px; overflow-x:auto; padding:0 16px 16px; }}
 .shot {{ margin:0; flex:0 0 130px; }}
 .shot img, .ph {{ width:130px; height:230px; border-radius:8px; object-fit:cover;
                   background:#e8eaed; border:1px dashed #bdc1c6; display:grid; place-items:center;
                   text-align:center; font-size:11px; color:#5f6368; padding:8px; }}
 figcaption {{ font-size:11px; color:#5f6368; margin-top:4px; }}
 .feature {{ width:100%; border-radius:8px; margin-top:12px; }}
 .note {{ background:#fff8e1; border-left:4px solid #fbbc04; padding:10px 12px; margin:12px 0;
          font-size:13px; border-radius:0 8px 8px 0; }}
 table {{ border-collapse:collapse; width:100%; background:#fff; border-radius:12px; overflow:hidden; }}
 td,th {{ text-align:left; padding:8px 12px; border-bottom:1px solid #e8eaed; font-size:13px; }}
 .loc {{ background:#fff; border-radius:12px; padding:12px; margin-bottom:8px; }}
 .loc h3 {{ margin:0 0 6px; font-size:12px; color:#5f6368; }}
 .loc .t {{ font-weight:500; margin:0; }}
 .loc .s {{ margin:2px 0 0; }}
 small {{ color:#80868b; }}
</style></head><body><div class="wrap">
<h1>Play listing preview — {html.escape(str(app.get('app_name', '')))}</h1>
<div class="note">Mock, not Play. It approximates the surfaces that decide conversion: the
search card, the listing header, and the phone strip where only the first 2–3 screenshots are
ever seen. Check it against your own internal-test listing before shipping.</div>

<h2>1. Search result card</h2>
<div class="card"><img src="{html.escape(icon)}" alt="icon"><div class="meta">
<p class="t">{html.escape(str(listing.get('title', '')))}</p>
<p class="s">{html.escape(str(app.get('app_name', '')))}</p>
<p class="r">★ new app — no rating yet. Your rating reads 0 until the first review lands.</p>
</div></div>

<h2>2. Listing header + screenshot strip</h2>
<div class="phone"><div class="hero"><img src="{html.escape(icon)}" alt="icon"><div>
<p class="t">{html.escape(str(listing.get('title', '')))}</p>
<p class="s">{html.escape(str(listing.get('short_description', '')))}</p></div></div>
<div class="strip">{strip}</div>
<img class="feature" src="{html.escape(feature)}" alt="feature graphic"></div>

<h2>3. Field budgets</h2>
<table><tr><th>Field</th><th>Used</th><th>Play limit</th><th>Indexed by search</th></tr>
<tr><td>App name</td><td>{len(str(listing.get('title', '')))}</td><td>30</td><td>yes, heaviest</td></tr>
<tr><td>Short description</td><td>{len(str(listing.get('short_description', '')))}</td><td>80</td><td>yes</td></tr>
<tr><td>Full description</td><td>{len(str(listing.get('full_description', '')))}</td><td>4000</td><td>yes</td></tr>
<tr><td>Keyword field</td><td>—</td><td>does not exist on Play</td><td>n/a</td></tr></table>
{('<h2>4. Other locales</h2>' + locs) if locs else ''}
</div></body></html>
"""


def smoke_html(store: dict) -> str:
    assets = store.get("assets", {})
    icon = rel_to_aso(str(assets.get("icon_512") or "assets/icon_512.png"))
    opts = ['<option value="">— icon only, no screenshot —</option>']
    for shot in shots_of(store):
        opts.append(f'<option value="{html.escape(rel_to_aso(shot))}">'
                    f'{html.escape(Path(shot).name)}</option>')
    return f"""<!doctype html>
<html lang="id"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Smoke test konversi — 5 detik</title>
<style>
 body {{ font:15px/1.55 system-ui,sans-serif; margin:0; background:#111; color:#eee; }}
 .t {{ position:fixed; top:8px; right:12px; font-variant-numeric:tabular-nums; color:#8ab4f8; }}
 .p {{ max-width:430px; margin:0 auto; padding:20px; }}
 .e {{ display:none; min-height:100vh; display:none; align-items:center; justify-content:center;
       flex-direction:column; gap:14px; }}
 .e img {{ max-width:100%; max-height:64vh; object-fit:contain; }}
 .big {{ font-size:26px; font-weight:700; }}
 label {{ display:block; text-align:left; margin:14px 0 4px; font-size:14px; }}
 select,textarea,input,button {{ width:100%; font:inherit; padding:10px; border-radius:8px;
   border:1px solid #444; background:#1c1c1c; color:#eee; box-sizing:border-box; }}
 button {{ margin-top:16px; background:#1a73e8; border:0; font-weight:600; }}
 button.ghost {{ background:#2f2f2f; margin-top:8px; }}
 p.hint {{ font-size:13px; color:#aaa; }}
 h2 {{ font-size:17px; }}
</style></head><body>
<div class="t" id="t"></div>

<div class="p" id="setup">
<h2>Smoke test konversi — 5 detik</h2>
<p class="hint">Peserta <b>tidak boleh</b> melihat nama app, developer, harga, atau rating. Tampilkan
hanya ikon + screenshot pertama, lalu 5 detik. Pertanyaan 1 ("untuk apa app ini?") adalah tes
komprehensi: kalau banyak yang salah jawab, listingmu belum menjelaskan fungsinya, dan itu masalah
copy bukan masalah traffic.</p>
<label>Icon (boleh ganti untuk A/B)</label>
<input type="file" id="ic" accept="image/*">
<label>Screenshot pertama</label>
<select id="sh">{''.join(opts)}</select>
<label>Nama peserta (opsional)</label>
<input id="nm">
<button id="go">Mulai — tampil 5 detik</button>
<button class="ghost" id="dl">Unduh hasil (CSV)</button>
<button class="ghost" id="rs">Reset</button>
</div>

<div class="e" id="exp"><img id="bi" src="{html.escape(icon)}" alt=""><img id="bs" alt=""></div>

<div class="p" id="ask" style="display:none">
<h2>5 detik habis. Jawaban jujur saja.</h2>
<label>1. Menurutmu app ini untuk apa?</label><input id="q1">
<label>2. Kalau app ini gratis, kamu install sekarang?</label>
<select id="q2"><option value="">pilih</option><option>ya, sekarang</option>
<option>mungkin nanti</option><option>kemungkinan besar tidak</option><option>tidak sama sekali</option></select>
<label>3. Apa yang membuatnya menarik?</label><input id="q3">
<label>4. Apa yang membuatnya tidak menarik?</label><input id="q4">
<label>5. Saran lain</label><input id="q5">
<button id="save">Simpan jawaban</button>
</div>

<script>
const KEY='exif_viewer_cvr', $=(id)=>document.getElementById(id);
let icData=null, timer=null;
const rows=()=>JSON.parse(localStorage.getItem(KEY)||'[]');
const save=(r)=>{{localStorage.setItem(KEY,JSON.stringify([...rows(),r]));}};
$('go').onclick=()=>{{
  const f=$('ic').files[0];
  if(f){{const rd=new FileReader();rd.onload=()=>{{icData=rd.result;start();}};rd.readAsDataURL(f);}}
  else start();
}};
function start(){{
  $('setup').style.display='none'; $('exp').style.display='flex';
  if(icData) $('bi').src=icData;
  const sh=$('sh').value;
  $('bs').style.display=sh?'block':'none'; if(sh) $('bs').src=sh;
  let left=5; $('t').textContent=left.toFixed(1);
  timer=setInterval(()=>{{
    left-=0.1; $('t').textContent=Math.max(0,left).toFixed(1);
    if(left<=0){{clearInterval(timer); $('exp').style.display='none';
      $('ask').style.display='block';}}
  }},100);
}}
$('save').onclick=()=>{{
  save({{who:$('nm').value,q1:$('q1').value,q2:$('q2').value,q3:$('q3').value,
    q4:$('q4').value,q5:$('q5').value,icon:icData?'upload':'store',
    shot:$('sh').value.split('/').pop(),at:new Date().toISOString()}});
  ['q1','q2','q3','q4','q5','nm'].forEach(i=>$(i).value='');
  $('ask').style.display='none'; $('setup').style.display='block';
}};
$('dl').onclick=()=>{{
  const keys=['who','q1','q2','q3','q4','q5','icon','shot','at'];
  const csv=[keys.join(','),...rows().map(r=>keys.map(k=>`"${{String(r[k]??'').replace(/"/g,'""')}}"`).join(','))].join('\\n');
  const a=document.createElement('a');
  a.href=URL.createObjectURL(new Blob([csv],{{type:'text/csv'}}));
  a.download='cvr-smoke-test.csv'; a.click();
}};
$('rs').onclick=()=>{{if(confirm('Hapus semua jawaban tersimpan?')) localStorage.removeItem(KEY);}};
</script></body></html>
"""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("app_root", type=Path)
    args = ap.parse_args()
    store_path = args.app_root / "store" / "store.json"
    if not store_path.is_file():
        print(f"missing {store_path}", file=sys.stderr)
        return 1
    store = json.loads(store_path.read_text(encoding="utf-8"))
    out = args.app_root / "store" / "aso-test"
    out.mkdir(parents=True, exist_ok=True)
    (out / "keyword-token-audit.md").write_text(token_audit(store), encoding="utf-8")
    (out / "listing-preview.html").write_text(listing_html(store), encoding="utf-8")
    (out / "cvr-smoke-test.html").write_text(smoke_html(store), encoding="utf-8")
    print(f"wrote {out}/keyword-token-audit.md")
    print(f"wrote {out}/listing-preview.html")
    print(f"wrote {out}/cvr-smoke-test.html")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())