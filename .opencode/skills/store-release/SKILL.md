---
name: store-release
description: Use when preparing a Flutter/Android app for Google Play upload or store submission - audits release readiness, researches Play Store ASO keywords and writes the app title, short description, full description and keyword field, manages the store listing (store.json), generates the launcher icon and Play graphics, sets up release signing, and writes the upload checklist. Trigger words "siap upload", "upload Play Store", "store listing", "judul dan deskripsi app", "ASO", "riset keyword", "launcher icon", "generate ikon", "keystore signing", "audit rilis", "app bundle", "AAB", "privacy policy".
---

# store-release

Repeatable pipeline that takes a Flutter Android app from "works on my phone" to "uploadable on
Google Play", and produces the artefacts that stay useful after the release (research, listing
source of truth, icon generator, audit script).

**This skill never invents brand facts.** App name, package id, colours, slogan, support email and
the app description come from the app's own config. Research fills gaps; the config stays the
authority.

## Scripts

All scripts live next to this file; run them from anywhere with absolute paths.

| Script | Purpose |
|---|---|
| `scripts/audit.sh <app-root> [--fast] [--online]` | Preflight audit. Exits 1 on any FAIL. Run first, run last. |
| `scripts/setup_signing.sh <app-root> [--keys-dir <dir>]` | Interactive: generates the upload keystore outside the repo + writes `android/key.properties`, and appends the git-ignore rules. Passwords are prompted for, never passed as arguments. |
| `scripts/store_tool.py init <app-root>` | Scaffold `store/store.json` from the app config |
| `scripts/store_tool.py validate <app-root>` | Validate store.json against Play limits and asset specs |
| `scripts/store_tool.py render <app-root>` | Render `store/store-listing.md` + `store/metadata/android/*.txt` |
| `scripts/store_tool.py links <app-root>` | HTTP-check every URL in store.json (privacy policy must resolve) |
| `scripts/store_tool.py web <app-root>` | Generate `store/web/privacy.html` + `terms.html` from store.json |
| `scripts/generate_icons.py <app-root>` | brand.json → launcher icons (all densities + adaptive) + Play 512 icon + 1024×500 feature graphic |

Requirements: `flutter`, `python3`, `Pillow` (`python3 -m pip install Pillow`).

## Output layout (created next to the app, so it travels with the repo)

```
<app-root>/
  store/
    brand.json            # colours + monogram, input for generate_icons.py
    store.json            # source of truth for the listing, data safety, release flags
    store-listing.md      # rendered, copy-paste into Play Console
    keyword-research.md   # research log: queries, competitors, scored keywords
    upload-checklist.md   # ordered manual steps for Play Console + phone testing
    metadata/android/*.txt# fastlane-compatible title/short/full description
    assets/               # icon_512.png, feature_graphic_1024x500.png, screenshots/
    web/privacy.html      # ready-to-host legal pages
    web/terms.html
```

## Workflow

### 1. Identify the app and its config

Find every Flutter app root in the workspace (`pubspec.yaml`). For each target, read the identity
sources in this order:

1. `lib/app_config.dart` (or equivalent) — `BrandConfig`, `ThemeConfig`, `ContentConfig`
2. `android/app/src/main/AndroidManifest.xml` — `android:label`, permissions
3. `android/app/build.gradle.kts` — `applicationId`, sdk levels
4. `pubspec.yaml` — name, version, dependencies (a dependency list tells you whether ads, IAP,
   analytics or an HTTP client exist — this determines the Data safety answer)

If the app uses a config-first framework, respect it: change the config, never hardcode in widgets.

### 2. Run the audit before touching anything

```bash
bash scripts/audit.sh <app-root> --fast
```

Read every FAIL and WARN. The audit already knows the Play gates (see
`references/play-requirements.md`). Typical blockers: debug-key signing, missing `INTERNET` for
Play Billing, dead privacy policy URL, placeholder URLs in config, `targetSdk` below the current
Play minimum, default Flutter launcher icon, `versionCode` not increasing.

### 3. Resolve posture decisions with the user — ask at most two questions

Two decisions cannot be inferred and are irreversible once shipped:

1. **Monetisation vs offline purity.** Play Billing needs `android.permission.INTERNET`. If the app
   markets itself as offline, ship without a paywall for the first release (recommended), or add
   the permission and document it precisely in the privacy policy.

   Do not trust the source manifest on this. `in_app_purchase_android` (via
   `com.android.billingclient:billing` → `transport-backend-cct`) merges `INTERNET`,
   `ACCESS_NETWORK_STATE` and `BILLING` into the release manifest automatically, so any app with IAP
   in its dependency tree ships with INTERNET whether the author wrote it or not. Check the merged
   artifact:

   ```bash
   cd <app-root>/android && ./gradlew :app:processReleaseManifest
   grep uses-permission ../build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml
   ```

   To keep the offline claim literally true **without** removing the dependency, add
   `<uses-permission android:name="…" tools:node="remove"/>` (with `xmlns:tools` on `<manifest>`) to
   the app's main manifest for `INTERNET`, `ACCESS_NETWORK_STATE` and `com.android.vending.BILLING`,
   and leave `AppConfig.productIds` empty so no `BillingClient` is created. Re-run the merged-manifest
   check to confirm all three are gone. The heavier alternative is to drop `in_app_purchase` from the
   release build entirely. If INTERNET remains, either drop "100% offline" from the listing or
   justify the permission in the privacy policy.
2. **Where the privacy policy is hosted.** The URL must resolve. If the user's domain does not
   resolve, produce placeholder URLs plus a hosting checklist — never ship a guess.

Everything else: decide, implement, and record the decision in `store/upload-checklist.md`.

### 4. Fix the native build

Apply `references/native-release-setup.md`. Run the interactive signing helper first — it prompts for
the passwords itself, so no credential ever passes through the agent:

```bash
bash scripts/setup_signing.sh <app-root>
```

Then apply the `build.gradle.kts` signing block, R8 with `proguard-rules.pro`, manifest hygiene, and
`version: x.y.z+N` in `pubspec.yaml`. Keep secrets outside the repo; keep `key.properties` and `*.jks`
git-ignored.

### 5. Research before writing copy

Follow `references/aso-playbook.md`. Use `websearch` to harvest the query space and the competitor
snapshot; do not guess keyword volumes. Write `store/keyword-research.md` with the query set,
competitor snapshot, scored keyword table, chosen title, and the rejected terms with reasons.

### 6. Write the listing

Fill `store/store.json` (scaffold with `store_tool.py init`). Rules:

- Title ≤ 30 chars, head keyword first, no brand-name-only titles.
- Short description ≤ 80 chars, the promise in the user's own words.
- Full description ≤ 4000 chars: opener with keywords in the first 170 chars, 5–7 benefit-led
  features, "good for" section, concrete privacy statement, 4–6 real FAQs, support email.
- `keywords`: only terms absent from title and description.
- `release.data_safety` must follow the dependency tree. A local-only tool collects nothing.

Then:

```bash
python3 scripts/store_tool.py validate <app-root>   # must print OK
python3 scripts/store_tool.py render   <app-root>
python3 scripts/store_tool.py links    <app-root>   # privacy policy must return HTTP 2xx
```

### 7. Generate icons and store graphics

Write `store/brand.json` from the app theme colours, pick a 1–3 character monogram, then:

```bash
python3 scripts/generate_icons.py <app-root>
```

Details and the safe-zone rules in `references/icons.md`.

### 8. Legal pages

```bash
python3 scripts/store_tool.py web <app-root>
```

This writes `store/web/privacy.html` and `store/web/terms.html` describing what the app actually does
(permissions, on-device processing, no accounts, email contact, last-updated date). Override the
generated wording per app with a `legal` object in `store.json` (`effective_date`, `offline`,
`permissions`, `data_collected`, `data_shared`, `third_parties`). Host the two files, point
`BrandConfig.privacyPolicyUrl` / `termsUrl` at the hosted copies, mirror the exact URL in
`store.json → contact`, then run `store_tool.py links` after deploying.

### 9. Screenshots

The user captures real UI (or drives the app to capture it) into `store/assets/screenshots/phone/`,
2–8 files, and lists them in `store.json`. Provide the shot list from `store-listing.md`
`screenshot_plan`; do not fabricate screenshots.

### 10. Verify and hand off

```bash
bash scripts/audit.sh <app-root>        # 0 FAIL
cd <app-root> && flutter analyze && flutter test
flutter build appbundle --release
```

Finish with `store/upload-checklist.md`: the exact Play Console fields to paste, the manual console
steps (account verification, 12-tester closed test for new personal accounts, pricing, IAP products,
data safety, staged rollout), and the phone tests to run on the release build before rollout.

## Non-negotiables

- Never commit `key.properties`, `*.jks`, or any credential.
- Never leave a placeholder URL in shipped code — the audit fails the build on purpose.
- Never claim offline while holding `INTERNET`, and never declare "no data collected" while the app
  transmits anything.
- Never fabricate keyword volumes or competitor statistics. Mark estimates as estimates.
- Never upload or commit anything unless the user explicitly asks.
- `flutter analyze` and `flutter test` must be clean before calling any app release-ready.