# phones_store_flutter

Flutter client for the PhoneMarket application.

## Run

This project now uses a single entrypoint: `lib/main.dart`.

Development:

```bash
flutter run --flavor development --dart-define=APP_FLAVOR=development
```

Staging:

```bash
flutter run --flavor staging --dart-define=APP_FLAVOR=staging
```

Production:

```bash
flutter run --flavor production --dart-define=APP_FLAVOR=production
```

Set `API_BASE_URL`, `ENABLE_DIO_LOGS`, and `REQUIRE_SECURE_TRANSPORT` with additional `--dart-define` flags as needed.
