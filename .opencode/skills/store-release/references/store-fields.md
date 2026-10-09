# Play Console field reference (where every value comes from)

`store/store.json` is the single source of truth. Render it with
`python3 scripts/store_tool.py render <app-root>` to get `store/store-listing.md` and
`store/metadata/android/*.txt` (fastlane-compatible layout), then paste into Play Console manually.

## Field limits

| Play Console field | Limit | Enforced by `store_tool.py validate` |
|---|---|---|
| App name (title) | **30 characters** | yes |
| Short description | **80 characters** | yes |
| Full description | **4000 characters** | yes |
| Keyword field | single comma/space-separated line, counted with title + description | warns on redundancy only |
| App icon | 512×512 PNG 32-bit, ≤1 MB, no alpha | yes (dimensions + mode + size) |
| Feature graphic | 1024×500, no alpha | yes (dimensions) |
| Phone screenshots | 2–8, short side 320–3840 px, ≤8 MB | presence only |
| Privacy policy URL | live `https://` | yes (scheme + placeholder) |

Character counts are **characters, not bytes**. Emoji and some non-Latin characters can consume more
than one code unit in Play's counter — stay 3–4 characters under the limit if the text uses them.

## Field-by-field sourcing

### Store settings

| Field | Value | Source |
|---|---|---|
| App or game | App | No ads, no game mechanics |
| App name / category / tags | from `store.json → app.*` | Category must match the real function (Photography, Tools, Productivity) |
| Contact email | `store.json → contact.email` | Must be monitored. Support-address rejections are common. |
| Privacy policy | `store.json → contact.privacy_policy_url` | Must match `BrandConfig.privacyPolicyUrl` in the app. Appnovasi house rule: always the shared `https://appnovasi.blogspot.com/p/privasi.html` |
| External marketing | Yes/No | Only "Yes" if you actually run ads |

### Main store listing

| Field | Notes |
|---|---|
| App name | Highest-value real estate. Put the *head* keyword first. Do not use the brand name alone. |
| Short description | Above the fold in search results. Repeat the primary keyword — Play does not treat this as duplication. |
| Full description | Play indexes this text. Use the customer's own words, not internal jargon. Front-load the first 170 characters (visible before "more"). |
| Keyword field | **Google Play has no keyword field.** Play indexes the app name (30), short description (80), full description (4,000) and the developer name — nothing else. The comma-separated keyword box is an App Store (iOS) field; pasting an iOS keyword export into a Play listing reads as spam and buys nothing. Secondary terms belong in the full description, once each, in real sentences. `store.json → listing.keywords` is kept only as a research log — Play Console has nowhere to paste it. |

### App content

| Section | Minimum to publish |
|---|---|
| Privacy policy | Live URL, matching the in-app link |
| Ads | Declare no if no ads SDK is in the dependency tree |
| App access | If any feature is gated, provide reviewer credentials/instructions |
| Content ratings | Complete the questionnaire |
| Target audience | Age groups; must match the ads declaration |
| News app | No |
| COVID-19 app | No |
| Data safety | Per data-type answers; see below |
| Government app | No |
| Financial features | No unless you handle real money |
| Health | No |
| Advertising ID | No permission → No |

### Data safety

Default answer for a local-only Flutter tool: **no data collected, no data shared**, nothing
encrypted in transit because nothing leaves the device. Declare each permission-driven data type only
if the code genuinely transmits it. If you later add Play Billing, Google collects purchase data on
Play's side — you still declare nothing collected *by you*, but you must ship a privacy policy that
explains the Play purchase flow.

### Pricing

Free by default. `paid: false` in `store.json` maps to "Free" in Play Console. A Play price must be
set for the base app before any in-app product can be created.

## Metadata that is NOT part of the listing but blocks release

- IAP product IDs must exist in Play Console with the **exact** ids in `AppConfig.productIds`, active,
  and priced, before the app is reviewed if a paywall is visible.
- Version code strictly increasing.
- A signed `.aab` — `flutter build appbundle --release`.