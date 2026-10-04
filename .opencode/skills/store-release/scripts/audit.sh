#!/usr/bin/env bash
# Preflight audit of a Flutter app for Google Play release readiness.
#
# Usage:
#   bash audit.sh <app-root> [--fast] [--online]
#
#   <app-root>   Flutter project directory (the one containing pubspec.yaml)
#   --fast       skip `flutter analyze` and `flutter test`
#   --online     additionally HTTP-check the URLs found in store/store.json
#
# Exit codes: 0 = no FAIL, 1 = at least one FAIL, 2 = bad usage.
# Portable to macOS bash 3.2 (no associative arrays, no GNU-only tools).

set -uo pipefail

APP_ROOT="${1:-}"
FAST=0
ONLINE=0
for arg in "$@"; do
  case "$arg" in
    --fast) FAST=1 ;;
    --online) ONLINE=1 ;;
  esac
done

if [ -z "$APP_ROOT" ] || [ ! -f "$APP_ROOT/pubspec.yaml" ]; then
  echo "usage: bash audit.sh <app-root> [--fast] [--online]" >&2
  echo "error: $APP_ROOT/pubspec.yaml not found" >&2
  exit 2
fi

# Resolve the script directory before changing cwd; a relative invocation path
# (e.g. `bash .opencode/.../audit.sh`) would otherwise break after `cd`.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$APP_ROOT" || exit 2
APP_ROOT="$(pwd)"

FAIL_COUNT=0
WARN_COUNT=0

pass() { printf '  [PASS] %s\n' "$1"; }
warn() { printf '  [WARN] %s\n' "$1"; WARN_COUNT=$((WARN_COUNT + 1)); }
fail() { printf '  [FAIL] %s\n' "$1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
skip() { printf '  [SKIP] %s\n' "$1"; }
head2() { printf '\n== %s ==\n' "$1"; }

GRADLE_KTS="android/app/build.gradle.kts"
MANIFEST="android/app/src/main/AndroidManifest.xml"

echo "Play release audit: $(pwd)"
echo "date: $(date '+%Y-%m-%d %H:%M %Z')"

# ---------------------------------------------------------------- toolchain --
head2 "toolchain"
if command -v flutter >/dev/null 2>&1; then
  pass "flutter found: $(flutter --version 2>/dev/null | head -1)"
else
  fail "flutter not on PATH"
fi

# ------------------------------------------------------------- version/ids --
head2 "version and identity"
VERSION_LINE="$(grep -m1 '^version:' pubspec.yaml | sed 's/version:[[:space:]]*//')"
if [ -n "$VERSION_LINE" ]; then
  PUB_NAME="$(printf '%s' "$VERSION_LINE" | cut -d+ -f1)"
  PUB_CODE="$(printf '%s' "$VERSION_LINE" | cut -d+ -f2)"
  pass "pubspec version: $VERSION_LINE"
  if [ "${PUB_CODE:-0}" -ge 1 ] 2>/dev/null; then
    pass "versionCode: $PUB_CODE (must increase on every upload)"
  else
    fail "versionCode missing or invalid in pubspec.yaml"
  fi
else
  fail "no version: field in pubspec.yaml"
fi

APP_LABEL="$(sed -n 's/.*android:label="\([^"]*\)".*/\1/p' "$MANIFEST" 2>/dev/null | head -1)"
if [ -n "$APP_LABEL" ]; then
  pass "android:label = $APP_LABEL"
  if [ "${#APP_LABEL}" -gt 30 ]; then
    warn "android:label longer than 30 chars, launcher name will be truncated"
  fi
else
  fail "android:label not set in $MANIFEST"
fi

APPLICATION_ID="$(grep -m1 'applicationId' "$GRADLE_KTS" 2>/dev/null | sed 's/.*= *"//; s/".*//')"
if [ -n "$APPLICATION_ID" ]; then
  pass "applicationId: $APPLICATION_ID"
  case "$APPLICATION_ID" in
    *.debug|*.dev|*.test) warn "applicationId looks like a dev variant ($APPLICATION_ID)" ;;
  esac
else
  fail "applicationId not found in $GRADLE_KTS"
fi

# ------------------------------------------------------------------ sdk set --
head2 "sdk levels"
FLUTTER_ROOT="${FLUTTER_ROOT:-$(dirname "$(dirname "$(command -v flutter)")")}"
FLUTTER_GRADLE="$FLUTTER_ROOT/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt"

# echoes the numeric part of a gradle sdk expression, resolving flutter.<x> to the SDK default
resolve_sdk() {
  local expr="$1"
  local token
  token="$(printf '%s' "$expr" | grep -o 'flutter\.[a-zA-Z]*' | head -1)"
  local literal
  literal="$(printf '%s' "$expr" | grep -o '[0-9]\+' | head -1)"
  if [ -n "$token" ]; then
    local key="${token#flutter.}"
    local value
    value="$(grep -m1 "val ${key}: Int = " "$FLUTTER_GRADLE" 2>/dev/null | sed 's/.*Int = //')"
    if [ -z "$value" ]; then
      return 1
    fi
    # maxOf(flutter.x, N) resolves to the larger of the two
    if [ -n "$literal" ] && [ "$literal" -gt "$value" ] 2>/dev/null; then
      printf '%s' "$literal"
    else
      printf '%s' "$value"
    fi
    return 0
  fi
  printf '%s' "$literal"
}

gradle_sdk() {
  grep -m1 "$1[[:space:]]*=" "$GRADLE_KTS" 2>/dev/null | sed 's/^[^=]*=[[:space:]]*//'
}

RAW_COMPILE="$(gradle_sdk compileSdk)"
RAW_TARGET="$(gradle_sdk targetSdk)"
RAW_MIN="$(gradle_sdk minSdk)"
COMPILE_SDK="$(resolve_sdk "$RAW_COMPILE")"
TARGET_SDK="$(resolve_sdk "$RAW_TARGET")"
MIN_SDK="$(resolve_sdk "$RAW_MIN")"
printf '  info  compileSdk=%s targetSdk=%s minSdk=%s\n' "${COMPILE_SDK:-?} (${RAW_COMPILE:-?})" "${TARGET_SDK:-?} (${RAW_TARGET:-?})" "${MIN_SDK:-?} (${RAW_MIN:-?})"

# Play policy: new apps and updates must target the API level required by Google Play.
# As of 2026-08-31 that is API 36. Override PLAY_MIN_TARGET_SDK if Google changes it.
PLAY_MIN_TARGET_SDK="${PLAY_MIN_TARGET_SDK:-36}"
if [ -z "$TARGET_SDK" ]; then
  if [ -f "$FLUTTER_GRADLE" ]; then
    warn "cannot resolve targetSdk from $GRADLE_KTS or $FLUTTER_GRADLE"
  else
    skip "Flutter SDK sources not found, cannot resolve flutter.targetSdkVersion"
  fi
elif [ "$TARGET_SDK" -ge "$PLAY_MIN_TARGET_SDK" ] 2>/dev/null; then
  pass "targetSdk $TARGET_SDK >= Play minimum $PLAY_MIN_TARGET_SDK"
else
  fail "targetSdk $TARGET_SDK is below the Play requirement $PLAY_MIN_TARGET_SDK"
fi

PLAY_MIN_COMPILE="${PLAY_MIN_COMPILE:-36}"
if [ -n "$COMPILE_SDK" ] && [ "$COMPILE_SDK" -lt "$PLAY_MIN_COMPILE" ] 2>/dev/null; then
  fail "compileSdk $COMPILE_SDK is below $PLAY_MIN_COMPILE"
elif [ -n "$COMPILE_SDK" ]; then
  pass "compileSdk $COMPILE_SDK ok"
fi

if [ -n "$MIN_SDK" ] && [ "$MIN_SDK" -lt 23 ] 2>/dev/null; then
  warn "minSdk $MIN_SDK: Play Billing v6 (in_app_purchase_android) needs 23+"
elif [ -n "$MIN_SDK" ]; then
  pass "minSdk $MIN_SDK ok"
fi

# ----------------------------------------------------------------- signing --
head2 "release signing"
if [ ! -f "$GRADLE_KTS" ]; then
  fail "missing $GRADLE_KTS (run: flutter create --platforms android .)"
else
  if grep -q 'key\.properties' "$GRADLE_KTS"; then
    pass "build.gradle.kts reads android/key.properties"
  else
    fail "release signing not configured: $GRADLE_KTS does not load key.properties"
  fi
  if grep -A6 'buildTypes' "$GRADLE_KTS" | grep -q 'signingConfig = signingConfigs.getByName("debug")'; then
    fail "release buildType still signs with the DEBUG key: Play will reject the upload"
  fi
  if [ -f android/key.properties ]; then
    pass "android/key.properties present (must stay git-ignored)"
  else
    warn "android/key.properties missing: run store-release signing setup (keytool) before uploading"
  fi
  if grep -q 'storeFile' android/key.properties 2>/dev/null; then
    KS_PATH="$(sed -n 's/^storeFile=//p' android/key.properties)"
    if [ -n "$KS_PATH" ] && [ -f "$KS_PATH" ]; then
      pass "keystore file found at $KS_PATH"
    else
      warn "key.properties storeFile points to a missing file: $KS_PATH"
    fi
  fi
fi

# ---------------------------------------------------------------- manifest --
head2 "permissions and offline posture"
# The source manifest is not what Play sees. Plugins merge their own permissions in
# (in_app_purchase_android -> billing -> transport-backend-cct adds INTERNET,
# ACCESS_NETWORK_STATE and BILLING), so an app that markets itself as offline must be
# checked against the *merged* release manifest when one exists. A source manifest can
# also intentionally strip a merged permission with tools:node="remove".
MERGED="build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  INTERNET_SOURCE="$(grep 'android.permission.INTERNET' "$MANIFEST" | grep -v 'tools:node="remove"' || true)"
  if [ -n "$INTERNET_SOURCE" ]; then
    warn "INTERNET declared in the source manifest: if the app is marketed as offline, remove it"
  else
    pass "no INTERNET granted in the source manifest"
  fi
  STRIPPED="$(grep -c 'tools:node="remove"' "$MANIFEST" 2>/dev/null || true)"
  if [ -n "$STRIPPED" ] && [ "$STRIPPED" -gt 0 ] 2>/dev/null; then
    printf '  info  %s permissions stripped with tools:node="remove"\n' "$STRIPPED"
  fi
  if grep 'AD_ID' "$MANIFEST" | grep -v 'tools:node="remove"' | grep -q .; then
    warn "AD_ID permission present: only valid when an ads SDK is actually shipped"
  fi
  if grep -q 'android:usesCleartextTraffic="true"' "$MANIFEST"; then
    fail "usesCleartextTraffic=true is a Play policy violation for production builds"
  fi
  PERMS="$(grep -c 'uses-permission' "$MANIFEST")"
  printf '  info  %s uses-permission entries in the source manifest\n' "$PERMS"
  if [ -d android/app/src/debug ] && grep -q 'android.permission.INTERNET' android/app/src/debug/AndroidManifest.xml 2>/dev/null; then
    pass "INTERNET isolated to the debug manifest (hot reload still works)"
  else
    warn "no INTERNET in the debug manifest: hot reload/VM service will not work"
  fi

  if [ -f "$MERGED" ]; then
    printf '  info  merged release manifest found\n'
    if grep -q 'android.permission.INTERNET' "$MERGED"; then
      printf '  [WARN] INTERNET is present in the MERGED release manifest (pulled in by a plugin).\n'
      printf '         Strip it with <uses-permission android:name="android.permission.INTERNET"\n'
      printf '         tools:node="remove"/> (see references/play-requirements.md, "Offline apps\n'
      printf '         and the INTERNET permission"), or drop the offline claim. Play lists every\n'
      printf '         merged permission publicly.\n'
    else
      pass "no INTERNET in the merged release manifest (offline claim is truthful)"
    fi
    if grep -q 'com.android.vending.BILLING' "$MERGED"; then
      warn "BILLING permission in the merged manifest: declare in_app_purchases=yes (or strip it)"
    fi
    if grep -q 'AD_ID' "$MERGED"; then
      warn "AD_ID in the merged manifest: declare ads=yes in the listing or remove the SDK"
    fi
    if grep -q 'android:usesCleartextTraffic="true"' "$MERGED"; then
      fail "usesCleartextTraffic=true in the merged manifest: Play policy violation"
    fi
    MERGED_SDK="$(grep -o 'android:targetSdkVersion="[0-9]*"' "$MERGED" | head -1 | grep -o '[0-9]\+')"
    MERGED_MIN="$(grep -o 'android:minSdkVersion="[0-9]*"' "$MERGED" | head -1 | grep -o '[0-9]\+')"
    printf '  info  merged targetSdk=%s minSdk=%s\n' "${MERGED_SDK:-?}" "${MERGED_MIN:-?}"
    if [ -n "$MERGED_SDK" ] && [ "$MERGED_SDK" -lt "${PLAY_MIN_TARGET_SDK:-36}" ] 2>/dev/null; then
      fail "merged targetSdk $MERGED_SDK is below the Play minimum ${PLAY_MIN_TARGET_SDK:-36}"
    fi
    MERGED_LABEL="$(sed -n 's/.*android:label="\([^"]*\)".*/\1/p' "$MERGED" | head -1)"
    if [ -n "$MERGED_LABEL" ]; then
      pass "merged android:label = $MERGED_LABEL"
    fi
  else
    skip "no merged release manifest (run: cd android && ./gradlew :app:processReleaseManifest)"
  fi
else
  fail "missing $MANIFEST"
fi

# -------------------------------------------------------------------- iap ---
head2 "monetization coherence"
if grep -q 'productIds' lib/app_config.dart 2>/dev/null; then
  if grep -qE 'productIds:[[:space:]]*(const[[:space:]]*)?\[\][[:space:]]*[,)]' lib/app_config.dart; then
    pass "productIds empty: this build has no billing dependency"
  else
    # Billing needs the network. Check the merged manifest, which is what ships.
    BILLING_NET="no"
    if [ -f "$MERGED" ]; then
      grep -q 'android.permission.INTERNET' "$MERGED" && BILLING_NET="yes"
    elif grep -q 'android.permission.INTERNET' "$MANIFEST" 2>/dev/null; then
      BILLING_NET="yes"
    fi
    if [ "$BILLING_NET" = "yes" ]; then
      pass "productIds set and INTERNET granted: Play Billing can reach the service"
    else
      warn "productIds set but no INTERNET permission: purchases will fail at runtime"
    fi
    if grep -qE 'kTrialProUnlocked[[:space:]]*=[[:space:]]*true|kOfflineProUnlocked[[:space:]]*=[[:space:]]*true' lib/app_config.dart 2>/dev/null; then
      warn "pro/trial flag is true in app_config: premium features ship unlocked"
      if [ "$BILLING_NET" = "yes" ]; then
        printf '         INTERNET is already granted, so the paywall can be switched on: set the\n'
        printf '         flag to false, create the product in Play Console, and declare\n'
        printf '         in_app_purchases=true in store.json.\n'
      else
        printf '         Expected for an offline release: Play Billing cannot work without\n'
        printf '         INTERNET. Confirm the store listing does not advertise a purchase.\n'
      fi
    fi
  fi
fi

# ------------------------------------------------------------------ icons --
head2 "icons and store assets"
RES="android/app/src/main/res"
if [ -f "$RES/mipmap-anydpi-v26/ic_launcher.xml" ]; then
  pass "adaptive launcher icon present (Android 8+ mask respected)"
else
  warn "no mipmap-anydpi-v26/ic_launcher.xml: launcher icons will be masked inconsistently"
fi
if [ -f store/assets/icon_512.png ]; then
  pass "store/assets/icon_512.png present"
else
  fail "store/assets/icon_512.png missing (run generate_icons.py)"
fi
if [ -f store/assets/feature_graphic_1024x500.png ]; then
  pass "store/assets/feature_graphic_1024x500.png present"
else
  warn "store/assets/feature_graphic_1024x500.png missing"
fi
SHOTS="$(find store/assets/screenshots -type f -name '*.png' 2>/dev/null | wc -l | tr -d ' ')"
if [ "${SHOTS:-0}" -ge 2 ]; then
  pass "$SHOTS phone screenshots captured (Play requires 2-8)"
elif [ "${SHOTS:-0}" -eq 1 ]; then
  warn "only 1 phone screenshot, Play requires at least 2"
else
  warn "no screenshots captured: Play requires 2-8 phone screenshots"
fi

# ------------------------------------------------------------- minify/so ---
head2 "build configuration"
if grep -q 'isMinifyEnabled = true' "$GRADLE_KTS" 2>/dev/null; then
  pass "R8 minify enabled"
else
  warn "R8 minify disabled: larger download size, no obfuscation"
fi
if grep -q 'isShrinkResources = true' "$GRADLE_KTS" 2>/dev/null; then
  pass "resource shrinking enabled"
else
  warn "isShrinkResources not enabled"
fi
if grep -rq 'proguard' android/app/*.pro 2>/dev/null || [ -f android/app/proguard-rules.pro ]; then
  pass "custom proguard rules file present"
else
  warn "no android/app/proguard-rules.pro: keep rules needed by pdf/syncfusion/plugins are missing"
fi
if [ -f android/app/src/main/AndroidManifest.xml ] && grep -q 'android:allowBackup' "$MANIFEST" 2>/dev/null; then
  warn "android:allowBackup set: verify it matches the Play backup policy claim"
fi

# ------------------------------------------------------------ placeholders --
head2 "placeholders and secrets"
if grep -rn 'REPLACE_ME\|YOUR_DOMAIN\|YOUR-DOMAIN' lib/ store/*.json 2>/dev/null | head -5 | grep -q .; then
  fail "placeholder values still present in lib/ or store.json:"
  grep -rn 'REPLACE_ME\|YOUR_DOMAIN\|YOUR-DOMAIN' lib/ store/*.json 2>/dev/null | head -5 | sed 's/^/        /'
else
  pass "no REPLACE_ME placeholders left"
fi
if git -C . ls-files --error-unmatch android/key.properties >/dev/null 2>&1; then
  fail "android/key.properties is tracked by git: remove it and rotate the key"
else
  pass "android/key.properties is not tracked by git"
fi
if git -C . ls-files | grep -qE '\.jks$|\.keystore$'; then
  fail "keystore file committed to git: revoke and rotate it"
else
  pass "no keystore file committed"
fi

# ------------------------------------------------------------ store data ---
head2 "store listing data"
if [ -f store/store.json ]; then
  pass "store/store.json present"
  if [ -x "$SCRIPT_DIR/store_tool.py" ] || command -v python3 >/dev/null 2>&1; then
    if python3 "$SCRIPT_DIR/store_tool.py" validate "$APP_ROOT" >/tmp/store_validate_$$.txt 2>&1; then
      pass "store.json validates against Play field limits"
      [ "$ONLINE" -eq 1 ] && python3 "$SCRIPT_DIR/store_tool.py" links "$APP_ROOT" | sed 's/^/  /'
    else
      fail "store.json has validation errors:"
      sed 's/^/        /' /tmp/store_validate_$$.txt
    fi
    rm -f /tmp/store_validate_$$.txt
  fi
  if [ -f store/keyword-research.md ]; then
    pass "store/keyword-research.md present"
  else
    warn "store/keyword-research.md missing: title/keywords should be research-backed"
  fi
  if [ -f store/upload-checklist.md ]; then
    pass "store/upload-checklist.md present"
  else
    warn "store/upload-checklist.md missing"
  fi
  if [ -f store/web/privacy.html ] && [ -f store/web/terms.html ]; then
    pass "hostable legal pages present (store/web/privacy.html, terms.html)"
  else
    warn "store/web/ legal pages missing: run store_tool.py web <app-root>"
  fi
else
  fail "store/store.json missing: create it with store_tool.py init, then fill it in"
fi

# ------------------------------------------------------------ code health --
head2 "code health"
if grep -rn '\bprint(' lib/ 2>/dev/null | grep -v '// ' | head -3 | grep -q .; then
  warn "print() calls in lib/: replace with debugPrint"
else
  pass "no print() in lib/"
fi
if [ "$FAST" -eq 1 ]; then
  skip "flutter analyze (--fast)"
  skip "flutter test (--fast)"
else
  if command -v flutter >/dev/null 2>&1; then
    if flutter analyze >/tmp/audit_analyze_$$.txt 2>&1; then
      pass "flutter analyze clean"
    else
      fail "flutter analyze reports issues:"
      grep -E '^\s+(info|warning|error)' /tmp/audit_analyze_$$.txt | head -10 | sed 's/^/        /'
    fi
    if flutter test >/tmp/audit_test_$$.txt 2>&1; then
      pass "flutter test green"
    else
      fail "flutter test failing:"
      grep -E 'Some tests failed|\[E\]' /tmp/audit_test_$$.txt | head -10 | sed 's/^/        /'
    fi
    rm -f /tmp/audit_analyze_$$.txt /tmp/audit_test_$$.txt
  fi
fi

# ----------------------------------------------------------------- report --
head2 "summary"
printf '  FAIL: %s   WARN: %s\n' "$FAIL_COUNT" "$WARN_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "  RESULT: NOT ready for Play Console upload"
  exit 1
fi
if [ "$WARN_COUNT" -gt 0 ]; then
  echo "  RESULT: uploadable, but resolve the warnings first (Play reviewers are strict)"
else
  echo "  RESULT: ready for Play Console upload"
fi
exit 0