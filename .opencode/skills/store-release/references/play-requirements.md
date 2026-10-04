# Google Play release requirements (verified 2026-10-01)

Authoritative sources to re-check when something is rejected:

- Target API: <https://support.google.com/googleplay/android-developer/answer/11926878>
- Data safety: <https://support.google.com/googleplay/android-developer/answer/10144311>
- Store listing / graphics: <https://support.google.com/googleplay/android-developer/answer/9866151>
- Developer verification (identity): <https://support.google.com/googleplay/android-developer/answer/14177239>

## Hard gates — an upload is rejected or the app is delisted if these fail

| Requirement | Value as of Oct 2026 | Notes |
|---|---|---|
| Target API level | **API 36 (Android 16)** | Required for new apps *and* updates since **31 Aug 2026**. Extension requests until 1 Nov 2026. Flutter 3.4x resolves `flutter.targetSdkVersion` to 36 — verify in `FlutterExtension.kt`, do not assume. |
| Format | **Android App Bundle (.aab)** | APK uploads are not accepted for new apps. |
| Signing | **Upload key + Play App Signing** | Never ship the app signing key. Generate a separate *upload* key. |
| Data safety form | Mandatory, per app | Must match runtime behaviour. Mismatch = removal. |
| Privacy policy | Live `https://` URL + reachable in-app | Play verifies the URL returns a real policy page. A dead domain is a rejection, not a warning. |
| Content rating | Questionnaire completed | Unrated apps are not distributed. |
| Target audience & content | Declared | Drives ads/age gating. |
| Account testing requirement | New personal accounts: closed test with **12 testers for 14 days** before production | Org accounts (D-U-N-S) are exempt. |
| Developer verification | Identity + contact verification per developer account | Do the "Who to contact" step before first release. |

## Bundle / build requirements

- 64-bit: mandatory for all apps since Aug 2019 — Flutter produces `arm64-v8a`, `armeabi-v7a`, `x86_64` by default.
- `minSdk`: `in_app_purchase_android` (Play Billing v6+) and `pdf`/`syncfusion` need **23+**. Flutter's default is 24, which is fine.
- `compileSdk`: 36+ required to compile against API 36 resources.
- Cleartext HTTP: `android:usesCleartextTraffic="true"` is a policy violation for production.
- Permission `com.google.android.gms.permission.AD_ID` is auto-merged by any ads SDK. If you answer "no ads" in the store listing but ship an ads SDK, you have both a Data safety and an ads-declaration violation.

## Permissions

Every permission in the merged manifest is listed on the Play listing and must be justified in the
**App content → Permissions** declarations. Rejections happen when the app requests something the
listing does not explain, or when the feature needs a permission you did not declare:

| Permission | Trigger declaration |
|---|---|
| `CAMERA` | Justify in the listing photo; cannot ship a camera feature that never opens |
| `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` | Required if the app reads the gallery |
| `POST_NOTIFICATIONS` | Needed if you ship notifications on API 33+ |
| `QUERY_ALL_PACKAGES` | Restricted, requires justification |
| `MANAGE_EXTERNAL_STORAGE` | Restricted, Play rarely approves |

Permissions you *do not use* should be deleted from the manifest — reviewers test for over-requesting.

## Offline apps and the INTERNET permission

An app that markets itself as "100% offline" must not hold `android.permission.INTERNET` in the
release manifest; Flutter puts it only in `android/app/src/debug/AndroidManifest.xml`, which is the
correct pattern. Consequences to plan for:

- **Google Play Billing (`in_app_purchase`) cannot work.** BillingClient needs the network, and the
  plugin does not declare the permission for you. `_iap.isAvailable()` returns `false` rather than
  throwing, so the app boots — but every purchase path silently fails.
- Shipping purchases from a no-INTERNET build guarantees 1-star reviews if a paywall is visible.
- Either drop the paywall for the offline release, or add `INTERNET` back and state precisely what
  it is used for in the privacy policy ("used only to validate and process purchases").

## Graphics

| Asset | Spec | Rejection trigger |
|---|---|---|
| App icon | 512×512 PNG, 32-bit, **max 1 MB**, **no alpha/transparency** | Alpha channel, non-square, blurry |
| Feature graphic | 1024×500 PNG or JPG, **no alpha** | Transparency, wrong ratio |
| Phone screenshots | 2–8 per language, short side 320–3840 px, **max 8 MB each** | Fewer than 2 |
| 7" tablet | Optional, 320–3840 px | — |
| 10" tablet | Optional | — |
| Video (optional) | YouTube URL, app must be published first | — |

Play applies its own rounding and shadow to the icon. Upload the **full-bleed square**: do not
pre-round the corners of the 512 icon, and do not include the app name in it if it becomes unreadable
at 48 px.

## Review rejection reasons that are avoidable

1. Dead or placeholder privacy policy URL, or a policy that contradicts the app (e.g. claims "no data
   collected" while the app requests camera + network).
2. Store listing describes features that are behind a paywall without saying so.
3. Broken features in the submitted build (usually release-only: R8 stripping, missing ProGuard
   rules, missing permissions).
4. Screenshot text that does not match the actual UI (screenshot shows a feature the build lacks).
5. Debug/placeholder text left in the build (`TODO`, `test`, `localhost`, `example.com`).
6. Content rating questionnaire left empty for a new app.
7. Icon so detailed it is unreadable, or an icon that is a photo of the app's UI screenshot.

## Release order that works (use `store/upload-checklist.md`)

1. Closed test track with the release AAB (also satisfies the 12-tester rule on new personal accounts).
2. Internal test to validate the build with real devices + real purchases when monetised.
3. Production, **staged rollout** (5% → 20% → 100%) so a release-blocking crash can be halted.
4. `versionCode` must strictly increase for every upload; `versionName` must be user-visible and
   meaningful.