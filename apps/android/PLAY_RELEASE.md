# Google Play release guide

## One-time Play Console setup

1. Create the app in Play Console with package name `dev.hsichen.colorinvo` and enable Play App Signing.
2. Create a private upload key. Keep the `.jks` outside git, copy `keystore.properties.example` to `keystore.properties`, and fill in its four values.
3. Create a Google Cloud service account, enable the Google Play Android Developer API, invite the account in Play Console, and grant release access for ColorInvo.
4. Complete App access, Ads, Content rating, Target audience, News apps, Data safety, Government apps, Financial features, Health, and the privacy-policy declaration. Review every declaration in Play Console; they are product/legal assertions and are intentionally not automated.
5. Set the English privacy-policy URL to `https://colorinvo.hsichen.dev/en/privacy` and Traditional Chinese URL to `https://colorinvo.hsichen.dev/privacy`.
6. Add at least one tester group to the internal track. Google Play requires the app record and policy forms to exist before API uploads can complete.

The app requests no broad photo or storage permission. A user explicitly selects a wallpaper through Android's system photo picker; palette analysis happens locally. Carrier and appearance settings remain in app preferences and may participate in the user's Android backup according to device settings. Use these facts when reviewing the current Data safety answers rather than copying a stale declaration.

## Store assets

Listing copy and release notes live under `play/en-US` and `play/zh-TW`. Generate localized Android screenshots from an API 36 emulator or device:

```sh
bun run android:screenshots
```

Review the generated images before enabling `PLAY_UPLOAD_SCREENSHOTS=true`. Add a reviewed 1024 × 500 PNG/JPEG feature graphic in each locale's `images/featureGraphic` slot before the production launch. Image upload stays off by default so release automation cannot overwrite reviewed artwork accidentally.

## Local release

Set the following in the gitignored `.env.local`:

```dotenv
ANDROID_VERSION_NAME=0.1.0
ANDROID_VERSION_CODE=1
PLAY_SERVICE_ACCOUNT_JSON=/absolute/path/to/play-service-account.json
PLAY_TRACK=internal
```

Install Fastlane once with `cd apps/android && bundle install`, then run:

```sh
bun run android:release
```

The release command runs unit tests and lint, compiles the app and device-test APKs, creates an R8-minified signed Android App Bundle, and uploads it with localized metadata. It stops before build or upload when signing/API credentials are incomplete.

## CI release

The `Android Play release` workflow is manually dispatched and defaults to the internal track. Configure the protected `google-play` GitHub environment with:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`: base64-encoded upload `.jks`.
- `ANDROID_KEYSTORE_PROPERTIES`: complete properties content; `storeFile` should be `colorinvo-upload.jks`.
- `PLAY_SERVICE_ACCOUNT_JSON`: complete service-account JSON.

Use a unique, monotonically increasing version code for every Play upload. Promote a validated internal build through Play Console instead of rebuilding the same version for production.
