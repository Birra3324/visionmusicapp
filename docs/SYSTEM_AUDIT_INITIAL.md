# Vision Music — Initial System Architecture Audit

**Date:** 2026-09-14  
**Scope:** Read-only architecture map of this Flutter listener client (`github.com/Birra3324/visionmusicapp`).  
**Method:** Source inspection of the current `main` tree. No production config was changed. No Firebase/GCP console mutations. No billing, signing, or package-ID edits.  
**Companion docs (historical, not re-verified at runtime):** `docs/VISION_MUSIC_MASTER_AUDIT.md` (2026-08-11), `TECHNICAL_AUDIT_2026-08-10.md`, `docs/FIRESTORE_SCHEMA.md` (proposal), `docs/ADMIN_API_CONTRACT.md` (proposal).

---

## 0. Verified identity (matches Mac diagnostics)

| Fact | Evidence | Status |
| --- | --- | --- |
| Firebase/GCP project `visionmusic-dev` | `lib/firebase_options.dart`, `android/app/google-services.json`, iOS/macOS plists, `firebase.json` | **Confirmed** |
| `projectNumber` / sender id `190873708714` | Same files (`messagingSenderId` / `GCM_SENDER_ID` / `project_number`) | **Confirmed** |
| Android/iOS package `com.visionmusic.app` | `android/app/build.gradle.kts` `applicationId` + `namespace`; iOS `PRODUCT_BUNDLE_IDENTIFIER`; macOS `AppInfo.xcconfig` | **Confirmed** |
| `pubspec` version `1.0.0+3` | `pubspec.yaml` line 5 | **Confirmed** |
| Firebase packages: core, auth, firestore, storage, analytics, app_check, crashlytics | `pubspec.yaml` 25–31 | **Confirmed** |
| Billing `billingEnabled=false` on `visionmusic-dev`; linked account **VisionMusic Cloud** `OPEN=false` (closed) | Mac diagnostics (not re-queried here). Parent is handling the billing fix separately. | **Accepted as given** |

This audit does **not** contradict those facts. It maps what the **code** assumes about Blaze / Cloud Functions / Cloud Run so the billing fix has a complete picture.

---

## 1. Flutter architecture

### 1.1 Entry points

| Entry | Role |
| --- | --- |
| `lib/main.dart` → `main()` | Only runtime entry. `WidgetsFlutterBinding.ensureInitialized()` then `runApp(const AppBootstrapper())`. |
| `AppBootstrapper` | Async init: `SettingsManager`, `FirebaseBootstrap`, `AppObservability`, `VideoServiceLocator`, catalog load, `AudioManager`, `AudioService.init`, `AudioSession`, recognition service. |
| `VisionMusicApp` | `MaterialApp` (dark gold theme, gen-l10n, 6 locales). **`home` is always `LoginScreen`.** No named routes, no `go_router` / `auto_route`. |
| `lib/_archive/**` | Historical screens/handlers. Excluded from analysis (`analysis_options.yaml`). Not imported by live code. |

There are no flavor entrypoints (`main_dev.dart` / `main_prod.dart`). Dev and any future prod share one `DefaultFirebaseOptions`.

Startup sequence:

```
main()
  AppBootstrapper._initServices()
    SettingsManager.init()                    // SharedPreferences
    FirebaseBootstrap.initialize()            // skipped only if placeholders
    AppObservability.initialize()             // Analytics + Crashlytics if Firebase ready
    VideoServiceLocator.init()                // Firestore VideoService (always constructed)
    _loadCatalog()                            // Firestore iff AppConfig.useFirebaseCatalog
    AudioManager(initialTracks) + persist
    AudioService.init(VisionAudioHandler)     // same AudioPlayer instance
    AudioSession.music()
    MusicRecognitionService(baseUrl localhost)
  → MultiProvider(AudioManager, SettingsManager, MusicRecognitionService)
  → VisionMusicApp.home = LoginScreen
```

### 1.2 Routing

Imperative `Navigator.push` / `pushReplacement`. Audio surfaces use `fadeRoute()` (`lib/widgets/fade_route.dart`); video uses `MaterialPageRoute`.

| Surface | How reached |
| --- | --- |
| `LoginScreen` | App `home` |
| `MainShell` | Guest continue **or** Google sign-in success (`pushReplacement`) |
| Tab 0 `GoldDiscoverScreen` | IndexedStack |
| Tab 1 `VideoHubScreen` | IndexedStack |
| Tab 2 `LibraryHubScreen` | IndexedStack |
| Tab 3 `SearchHubScreen` | IndexedStack |
| Tab 4 `ProfileHubScreen` | IndexedStack |
| `NowPlayingScreen` | Mini player, song row, search, library |
| `VideoPlayerScreen` / `VideoCategoryScreen` | Watch tab |
| `PlaylistsScreen` / `PlaylistDetailScreen` / `ArtistScreen` | Library |
| `MusicIdentificationScreen` | Search hub |

`MainShell` hides the mini-player on the Watch tab (index 1) to avoid audio/video confusion.

**Auth routing gap:** a returning signed-in user still lands on `LoginScreen`. There is no `authStateChanges` gate that skips login. Profile never calls `AuthService.signOut()`.

### 1.3 State management

`provider` 6.x. Three `ChangeNotifier`s at the root:

| Object | Lifetime | Persistence |
| --- | --- | --- |
| `AudioManager` | Process | Queue in memory; favorites / library / “downloaded” / recents in `SharedPreferences` |
| `SettingsManager` (singleton) | Process | autoplay, shuffle, repeat, locale in `SharedPreferences` |
| `MusicRecognitionService` | Process | None (temp m4a deleted after upload) |

Playlists are **not** in the root provider. `PlaylistController` is constructed locally in `PlaylistsScreen` and again (a **new** instance) in `SongMoreOptionsButton`. `AudioManager.playlists` is hard-coded to `const []`. Two stores, no shared notifier.

### 1.4 Auth flow

`lib/features/auth/auth_service.dart`:

- Google: native `GoogleSignIn` → `GoogleAuthProvider.credential`; web uses `signInWithPopup`.
- Guest: **no** `signInAnonymously()`. Guest is a local navigation skip. `FirebaseAuth.currentUser` stays null.
- `isFirebaseReady` is `!FirebaseBootstrap.hasPlaceholderConfig`, **not** “bootstrap succeeded”. Placeholder check is platform-scoped (Windows/Linux `REPLACE_WITH_` values do not block iOS/Android).

`LoginScreen`: Google button disabled when placeholders exist; guest always allowed. Copy says favorites/recents are device-local — that matches the code (not Firestore `users/{uid}`).

**Google Sign-In platform wiring is incomplete in this repo:**

- Android `google-services.json` has `"oauth_client": []` (no Android OAuth client / SHA-1).
- iOS `GoogleService-Info.plist` has no `CLIENT_ID` / `REVERSED_CLIENT_ID`.
- iOS `Info.plist` has no `CFBundleURLTypes` for the reversed client ID (required by `google_sign_in`).

Email/password and Apple Sign-In are not implemented. `docs/FIREBASE_MIGRATION_PLAN.md` notes App Store requires Apple wherever Google is offered.

### 1.5 Media playback

Single engine (confirmed, still true):

- `AudioManager` owns one `just_audio` `AudioPlayer`.
- `VisionAudioHandler` (`lib/audio/audio_handler.dart`) is injected with that manager and uses `_audioManager.player` — it does **not** construct a second player.
- One source is loaded at a time (`playAtIndex` → `setAudioSource`). Shuffle/repeat are owned by `AudioManager` + `SettingsManager`, not by `LoopMode` on a concatenated queue.
- Background: `audio_service` notification channel `com.visionmusic.app.channel.audio`; Android FGS `mediaPlayback`; iOS `UIBackgroundModes: audio`.
- Paths go through `MediaSourceResolver`: `assets/` / `https?://` / `gs://` (download URL at play time) / `file://`.
- “Download” only sets a SharedPreferences flag (`AudioManager.download`). No file is written. Artwork for `file://` / `gs://` falls back to the logo.

**Catalog switch:** `AppConfig.useFirebaseCatalog = false` (`lib/core/services/app_config.dart`). Songs come from `LocalSongRepository` → `lib/mock_songs.dart` (8 bundled tracks). Firestore is wired but dark.

**Video is not gated by that flag.** `VideoService` always talks to Firestore collections `videos` / `videoCategories` when Firebase initialized, and falls back to `lib/mock_videos.dart` on error or empty. Native `video_player` + `chewie` for non-YouTube URLs; YouTube opens externally via `url_launcher`.

### 1.6 AI assistant wiring

Feature exists under `lib/features/ai_music_assistant/` (prompt builder, validator, JSON decoder, screen, logger) and is covered by unit tests.

**It is not on any navigation path.** `AiMusicAssistantScreen` is never pushed. `MusicAiClient` is an abstract class with **no production implementation** (only `FakeMusicAiClient` / `ThrowingMusicAiClient` in tests). There is no HTTP/Gemini/OpenAI client, no `cloud_functions` package, and no API key injection.

Dead / placeholder AI services (not used by the assistant screen):

| File | Pattern |
| --- | --- |
| `lib/services/ai_translation_service.dart` | `_geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE'`; comments say a future call must go through a Cloud Function |
| `lib/services/music_metadata_ai_service.dart` | Same placeholder key |
| `lib/services/audio_language_detection_service.dart` | Commented OpenAI transcription URL |

`LyricsService` is honest-empty (fabricated lyrics were removed 2026-08-11). No licensed provider.

---

## 2. Firebase initialization and config consistency

Bootstrap: `lib/core/services/firebase_bootstrap.dart`.

1. Skip `Firebase.initializeApp` if current-platform options look like `REPLACE_WITH_`.
2. Else initialize with `DefaultFirebaseOptions.currentPlatform`.
3. Enable Firestore persistence.
4. Touch Auth + Storage instances.
5. Activate App Check: Play Integrity / App Attest in **release**; **debug providers** otherwise. Comment in file: **enforcement is a console action after monitoring**, not done in code.

Observability (`lib/core/services/app_observability.dart`): Analytics events with opaque IDs only; Crashlytics collection **disabled in debug**.

### 2.1 Cross-file consistency (`visionmusic-dev` / `190873708714` / `com.visionmusic.app`)

| Location | projectId | appId | package / bundle | Notes |
| --- | --- | --- | --- | --- |
| `lib/firebase_options.dart` Android | visionmusic-dev | `1:190873708714:android:57de878985e6c1782b08d3` | (via gradle) | Matches |
| `lib/firebase_options.dart` iOS | visionmusic-dev | `1:190873708714:ios:a219e9ab0dcc4fd72b08d3` | `com.visionmusic.app` | Matches |
| `lib/firebase_options.dart` macOS | visionmusic-dev | **same iOS appId** | `iosBundleId: com.visionmusic.app` | **macOS registered as iOS app** |
| `lib/firebase_options.dart` web | visionmusic-dev | `1:190873708714:web:941ac983abaa714a2b08d3` | n/a | Has `measurementId` `G-GKZ8HSXCET` |
| `lib/firebase_options.dart` Windows / Linux | `REPLACE_WITH_PROJECT_ID` | placeholders | n/a | Bootstrap skips Firebase |
| `android/app/google-services.json` | visionmusic-dev | same Android appId | `com.visionmusic.app` | Matches; **oauth_client empty** |
| `ios/Runner/GoogleService-Info.plist` | visionmusic-dev | same iOS appId | `com.visionmusic.app` | Matches; **no OAuth client fields** |
| `macos/Runner/GoogleService-Info.plist` | visionmusic-dev | **same iOS appId** | `com.visionmusic.app` | Byte-identical to iOS plist |
| `firebase.json` FlutterFire block | visionmusic-dev | Android/iOS/web as above; macOS = iOS | — | Matches Dart options |

Storage bucket everywhere that is configured: `visionmusic-dev.firebasestorage.app`.

No `.firebaserc` in the repo (CLI default project is not pinned here).

`FIREBASE_SETUP.md` at repo root is **stale** (still describes placeholder scaffolding and a suggested project name `vision-music-app`). Live wiring is `visionmusic-dev` as of 2026-08-12 (`docs/FIREBASE_MIGRATION_PLAN.md` status note).

---

## 3. Firestore collections referenced in **code** vs proposed schema

### 3.1 Actually queried / written by the Flutter app

| Collection | File | Operations | Query shape |
| --- | --- | --- | --- |
| `songs/{id}` | `lib/core/services/firestore_song_repository.dart` | read | `status == 'published' && approved == true`; also `doc(id)` gated by `PublicCatalogPolicy` |
| `videos/{id}` | `lib/core/services/video_service.dart` | read + **update** | `isPublished == true` (+ `isFeatured`, `category`) `orderBy('releaseDate')`; `incrementViewCount` writes `viewCount` |
| `videoCategories/{id}` | `lib/core/services/video_service.dart` | read | `isActive == true` `orderBy('sortOrder')` |
| `videos/{id}` (alt) | `lib/core/services/video_repository.dart` | read | Same collection, but `orderBy('publishedAt')` and `type` — **not used by VideoHub** (hub uses `VideoService`) |

`PublicCatalogPolicy` (`lib/core/services/public_catalog_policy.dart`) audio resolution order: `publishedAudioUrl` → renditions `aac256|aac128|aac64|mp3` with `approved && public` → legacy `filePath`. Paths must be `http` / `https` / `gs`.

`lib/models/firestore_song_model.dart` is a richer shape (`playCount`, AI mood fields, `toFirestore()`). **Nothing imports it.** Live mapping is `FirestoreSongRepository._songFromMap`.

### 3.2 Declared in `firestore.rules` but unused by Dart

| Path | Rules intent | Dart usage |
| --- | --- | --- |
| `users/{userId}` + `favorites`, `library`, `recentlyPlayed`, `playlists`/`tracks`, `downloads` | owner-only | **None.** All of that is SharedPreferences. |
| `publicPlaylists/{playlistId}` | public-if-`isPublic`; owner write | **None.** |

### 3.3 Proposed in docs, **not** in rules or app code

From `docs/FIRESTORE_SCHEMA.md` (status: not deployed): `adminRoles`, `ingestionRequests`, `processingJobs`, `tracks`, `artists`, `albums`. The default-deny rule would block client access if they existed. No Dart references.

### 3.4 Indexes

`firestore.indexes.json` is `{ "indexes": [], "fieldOverrides": [] }`.

Video queries that combine equality + `orderBy` **require composite indexes**. Without them, `VideoService` catches the error and silently serves `mockVideos`. Song query is two equalities on one collection (usually no custom composite needed).

---

## 4. Storage paths

### 4.1 Used at runtime

The client does **not** construct Storage object paths. It only:

- Calls `FirebaseStorage.instance.refFromURL(gs://…).getDownloadURL()` (`MediaSourceResolver.resolveStorageRef`).
- Loads `https://` URLs directly (`AudioSource.uri` / `NetworkImage` / `VideoPlayerController.networkUrl`).
- Loads bundled `assets/audio/*` and `assets/images/*`.

So the live audio catalog never hits Storage today (`useFirebaseCatalog = false`).

### 4.2 Declared in `storage.rules`

| Prefix | Read | Write |
| --- | --- | --- |
| `audio/**` | signed-in | deny |
| `video/**` | signed-in | deny |
| `artwork/**` | public (`if true`) | deny |
| `users/{userId}/profile/{fileName}` | signed-in | owner + image + &lt; 5 MB |
| everything else | deny | deny |

**Mismatch with guest mode:** guests never authenticate. If the catalog flips to `gs://` audio under `audio/`, guests cannot stream. `https` download URLs with tokens are a separate (weaker) access model; the rules file’s stated intent is “auth required to stream.”

### 4.3 Proposed in admin docs, **not** in `storage.rules`

`private/sources/`, `private/processing/`, `private/renditions_staging/`, `public/renditions/`, `public/waveforms/` (`docs/SECURITY_MODEL.md`, `docs/ADMIN_API_CONTRACT.md`). Unmatched prefixes fall through to default deny — acceptable until the pipeline exists, but the delta was never applied.

`tools/import_youtube_videos.py` writes Firestore `videos` docs (Admin SDK), not Storage objects.

---

## 5. Admin functionality and role enforcement

**There is no admin UI, no admin role check, and no custom-claim reader in this app.**

- No `adminRoles` reads, no `request.auth.token.role`, no `cloud_functions` / `httpsCallable`.
- Catalogue writes are denied to **all** clients in `firestore.rules` (`allow write: if false` on `songs` / `videos` / `videoCategories`). That is the only “admin” boundary in this repo: clients cannot publish.
- `VideoService.incrementViewCount` is a client write to `videos` and **would be denied** by those rules. It is also **uncalled** (dead method).
- README: admin studio and Cloud Functions live in **separate private repos**. This tree is the listener client only.
- `docs/ADMIN_API_CONTRACT.md` / `SECURITY_MODEL.md` specify `role: 'admin'` custom claim **plus** live `adminRoles/{uid}.active` re-check inside callables. **None of that is implemented here.**

Operator script: `tools/import_youtube_videos.py` uses a **Firebase service-account JSON** (`firebase-key.json`) via Admin SDK — that bypasses rules. Docs instruct placing the key in `tools/`. That path was **not** gitignored before this audit (see P1). No `firebase-key.json` is in the tree now.

---

## 6. Cloud Functions, backend APIs, Cloudflare / domains

### 6.1 In this repository

| Kind | Present? |
| --- | --- |
| `functions/` directory | **No** |
| `cloud_functions` pub dependency | **No** |
| `httpsCallable` / `FirebaseFunctions` | **No** (docs only) |
| `.firebaserc` | **No** |
| Recognition backend | **Hardcoded** `http://127.0.0.1:8081/recognize` in `lib/main.dart` |
| YouTube Data API | `lib/core/services/youtube_config.dart` — `apiKey` and `channelId` are `null`; URLs to `googleapis.com/youtube/v3` never built |
| Gemini / OpenAI | Placeholder / commented URLs only |

Recognition (`lib/features/recognition/services/recognition_repository.dart`) sends Firebase ID token + optional App Check token as `Authorization` / `X-Firebase-AppCheck`. It **throws if `currentUser == null`**, so guests cannot use Identify. The server is not in this repo; localhost will fail on device/TestFlight.

### 6.2 Code and docs that assume Blaze / Cloud Functions / Cloud Run

These cannot run on Spark (`billingEnabled=false`) and will stay blocked until the closed billing account is reopened (parent-owned):

| Assumption | Where |
| --- | --- |
| Callable Functions for admin ingest/publish | `docs/ADMIN_API_CONTRACT.md` entire contract |
| Cloud Run FFmpeg `process` service | same + `docs/COST_ESTIMATE.md` + `docs/SECURITY_MODEL.md` |
| “Put Gemini keys behind a Cloud Function” | `lib/services/ai_translation_service.dart` |
| YouTube API key belongs in a Cloud Function | `VIDEO_LINKS_TO_FILL_IN.md` |
| Spark → Blaze for public streaming | `docs/COST_ESTIMATE.md` |
| “Confirm Blaze billing budget alerts” | `docs/TESTFLIGHT_READINESS_CHECKLIST.md` |
| AWS MediaConvert + S3 (alt pipeline, also paid) | `BACKEND_SETUP_FIREBASE_AWS.md` |
| Admin studio + Functions in other repos | `README.md` |

App Check **activation** in the client does not require Blaze; **enforcement** and Play Integrity in production are console/billing-sensitive. Crashlytics/Analytics are initialized when Firebase is ready.

### 6.3 Domains / Cloudflare

| Host | In runtime code? | Notes |
| --- | --- | --- |
| `www.visionmusic.et` | No (README only) | Marketing site; separate repo `visionmusic-site` |
| `cdn.visionmusic.et` | Tests only (`test/public_catalog_policy_test.dart`) | Not referenced by the app |
| `visionmusic-dev.firebaseapp.com` | `firebase_options.dart` web `authDomain` | |
| `visionmusic-dev.firebasestorage.app` | All configured Firebase options | |
| `youtube.com` / `img.youtube.com` | Mock videos + thumbnails | |
| Cloudflare Workers / `workers.dev` | **None** | |

No Cloudflare zone, Worker, or R2 binding appears in this client.

---

## 7. Android `app/build.gradle.kts`

File: `android/app/build.gradle.kts`.

| Setting | Value |
| --- | --- |
| `namespace` | `com.visionmusic.app` |
| `applicationId` | `com.visionmusic.app` |
| `compileSdk` | `flutter.compileSdkVersion` (SDK-provided; Flutter not installed in this audit environment, so the numeric value is not re-resolved here) |
| `minSdk` | `flutter.minSdkVersion` (comment: required by `audio_service` FGS) |
| `targetSdk` | `flutter.targetSdkVersion` |
| `versionCode` / `versionName` | `flutter.versionCode` / `flutter.versionName` ← `pubspec` `1.0.0+3` |
| Java / Kotlin | 17 |
| Plugins | `com.android.application`, `com.google.gms.google-services` **4.3.15**, `com.google.firebase.crashlytics` **2.8.1**, Kotlin **2.2.20**, Flutter Gradle plugin |
| AGP | **8.11.1** (`android/settings.gradle.kts`) |
| R8 | release `isMinifyEnabled` + `isShrinkResources`; `proguard-rules.pro` keeps Flutter/Firebase/`audio_service` |

**Signing:**

- Release config is created only if `android/key.properties` exists (gitignored). Fields: `keyAlias`, `keyPassword`, `storeFile`, `storePassword`.
- `buildTypes.release.signingConfig = signingConfigs["release"]` even when the file is missing — a Play/upload build without `key.properties` will fail or be unsigned. Debug uses the default debug keystore (no explicit `debug` signing block).
- Keystore files `*.jks` / `*.keystore` are gitignored. **Not inspected, not modified.**

Manifest (`android/app/src/main/AndroidManifest.xml`): `INTERNET`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `POST_NOTIFICATIONS`. **No `RECORD_AUDIO`.** Recognition still requests `Permission.microphone` in Dart.

---

## 8. Security rules patterns

Both rule files are versioned and wired in `firebase.json`. Both files say **`NOT YET DEPLOYED`** (written 2026-08-11). Console state was **not** queried in this audit. TestFlight checklist still has “backend team deploys … rules” unchecked.

### 8.1 Dangerous `allow if true`?

**There is no blanket `allow read, write: if true`.** Default match is deny:

```
match /{document=**} { allow read, write: if false; }   // firestore
match /{allPaths=**} { allow read, write: if false; }   // storage
```

**Intentional public-read (not world-write):**

| Rule | File | Risk |
| --- | --- | --- |
| `songs/{id}` `allow read: if true` | `firestore.rules` | Catalog metadata world-readable (by design). Writes denied. |
| `videos/{id}` `allow read: if true` | same | Same. **Does not check `isPublished`** — unpublished docs are readable if the ID is known. App filters `isPublished` client-side only. |
| `videoCategories/{id}` `allow read: if true` | same | Same. |
| `artwork/**` `allow read: if true` | `storage.rules` | Public artwork (by design). Writes denied. |

These are **not** the 30-day test-mode pattern. They are still “anyone on the internet can enumerate public catalog metadata” once rules are deployed.

### 8.2 Other rule vs code gaps

- Client `videos` write (`incrementViewCount`) vs `allow write: if false`.
- `users/**` rules unused; user data is on-device.
- Proposed ingestion collections not listed; default-deny covers them.
- `firestore.rules` comment: catalogue writes only via console / Admin SDK / Cloud Functions. Admin SDK path exists in `tools/import_youtube_videos.py`; Functions path does not exist in this repo and needs Blaze.

---

## 9. Findings (config / code only)

Billing (closed account / `billingEnabled=false`) is **P0-0**, already identified, owned by parent. Listed first so nothing is lost, then **new** items from this pass.

### P0 — Critical

| ID | Finding | Evidence |
| --- | --- | --- |
| **P0-0** | **Billing already identified.** `visionmusic-dev` `billingEnabled=false`; linked account VisionMusic Cloud `OPEN=false`. Blocks Blaze-only products (Cloud Functions, Cloud Run ingest, paid Storage/Firestore overage, some App Check / Play Integrity production paths). Parent handling separately. | Mac diagnostics; code/docs in §6.2 assume those products |
| **P0-1** | **Repo security rules are explicitly undeployed.** If the console still has test-mode or open rules, Auth/Firestore/Storage are already initialized on device (options are real, not placeholders) and `VideoService` queries Firestore on every Watch-tab load. Cannot confirm console from git; treat deploy-vs-console drift as release-blocking until verified. | `firestore.rules` L18–19; `storage.rules` L11–12; `FirebaseBootstrap.initialize`; `VideoServiceLocator.init()` in `main.dart` |
| **P0-2** | **Google Sign-In cannot succeed with the committed client configs.** Android `oauth_client` is empty; iOS plist lacks `CLIENT_ID` / `REVERSED_CLIENT_ID`; iOS `Info.plist` has no Google URL scheme. The login button is enabled whenever placeholders are absent. | `android/app/google-services.json`; `ios/Runner/GoogleService-Info.plist`; `ios/Runner/Info.plist`; `login_screen.dart` |

### P1 — High

| ID | Finding | Evidence |
| --- | --- | --- |
| **P1-1** | **Guest vs Storage auth.** First-class guest path never signs in; Storage `audio/**` and `video/**` require `isSignedIn()`. Flipping `useFirebaseCatalog` to `gs://` audio will break guest playback. | `login_screen.dart` `_continueAsGuest`; `storage.rules` L42–50; `AppConfig.useFirebaseCatalog` |
| **P1-2** | **Music recognition is wired to loopback and requires a logged-in user.** Production/TestFlight Identify hits `http://127.0.0.1:8081`. No `RECORD_AUDIO` in the main Android manifest; no `NSMicrophoneUsageDescription` in iOS `Info.plist`. | `lib/main.dart` L76; `recognition_repository.dart` L21–24; `AndroidManifest.xml`; `ios/Runner/Info.plist` |
| **P1-3** | **Firestore composite indexes file is empty.** Watch-tab queries (`isPublished` + `orderBy releaseDate`, featured, category) will fail in production Firestore and silently fall back to mocks — easy to misread as “Firebase is working.” | `firestore.indexes.json`; `video_service.dart` L50–114 |
| **P1-4** | **No session restore / no sign-out UI.** Every cold start shows login; `signOut()` has no caller. | `VisionMusicApp.home`; `auth_service.dart`; `profile_hub_screen.dart` |
| **P1-5** | **Apple Sign-In absent** while Google is offered (App Store guideline cited in the project’s own migration plan). | `auth_service.dart`; `docs/FIREBASE_MIGRATION_PLAN.md` L42 |
| **P1-6** | **Service-account key drop path was not gitignored.** Import docs tell operators to put `tools/firebase-key.json` in-tree. Mitigated in this PR by `.gitignore` only — no key was present. | `tools/HOW_TO_IMPORT_VIDEOS.md`; previous `.gitignore` |
| **P1-7** | **Single Firebase project, no prod project in config.** `vision-music-prod` was planned; the app only knows `visionmusic-dev`. Dev DB = whatever ships. | `firebase_options.dart`; `docs/FIREBASE_MIGRATION_PLAN.md` |
| **P1-8** | **Unpublished video documents are world-readable** under proposed/current rules (`read: if true`, no `isPublished` in rules). Client filter is not a security boundary. | `firestore.rules` L46–48; `video_service.dart` L153–155 (`fetchVideoById` does not check `isPublished`) |
| **P1-9** | **AI / YouTube / translation keys in client files (unfilled).** Filling `_geminiApiKey` or `YouTubeConfig.apiKey` would ship secrets in the IPA/APK. Comments already say use Functions — Functions need Blaze (P0-0). | `ai_translation_service.dart`; `music_metadata_ai_service.dart`; `youtube_config.dart` |

### P2 — Medium / hygiene

| ID | Finding | Evidence |
| --- | --- | --- |
| **P2-1** | macOS Firebase app is the **iOS** appId (analytics/App Check mis-attribution). | `firebase_options.dart` L46–53; `firebase.json` macos block |
| **P2-2** | Windows/Linux Firebase options still placeholders. | `firebase_options.dart` L54–68 |
| **P2-3** | AI Music Assistant is orphaned (no route, no `MusicAiClient` impl). | `lib/features/ai_music_assistant/**` vs no references from `main_shell` / search / profile |
| **P2-4** | Dual playlist controllers; `AudioManager.playlists` always empty; “Add to playlist” constructs a **new** controller and `load()` without awaiting. | `audio_manager.dart` L45; `song_more_options_button.dart` L108–109 |
| **P2-5** | Download is a boolean flag, not offline media. | `audio_manager.dart` L460–464 |
| **P2-6** | `FirestoreSongModel` and `VideoRepositoryFactory` unused by the shell (hub uses `VideoService`; songs use `FirestoreSongRepository`). Query field names disagree (`releaseDate` vs `publishedAt`). | `video_repository.dart`; `video_service.dart`; `firestore_song_model.dart` |
| **P2-7** | `incrementViewCount` dead + would be rules-denied. | `video_service.dart` L167–176 |
| **P2-8** | Web chrome still `vision_music_clean` (index.html title, `web/manifest.json`). | `web/index.html`; `web/manifest.json` |
| **P2-9** | Stale `FIREBASE_SETUP.md` vs live `visionmusic-dev`. | repo root |
| **P2-10** | No in-app account deletion UI despite `users/{id}` `allow delete` and store requirements mentioned in rules comments. | `firestore.rules` L65–66; profile hub |
| **P2-11** | Mock / seed YouTube URLs still contain `REPLACE_*` placeholders; player treats them as unplayable. | `lib/mock_videos.dart`; `VIDEO_LINKS_TO_FILL_IN.md` |
| **P2-12** | App Check debug provider in non-release — correct for simulators; must not ship as the only provider, and enforcement is still console-side. | `firebase_bootstrap.dart` L72–79 |
| **P2-13** | `AuthService.isFirebaseReady` ignores bootstrap **failure** (configured-but-error). | `auth_service.dart` L11 vs `FirebaseBootstrapResult.isReady` |
| **P2-14** | macOS copyright `com.example` leftover. | `macos/Runner/Configs/AppInfo.xcconfig` L14 |

---

## 10. What this audit did **not** do

- Did not deploy rules, indexes, or Functions.
- Did not open Firebase/GCP billing, IAM, or App Check enforcement.
- Did not change `applicationId`, bundle ID, signing, or `key.properties`.
- Did not enable `useFirebaseCatalog`.
- Did not run `flutter test` / `flutter analyze` (Flutter SDK not present in this environment).
- Did not treat Firebase **client** API keys in `firebase_options.dart` / `google-services.json` as secrets (they are public client identifiers; **rules + OAuth client restrictions** are the boundary).

---

## 11. Suggested next actions (human / billing parent)

1. Keep P0-0 on the billing owner; do not implement Cloud Functions / Cloud Run until Blaze is actually open.
2. Diff console Firestore/Storage rules against the repo files; deploy to **dev** only after that diff.
3. Register Android SHA-1/256 and iOS OAuth clients; regenerate FlutterFire configs (do not hand-edit package IDs).
4. Decide guest streaming policy **before** turning on `useFirebaseCatalog`.
5. Replace recognition `127.0.0.1:8081` with a real, authenticated endpoint (Blaze-dependent if it is a Function).
6. Add the video composite indexes or stop querying Firestore until they exist.

---

## 12. File index (live code, not `_archive`)

```
lib/main.dart                          entry, providers, catalog flag, recognition URL
lib/app/main_shell.dart                5-tab IndexedStack + mini-player
lib/firebase_options.dart              visionmusic-dev (+ Win/Linux placeholders)
lib/core/services/firebase_bootstrap.dart
lib/core/services/app_config.dart      useFirebaseCatalog = false
lib/core/services/app_observability.dart
lib/core/services/firestore_song_repository.dart
lib/core/services/public_catalog_policy.dart
lib/core/services/media_source_resolver.dart
lib/core/services/video_service.dart   videos + videoCategories
lib/features/auth/{login_screen,auth_service}.dart
lib/audio_manager.dart + lib/audio/audio_handler.dart
lib/features/ai_music_assistant/**     unwired
firestore.rules / storage.rules / firebase.json / firestore.indexes.json
android/app/build.gradle.kts
```
