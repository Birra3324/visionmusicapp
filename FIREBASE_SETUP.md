# Firebase Setup for Vision Music

This project now includes Firebase scaffolding, but it is not connected to a live Firebase project yet.

## Added in code
- firebase_core
- firebase_auth
- cloud_firestore
- firebase_storage
- placeholder `lib/firebase_options.dart`
- bootstrap helper at `lib/core/services/firebase_bootstrap.dart`

## Next steps

### 1) Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2) Log in to Firebase
```bash
firebase login
```

### 3) Create or select your Firebase project
Suggested project name:
- `vision-music-app`

Suggested Android package:
- `com.visionmusic.app`

### 4) Run FlutterFire configure inside the project
```bash
cd ~/Desktop/visionmusicapp
flutterfire configure
```

Select at minimum:
- Android
- iOS
- macOS

If you plan web later, include web too.

### 5) Replace the placeholder config
`flutterfire configure` should generate a real `lib/firebase_options.dart` file.

### 6) Platform files you will likely need
- Android: `android/app/google-services.json`
- iOS/macOS: `ios/Runner/GoogleService-Info.plist` and/or macOS equivalent depending on setup

## Recommended Firebase services for MVP
- Authentication
- Firestore
- Storage

## Suggested Firestore collections
- users
- artists
- albums
- songs
- playlists
- videos
- featured_sections
- app_config

## Suggested MVP use of each service
### Authentication
- guest mode first
- Google sign-in next

### Firestore
- catalog metadata
- artist records
- playlists
- featured home sections

### Storage
- audio files
- artwork
- video thumbnails
- promo assets

## Important note
The current code is set to skip Firebase initialization when placeholder values are still present. That means the app can keep running locally until you connect the real Firebase project.
