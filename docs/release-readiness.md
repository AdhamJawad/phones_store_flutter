# PhoneMarket Release Readiness

## Environments
- Development:
  - entrypoint: `lib/main.dart`
  - intended for local Laravel backends and emulator cleartext traffic
- Staging:
  - entrypoint: `lib/main.dart`
  - intended for pre-production HTTPS verification
- Production:
  - entrypoint: `lib/main.dart`
  - intended for store-ready builds only

## Required Dart Defines
- `APP_FLAVOR=development|staging|production`
- `APP_NAME=PhoneMarket`
- `API_BASE_URL=https://example.com/api/v1`
- `ENABLE_DIO_LOGS=true|false`
- `REQUIRE_SECURE_TRANSPORT=true|false`

Example:

```bash
flutter run \
  --flavor development \
  --dart-define=APP_FLAVOR=development \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=ENABLE_DIO_LOGS=true
```

## Android Builds
- Development:
```bash
flutter run \
  --flavor development \
  --dart-define=APP_FLAVOR=development
```
- Staging APK:
```bash
flutter build apk \
  --release \
  --flavor staging \
  --dart-define=APP_FLAVOR=staging \
  --dart-define=API_BASE_URL=https://staging.example.com/api/v1 \
  --dart-define=ENABLE_DIO_LOGS=false \
  --dart-define=REQUIRE_SECURE_TRANSPORT=true
```
- Production App Bundle:
```bash
flutter build appbundle \
  --release \
  --flavor production \
  --dart-define=APP_FLAVOR=production \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1 \
  --dart-define=ENABLE_DIO_LOGS=false \
  --dart-define=REQUIRE_SECURE_TRANSPORT=true
```

## iOS Builds
- Staging:
```bash
flutter build ios \
  --release \
  --dart-define=APP_FLAVOR=staging \
  --dart-define=API_BASE_URL=https://staging.example.com/api/v1 \
  --dart-define=ENABLE_DIO_LOGS=false \
  --dart-define=REQUIRE_SECURE_TRANSPORT=true
```
- Production:
```bash
flutter build ipa \
  --release \
  --dart-define=APP_FLAVOR=production \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1 \
  --dart-define=ENABLE_DIO_LOGS=false \
  --dart-define=REQUIRE_SECURE_TRANSPORT=true
```

## Signing Preparation
- Android:
  - replace debug signing in `android/app/build.gradle.kts`
  - add keystore properties outside version control
  - enable `phoneMarketEnableCodeShrinking=true` only after a release smoke test
- iOS:
  - configure bundle identifiers per environment in Xcode
  - set team, signing certificate, and provisioning profiles
  - verify `APP_DISPLAY_NAME` per scheme/configuration

## QA Checklist
- Auth bootstrap recovers from missing/expired tokens
- App resume refreshes current user without duplicate requests
- Offline banner appears when connectivity drops
- Repeated taps do not double-submit create/update/delete actions
- Multipart uploads still work for listings and recharge proof submissions
- Protected routes redirect correctly after logout or token expiry
- Invalid product/order routes fall back safely
- Wallet/order flows handle timeout and retry gracefully

## Packaging Checklist
- Replace placeholder launcher icons and launch assets
- Verify Android `applicationId` values for all flavors
- Verify iOS display name and bundle identifiers
- Confirm production base URL uses HTTPS
- Disable Dio logs for staging/production
- Provide store screenshots, privacy metadata, and support URLs
