# Rahe-Sehat Healthcare AI

Flutter mobile frontend for Rahe-Sehat Healthcare AI, an AI-powered healthcare
coordination and hospital intelligence app.

## Backend

The app defaults to the hosted FastAPI backend:

```bash
https://kcu28-aiseekho-backend.hf.space
```

You can override it at build/run time:

```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.example.com
```

## Google Maps

Do not commit API keys. For local Android builds, provide the Maps key in one of
these places:

```properties
# android/local.properties
GOOGLE_MAPS_API_KEY=your_google_maps_key
```

or:

```bash
flutter build apk --release -PGOOGLE_MAPS_API_KEY=your_google_maps_key
```

For a production release APK, also provide a real signing config in
`android/key.properties` and make sure the Google Maps API key is allowed for
the release package name and SHA-1 certificate fingerprint.

If you build in GitHub Actions, add these secrets as well:

```text
GOOGLE_MAPS_ANDROID_KEY or GOOGLE_MAPS_API_KEY
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

Example `android/key.properties`:

```properties
storeFile=../app/upload-keystore.jks
storePassword=your_store_password
keyAlias=upload
keyPassword=your_key_password
```

## Build

```bash
flutter pub get
flutter analyze
flutter build apk --release --split-per-abi
```
