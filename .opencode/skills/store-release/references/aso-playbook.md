# ASO playbook for Google Play (Indonesian long-tail market)

The goal is not "top charts". These apps are **single-job utilities with low trigger frequency**
(pas foto saat mendaftar kerja, hitung cat saat renovasi). The realistic win is: appear on page 1–2
of a specific high-intent query, get an install, survive the first session, get 5 stars.

## Research procedure (do this before writing a single character of copy)

1. **List the query the user would actually type.** Job-to-be-done phrasing, in the user's words, in
   Indonesian slang — not the internal feature name. "pas foto 3x4", not "ID photo generator".
2. **Look at what already ranks.** `websearch` for `"<query>" aplikasi Play Store` and open the top
   results. Record: their title (≤30 chars), installs, rating, review count, first 3 features in
   their description, whether they are offline, whether they have ads.
3. **Extract the phrasing from competitor copy, not from your feature list.** Competitor titles
   already encode the query space; harvest the nouns.
4. **Check Play's own autocomplete.** Type the head term into the Play search bar. The suggestions
   are the real query variants and are the highest-value source.
5. **Cross-check with web volume tools** if available (Google Keyword Planner, AppTweak, SensorTower).
   Web volume is a proxy, not Play volume; Play volumes are typically 5–20% of web volumes. Treat any
   number as an order of magnitude.
6. **Score each keyword** before using it:
   - `intent` (1–3): does this query mean "I want to do this task now"?
   - `reach` (1–3): does the ranking page show it, or only big players?
   - `fit` (1–3): does the app genuinely do this job?
   Use it only if `intent × reach × fit ≥ 12`. That filter is what keeps the keyword field from
   filling with vanity terms.
7. **Write `store/keyword-research.md`** with: the query set, the top 5 competitors and their
   install/rating snapshot, the scored keyword table, the chosen title, and the rejected terms with
   the reason. Future updates read this file instead of re-researching from scratch.

## Play-specific mechanics

- Play **indexes the app name (30), the short description (80), the full description (4,000), and
  the developer name**. It does not index the category, the tags, or the privacy policy.
- **Play has no keyword field.** There is no comma-separated box in Play Console, no character
  budget for it, and no "terms not in your title" trick — that is iOS. A Play keyword strategy is
  therefore a *sentence* strategy: every term you want to rank for has to appear in the name, the
  short description or the full description. Treat `store.json → listing.keywords` as a research
  log and a checklist for what must appear in the copy, never as a field to paste into the console.
- Play does **not** penalise keyword repetition between title, short description and full
  description the way the App Store does — repeat the head term in title + short description.
- Two thirds of the free-description budget is usually unused: 4,000 characters is the ceiling, not
  a quota, but unused budget on a long-tail utility is wasted ranking surface. Google still asks
  for natural language, not a comma list, so expand with real sentences that answer questions.
- Every language you publish gets its **own full budget** (30 + 80 + 4,000). If you only define one
  language, Google machine-translates the rest, and machine-translated copy costs you conversion.
  Define the languages you actually support, per language.
- Ranking depends heavily on **conversion rate** (icon + title + first screenshot) and on **retention
  signals** from Play Store listing performance. Rating velocity matters more than rating value.
- Reviews: reply in the same language, within the first week, and answer the 1-star ones with a fix
  commitment, not an apology.

## Title formula (30 chars)

```
<Head keyword> <secondary keyword> <differentiator>
```

Differentiators worth spending characters on: `Offline`, `Tanpa Iklan`, `Gratis`, `Kecil`,
`100KB`, `100% Gratis`, `Praktis`. Avoid: brand name alone, emoji, `App`, `2024`, competitor names.

## Short description formula (80 chars)

Restate the single job + the strongest differentiator. Write it as the promise, not as a feature list.
Emoji cost 2–4 characters each and count against the limit — spend them only if the category
routinely uses them.

## Full description formula (4000 chars)

```
1. One-paragraph opener with the job and the keywords the user would search (first 170 chars are
   visible before "more" — the SEO surface that matters most).
2. Feature list, 5–7 items, each starting with a bold keyword, phrased as user benefit.
3. "Cocok untuk" section: list the concrete situations and target sites (CPNS,FuerDinas, kampus).
4. Privacy/offline statement, concrete and verifiable.
5. FAQ: 4–6 real questions with real answers.
6. Close with the support email, not a sales pitch.
```

Do not keyword-stuff the description into unreadability; Play's own quality signals penalise
listings that read as spam, and the human reviewer reads it too.

## Long-tail naming for Indonesia (observed ranking patterns)

- Pas foto: the size *is* the keyword. `3x4`, `4x6`, `2x3`, `300 DPI`, `latar biru`, `latar merah`,
  `KTP`, `SIM`, `ijazah`, `pas foto gratis`, `pas foto online` (users search this even when the app
  is offline — answer it in the description).
- Background colour matters to users and is almost never in competitor titles: include it in the
  description.
- Construction: users search the *task*, not the tool. `hitung cat`, `cat butuh berapa liter`,
  `berapa keramik`, `cor dak butuh semen berapa`, `luas cat 3x4`, `biaya bangun rumah`,
  `kalkulator RAB` is the minority phrasing — lead with the task words and keep "RAB" as a
  secondary term.
- Language style: informal Indonesian (`butuh`, `berapa`, `hitung`), not technical (`dimensi`,
`koefisien`, `volume`). Check the app's own copy matches the query style.

## Competitive reality (Indonesia, 2026)

Pas foto is a crowded, ad-heavy category with strong incumbents; the differentiator that survives
review is **offline + no ads + Indonesian presets + local pricing**. Construction/RAB is less
crowded but has AI-wrapped competitors and incumbent apps with 10+ calculators; do not compete on
feature count. In both cases the defensible edge is: correct localised presets, transparent
calculations, works without signal.