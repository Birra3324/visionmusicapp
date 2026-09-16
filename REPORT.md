# Vision Music overnight report — 2026-09-16

**App:** Vision Music Flutter listener client  
**Branch:** `cursor/overnight-audit-release-724e`  
**Base:** `origin/main` @ `fa04db3`  
**Head:** this PR  
**Mode:** no Play Store publish, no paid GCP/billing changes, no secrets committed  

Evidence below is from this Cloud Agent VM (`Flutter 3.47.4` / `Dart 3.13.3`). Device playback, Play Console, and live Google Sign-In were **not** exercised on a phone.

---

## Snapshot (current HEAD vs prior notes)

| Item | Prior notes | This pass |
| --- | --- | --- |
| `pubspec.yaml` version | `1.0.0+3` | **`1.0.1+5`** |
| External AAB | operator-built **`1.0.1+4`** (not in git) | Repo did **not** contain `1.0.1+4`. Next Play `versionCode` must be **≥ 5** if `+4` was or will be uploaded. This PR is `+5`. |
| Android `applicationId` / namespace | `com.visionmusic.app` | **VERIFIED** `android/app/build.gradle.kts` |
| iOS bundle id | `com.visionmusic.app` | **VERIFIED** `ios/Runner.xcodeproj` + `GoogleService-Info.plist` `BUNDLE_ID` |
| Firebase project id | `visionmusic-dev` | **VERIFIED** `firebase.json`, `google-services.json` `project_id`, iOS `PROJECT_ID`, Android/iOS/Web `DefaultFirebaseOptions` (values not printed) |
| Catalog default | `useFirebaseCatalog = false` | **VERIFIED** `lib/core/services/app_config.dart` + `test/app_config_test.dart` |
| Auth | Guest + Google | Guest **VERIFIED** in widget test. Google Sign-In production wiring **BLOCKED** (see below). |
| Tests (prior Mac) | 71 passed | **87 passed** this VM |

Client Firebase API keys remain in-tree as standard FlutterFire public client keys. This report does **not** reprint them.

---

## VERIFIED

### `flutter analyze`
```
$ flutter analyze
Analyzing workspace...
No issues found! (ran in 10.0s)
```

One pre-existing warning (`unawaited_return_in_try_block` in `youtube_repository.dart`) was fixed with `await` so exceptions from `_convertYouTubeItem` are actually caught. Re-analyze after the fix: **No issues found.**

### `flutter test`
```
$ flutter test --reporter compact
All tests passed!
```
Final counter: **+87**. Prior documented baseline was 71. New coverage: catalog bootstrap, AppConfig defaults, AuthService readiness, guest login UI, guest Profile (no AI / no sign-out), recognition mic flag, `UnavailableMusicAiClient`.

Existing suites still passing: Song equality, mock catalog, video playability, media source resolver, queue mutation, audio persistence, public catalog policy, AI validator/service, localization.

### Catalog mode
`AppConfig.useFirebaseCatalog = false` and `fallbackToLocalOnEmpty = true`. Startup now goes through `CatalogBootstrap.load` (behavior-preserving extract). Tests prove: flag off → local; Firebase not ready → local; empty remote + fallback → local.

### Guest login / Profile
- `LoginScreen(firebaseReady: false)` shows **Continue as Guest** and **Sign in temporarily unavailable** (`test/login_guest_test.dart`).
- Guest Profile shows **Guest listener**, privacy row, **no** sign-out, **no** AI tile by default (`test/profile_hub_guest_test.dart`).
- `AuthService.isFirebaseReady` is false until `Firebase.initializeApp` has actually created an app (`test/auth_service_test.dart`). Previously, present Android/iOS options made Google Sign-In look ready even after a failed/skipped bootstrap.

### AI Music Assistant (stub, no invented URL)
No production `MusicAiClient` HTTP implementation exists under `lib/` (grep: no `http://` / `https://` in `music_ai_*.dart`).

Smallest safe wiring:
- Flag `ENABLE_AI_MUSIC_ASSISTANT` (default **false**).
- When on, Profile shows a tile that opens `AiMusicAssistantScreen` with `MusicAssistantService.unavailable()` → `UnavailableMusicAiClient` (throws, **no network**).

Live generation remains unavailable until a real backend URL exists in a private repo. Billing on `visionmusic-dev` is **CLOSED** (prior diagnosis); do not expect Cloud Functions.

### Music recognition UI
Search mic is hidden unless `ENABLE_MUSIC_RECOGNITION=true`. Default-off verified. The repository still hardcodes `http://127.0.0.1:8081` — not a production host.

### Signing hygiene
- `.gitignore` includes `android/key.properties`, `*.jks`, `*.keystore`.
- `android/key.properties.example` committed with placeholders only (`YOUR_STORE_PASSWORD`, alias `upload`).
- This VM: **`android/key.properties` ABSENT**, **`upload-keystore.jks` ABSENT** (expected).
- `git grep` for private-key / keystore password patterns in tracked non-example files: **no matches**.

### Permissions (code)
- Android: existing playback FGS + `RECORD_AUDIO` declared (identification / `record` plugin).
- iOS: `NSMicrophoneUsageDescription` added.

---

## PARTIALLY VERIFIED

### Playback
Queue/favorites/recent persistence and Song `id` equality (the Firestore `indexOf` footgun) are covered by unit tests. **Actual audio playback, lock-screen controls, and background audio were not run on a device or emulator** (no Android SDK on this VM).

### Google Sign-In (client files)
Configs exist for `com.visionmusic.app` / `visionmusic-dev`. **Committed** `google-services.json` has `oauth_client: []`. iOS `GoogleService-Info.plist` has **no** `CLIENT_ID` / `REVERSED_CLIENT_ID`. `Info.plist` has **no** `CFBundleURLTypes` for Google Sign-In. Guest path does not need these.

Treat production Google Sign-In as **not store-ready** until SHA fingerprints + OAuth clients are in Firebase and regenerated configs (operator / console). Do not paste those values into git beyond FlutterFire’s usual public client files.

### Privacy policy URL
Profile links to `https://www.visionmusic.et/privacy.html` (documented marketing URL). From this VM:
```
curl -L https://www.visionmusic.et/ …
→ SSL: no alternative certificate subject name matches target host name 'www.visionmusic.et'
```
Play Console still needs a **live HTTPS** privacy URL. TLS on the marketing site is an operator fix.

### Version vs external AAB `1.0.1+4`
Git `main` was `1.0.0+3`. The `1.0.1+4` AAB is **not** in this repository (no matching tag/commit). This PR bumps to **`1.0.1+5`** so a future Play upload cannot reuse `versionCode` 4. If `+4` was never uploaded, `+5` is still a safe monotonic choice.

### `flutter doctor`
Flutter SDK **OK**. Android toolchain **missing** (no Android SDK). Linux desktop incomplete (ninja/GTK). Cannot `flutter build appbundle` here.

---

## BLOCKED

| Item | Why | What would unblock |
| --- | --- | --- |
| Play-signed AAB on this VM | No Android SDK; no `key.properties` / keystore (correctly gitignored) | Operator machine with SDK + local keystore. Copy from `android/key.properties.example`. **Do not commit secrets.** |
| Play production publish | Explicit RED gate | Human approval in Play Console. **Not done.** |
| Firebase Blaze / Cloud Functions / paid APIs | Billing account **CLOSED** (`visionmusic-dev` `billingEnabled: false`) per 2026-09-14 diagnosis | New/open billing account + link project. **Not attempted.** |
| Live AI generate | No backend URL in this repo; billing would also block Functions | Private CF/API + `MusicAiClient` impl. Flag is ready. |
| Production music identification | Hardcoded `127.0.0.1:8081`; guests also cannot recognize (repo requires logged-in user) | Real host + auth policy. Flag stays off until then. |
| Production Google Sign-In | Empty Android `oauth_client`; iOS missing `CLIENT_ID` / URL scheme | Firebase console SHA + OAuth, then `flutterfire configure` |
| Firebase catalog in prod | Flag still `false` (intentional) | Published Firestore songs + rules + then flip flag |
| Device / emulator smoke | No Android SDK, no emulator | Physical device or operator Mac |
| Privacy URL for store listing | TLS name mismatch on `visionmusic.et` from this VM | Fix cert / confirm live `privacy.html` |

---

## Android production AAB checklist (honest)

1. **Identity** — `com.visionmusic.app` OK. Version in git is now `1.0.1+5` (`versionName` 1.0.1 / `versionCode` 5). Reconcile Play Console: if `4` already uploaded, this is the next code; if not, still do not reuse `1.0.0+3`.
2. **Signing** — `buildTypes.release` uses `signingConfigs.release` from `android/key.properties` when present. **Missing on this VM.** Release build will not be Play-signed here. Gradle prints a warning when the file is absent.
3. **ProGuard** — `isMinifyEnabled = true`; rules exist for Flutter/Firebase/audio/Google Sign-In. **Not** validated with a release run.
4. **Permissions / Data safety** — INTERNET, network state, WAKE_LOCK, FGS media playback, POST_NOTIFICATIONS, RECORD_AUDIO. Declare microphone + analytics/crashlytics on the Play Data safety form. The `record` plugin can still merge mic permission even when the Identify UI is flagged off.
5. **Privacy** — in-app link added; **site TLS unverified**.
6. **Firebase** — client project is **`visionmusic-dev`**, not a separate production project. App Check uses Play Integrity in release. Catalog stays **local mock**.
7. **Do not submit** to Play production from this work.

---

## What was intentionally not done

- No Play Console click / upload / promote.
- No `gcloud` billing mutations, Blaze upgrade, or Functions deploy.
- No invented Music Assistant or recognition base URL.
- No commit of keystores, `key.properties`, or secret API keys.
- Catalog flag left `false` (demo catalog remains bundled).

---

## Commands (this VM)

```
flutter --version
# Flutter 3.47.4 • Dart 3.13.3

flutter pub get
flutter analyze          # No issues found
flutter test             # All tests passed! (+87)
flutter doctor -v        # Flutter OK; Android SDK missing
```
