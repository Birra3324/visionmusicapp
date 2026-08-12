# VisionMusic — Finalization Plan

A concrete, numbered checklist to take the app from its current state to a shippable
MVP. Split into what's already done, what you need to run on your Mac, decisions you
need to make, and the actual App Store / TestFlight flow.

---

## 1. What was cleaned up in this pass

**Code structure**
- Archived **22 dead/duplicate files** from `lib/` into `lib/_archive/` (see
  `lib/_archive/README.md` for the full mapping). The live tree dropped from ~46 Dart
  files to 20.
- Added an `analyzer.exclude` block to `analysis_options.yaml` so the archive folder
  is ignored by `flutter analyze`.

**Real bugs fixed**
- `lib/now_playing_screen.dart` — replaced deprecated `Colors.black.withOpacity(0.60)`
  with `Colors.black.withValues(alpha: 0.60)` (matches the rest of the codebase and
  removes a deprecation warning).
- `lib/vision_theme.dart` — removed deprecated `ColorScheme.background` field; added
  `onSurface: kTextMain` so text contrast is explicit.
- `lib/gold_discover_screen.dart` — removed a redundant nested `const` that was a
  style nit flagged by the linter.

**UX polish**
- `lib/widgets/vision_background.dart` — previously just a flat dark color. Now
  actually renders the `assets/images/bg_gold_4k.png` asset with a translucent dark
  overlay on top (configurable opacity) so every screen wrapped in `VisionBackground`
  gets the branded gold feel without killing readability. Falls back to a flat color
  if the image fails to load.

**Docs refreshed**
- `VISION_MUSIC_MVP_CHECKLIST.md` is updated to mark completed items and note open
  decisions.

---

## 2. Verify on your Mac (do this first)

Run these in order. If any step fails, that's where to focus next.

```bash
cd ~/Desktop/visionmusicapp

# 1. Confirm you're on a supported Flutter/Dart SDK
flutter --version                 # should be >= 3.22
flutter doctor                    # no red checks on iOS / macOS / Android sections

# 2. Clean and reinstall dependencies
flutter clean
flutter pub get

# 3. Reinstall iOS pods (only needed for iOS/macOS)
cd ios && pod install --repo-update && cd ..
cd macos && pod install --repo-update && cd ..

# 4. Static analysis — should be much quieter now
flutter analyze

# 5. Fastest way to smoke-test the app
flutter run -d macos
# Then, on a real device or simulator:
flutter run -d "iPhone 15 Pro"     # or whichever is booted
```

If `flutter analyze` still shows warnings, paste them into our chat and I can go fix
them.

---

## 3. Decisions you need to make before shipping

Each one is a short fork. Decide, then I (or you) act on the decision.

### Decision A — Auth scope for MVP
- **Guest only (simpler, ships sooner)**: remove the Google button entirely; login
  screen becomes a splash with "Enter Vision Music" CTA.
- **Guest + Google (a little more work)**: enable Google as a sign-in provider in the
  Firebase console (Authentication → Sign-in method → Google), add your support email,
  and test the flow on a real iOS device (simulator's Google flow is flaky).

### Decision B — Data source for MVP
- **Local demo catalog (shippable today)**: current 9-track mock stays. Ideal for
  investor demos, no backend risk. Everything in `lib/mock_songs.dart`.
- **Firebase-backed catalog (more realistic, more work)**: create `songs`, `artists`,
  `albums` collections in Firestore, upload audio to Storage, and swap `mock_songs.dart`
  for a repository class that streams from Firestore. ~2–3 days of focused work.

### Decision C — Video module for MVP
- Currently **cut** (archived). Re-add it only if the demo narrative needs it. The
  source is at `lib/_archive/features_video/video_hub_screen.dart`.

### Decision D — Target platforms for MVP
- **iOS + Android** (typical): package as usual.
- **iOS + macOS + Android**: Mac build already works; just decide whether to distribute
  it. macOS distribution outside the App Store requires signing + notarization.

---

## 4. Polish items still worth doing (after verification)

These are small, high-impact wins if you have a few hours:

1. **Library favorites UI** — `AudioManager` already has `toggleFavorite` / `favoriteSongs`.
   Add a "Favorites" section to `library_hub_screen.dart` that lists `audioManager.favoriteSongs`,
   and add a heart toggle to `SongRow`/`_SearchResultRow`.
2. **Recently played** — track the last N songs in `AudioManager` (append to a
   `List<Song> _recent` in `playSong`), render in Library and in Discover.
3. **Sign-out flow** — `auth_service.dart` has `signOut()` but nothing calls it.
   Add a "Sign out" row in Profile that pops back to `LoginScreen`.
4. **Empty state for Library hub** — show a friendly "Your library is empty. Play a
   song to get started." when `audioManager.library` is empty.
5. **Real Firebase gate** — the current `hasPlaceholderConfig` check only inspects
   Android. Harden it to also reject any platform whose `apiKey` starts with `REPLACE_WITH_`.
6. **Remove unused AudioManager stubs** — `createPlaylist`, `addToQueue`, `playNext`,
   `removeFromQueue` are currently no-ops. Either implement or delete to avoid dead API surface.

---

## 5. App Store / TestFlight shipping (iOS)

This all runs on your Mac. Allow ~90 minutes the first time.

### 5a. Prep in Xcode
```bash
open ios/Runner.xcworkspace
```
In Xcode:
1. Select the `Runner` target → *Signing & Capabilities*. Set Team to your Apple
   Developer account. Bundle Identifier should be `com.visionmusic.app`.
2. Set version and build in *General* (e.g. 1.0.0, build 1).
3. If using push notifications or Google Sign-In, add URL Schemes from your
   `GoogleService-Info.plist` to the `Info.plist` → `CFBundleURLTypes`.
4. In *Signing*, ensure "Automatically manage signing" is checked unless you're using
   a custom provisioning profile.

### 5b. Build for App Store
```bash
flutter build ipa --release
```
This outputs `build/ios/ipa/*.ipa`.

### 5c. Upload
Option 1 (easiest): open Xcode → *Window* → *Organizer* → *Distribute App* →
*App Store Connect* → *Upload*.
Option 2 (CLI): `xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios -u <appleid> -p <app-specific-password>`.

### 5d. App Store Connect
1. Log in to App Store Connect → *My Apps* → *+* → *New App*.
   Name: "Vision Music" (or your chosen name). SKU can be `visionmusic`.
   Bundle ID: pick the one matching `com.visionmusic.app`.
2. Fill required metadata: description, screenshots, keywords, support URL, privacy
   policy URL, category (Music), age rating questionnaire.
3. Under *TestFlight*, add your first build → *Start Internal Testing* → invite
   yourself / partners.
4. When ready for public release: *App Store* tab → select the build → submit for
   review.

### 5e. Screenshots you'll need
Minimum set for iPhone 6.7": 3 screenshots, 1290 × 2796 px.
Easiest path: run `flutter run --release -d "iPhone 15 Pro Max"`, take
`Device → Screenshot` in the simulator menu bar, capture Login / Discover /
Now Playing.

---

## 6. Android shipping (Google Play)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

On Play Console:
1. Create a new app → "Vision Music" → category "Music & Audio".
2. Upload the `.aab` under *Release → Internal testing → Create new release*.
3. Fill out Content rating, Target audience, Data safety, Privacy policy URL.
4. Promote from Internal → Closed → Open → Production as you test.

**Note:** Play requires a Privacy Policy URL that's live on the public internet.
A simple static page is fine.

---

## 7. Known limitations / follow-ups

- `macos` Firebase options currently copy the iOS values. That works today but a
  proper `flutterfire configure --platforms=macos` run will generate a true macOS
  app ID when you're ready.
- Google Sign-In needs real configuration to function: add your client ID to
  `ios/Runner/Info.plist` and the OAuth client IDs to Firebase Console → Project
  Settings → Your apps.
- No automated tests exist beyond the default `test/widget_test.dart`. Not a blocker
  for MVP demos but worth adding before a public launch.
- Audio is bundled inside the app (all 9 tracks live under `assets/audio/`). That's
  fine for the demo; if the catalog grows past ~50 tracks or ~100 MB, move to
  Firebase Storage streaming.

---

## 8. Quick reference — file map (after cleanup)

```
lib/
├── main.dart                    # entry point
├── vision_theme.dart            # colors + theme
├── settings_manager.dart        # persisted user settings
├── audio_manager.dart           # playback state
├── song.dart                    # Song model
├── mock_songs.dart              # demo catalog
├── firebase_options.dart        # FlutterFire config
├── gold_discover_screen.dart    # Home tab
├── now_playing_screen.dart      # Full player
├── artist_screen.dart           # Artist detail
├── playlists_screen.dart        # Playlists list
├── playlist_detail_screen.dart  # Single playlist
├── app/
│   └── main_shell.dart          # Bottom nav + tab host
├── audio/
│   └── audio_handler.dart       # OS-level media session
├── controllers/
│   └── playlist_controller.dart
├── core/
│   └── services/
│       └── firebase_bootstrap.dart
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── auth_service.dart
│   ├── library/
│   │   └── library_hub_screen.dart
│   ├── profile/
│   │   └── profile_hub_screen.dart
│   └── search/
│       └── search_hub_screen.dart
├── models/
│   └── playlist.dart
├── widgets/
│   ├── mini_player.dart
│   ├── vision_background.dart   # branded gold background
│   ├── song_row.dart
│   └── fade_route.dart
└── _archive/                    # dead code, see README there
```

---

## 9. If you get stuck

Paste the output of the failing command back here. The most common failures on a
fresh Mac checkout are:
- Missing CocoaPods (`sudo gem install cocoapods`)
- Outdated Xcode command line tools (`xcode-select --install`)
- Stale Pods — nuke with `rm -rf ios/Pods ios/Podfile.lock && cd ios && pod install`
- Flutter SDK mismatch — `flutter upgrade` or match the pubspec's `sdk: ^3.10.1`
