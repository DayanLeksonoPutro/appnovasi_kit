# Native release setup (repeatable patch for any Flutter app)

These edits turn a debug-signed Flutter app into an uploadable release. They are idempotent: apply
them once, re-running the skill should be a no-op.

## 1. Signing — upload key + Play App Signing

Never use the Play *app signing* key locally. Generate a separate **upload key**:

```bash
cd <app-root>/android
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -alias upload
# storePassword / keyPassword / alias / validity must be typed at the prompt.
# Losing this file means losing the ability to upload updates.
```

Create `android/key.properties` (never commit it):

```properties
storePassword=CHANGE_ME
keyPassword=CHANGE_ME
keyAlias=upload
storeFile=../keystore/upload-keystore.jks
```

Recommended layout that keeps secrets out of the source tree:

```
android/key.properties          # ignored by git, points at the keystore
<workspace>/.keys/<app>/upload-keystore.jks   # outside the repo entirely
```

`.gitignore` (repo root) must contain:

```gitignore
# android release signing
**/key.properties
**/*.jks
**/*.keystore
```

## 2. `android/app/build.gradle.kts` patch

Add above `android { }`:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Inside `android { }`, add:

```kotlin
signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
}
```

Inside `buildTypes`, replace the debug signing line and enable shrinking:

```kotlin
buildTypes {
    release {
        signingConfig = if (keystorePropertiesFile.exists()) {
            signingConfigs.getByName("release")
        } else {
            signingConfigs.getByName("debug") // local release runs only
        }
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro",
        )
    }
}
```

`targetSdk`/`compileSdk` stay as `maxOf(flutter.targetSdkVersion, 36)` /
`maxOf(flutter.compileSdkVersion, 37)`, but **verify** the resolved target SDK against the current
Play requirement (see `play-requirements.md`).

## 3. `android/app/proguard-rules.pro`

Flutter's own rules cover the engine, but plugin reflection breaks at release time only. Minimum set
for a plugin-heavy app:

```proguard
# Flutter / embedding
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Play Billing
-keep class com.android.billingclient.api.** { *; }

# pdf / image / syncfusion use reflection for fonts & codecs
-keep class com.syncfusion.** { *; }
-keep class org.apache.pdfbox.** { *; }
-dontwarn org.apache.pdfbox.**

# Kotlin coroutines
-dontwarn kotlinx.coroutines.**
```

Then **build and run the release build on a real device**. R8 failures never show up in
`flutter test`; they show up as a crash on first launch of the release build.

## 4. Manifest hygiene

- Delete permissions the app does not use. Each one is exposed on the store listing.
- For offline apps: keep `INTERNET` in `src/debug/AndroidManifest.xml` only.
- Add `android:enableOnBackInvokedCallback="true"` on `<application>` for Android 13+ predictive back.
- Consider `android:allowBackup="false"` unless cloud backup is desired — it simplifies the Play
  "Data safety → data is backed up" answer.

## 5. Versioning

`pubspec.yaml` is the single source:

```yaml
version: 1.0.0+1    # <versionName>+<versionCode>
```

`versionCode` **must strictly increase** on every upload or Play rejects the AAB. Never reuse it,
including for internal test tracks.

## 6. Release build + verification

```bash
flutter clean
flutter pub get
flutter analyze                 # 0 issues
flutter test                    # all green
flutter build appbundle --release
ls -lh build/app/outputs/bundle/release/app-release.aab
```

Verify the uploaded AAB contents rather than trusting the build log:

```bash
# bundletool is optional but catches missing ABIs / bad split config
java -jar bundletool.jar build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=/tmp/app.apks
```

Check the merged manifest of the built artifact (this is what Play sees):

```bash
cd android && ./gradlew :app:processReleaseManifest
cat app/build/intermediates/merged_manifests/release/*/AndroidManifest.xml
```

Then confirm: no `INTERNET` (if offline posture), no `AD_ID`, no debug signing, `android:label`
correct, `minSdk`/`targetSdk` as expected.

## 7. Play App Signing handoff

1. Upload the AAB signed with the **upload key**.
2. Play Console → **App integrity → App signing** → accept the Play-generated app signing key.
3. Enable **Play App Signing** (recommended, mandatory for new apps) and enrol in **Play App Signing
   for Play-managed publishing services** only if you want Play to reset upload keys for you.
4. Keep the upload key backed up offline. Store it in a password manager, not in git.