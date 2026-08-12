# Vision Music MVP Checklist

## Current Project Status (updated April 21, 2026)
- Flutter app with shared codebase for iOS, Android, macOS, Web
- Feature-based structure under `lib/features/` + `lib/app/main_shell.dart`
- Core navigation: Home / Library / Search / Profile
- Audio playback foundation (just_audio + audio_service + audio_session)
- Search works on local mock catalog (9 demo tracks)
- Playlist flow exists (create / detail)
- Login screen with guest mode + optional Google sign-in
- Firebase scaffolding present, real project values configured for Android/iOS/macOS
- Dead code archived to `lib/_archive/` — 22 files trimmed from the live tree

## MVP Goal
Ship a polished Vision Music demo/MVP that feels real, branded, and stable enough for
internal demos, testing, and investor/partner presentation.

## Phase 1 — Stabilize the Existing App
- [x] Fix analyzer warnings that affect maintainability (deprecated `withOpacity`, `ColorScheme.background`)
- [x] Remove dead imports and obviously unused files (archived to `lib/_archive/`)
- [x] Consolidate active screens into one clear structure (flat layout archived, features/ is canonical)
- [x] Make background/image loading safer (VisionBackground now has `errorBuilder` on the asset)
- [ ] Verify app opens cleanly on macOS and Android *(requires running on your Mac)*
- [ ] Add a basic empty/error state strategy for main sections *(search has one; library/home still need)*

## Phase 2 — Core User Flow
- [x] Keep guest mode working well
- [ ] Decide whether Google sign-in is part of MVP or postponed
- [ ] If included, finish Google sign-in (Firebase values are already live for Android/iOS)
- [x] Improve login screen branding and onboarding copy (already good)
- [x] Add a clear path from login to home experience

## Phase 3 — Music Experience
- [ ] Polish Home / Discover screen (works; could add real trending data)
- [ ] Finish Library tab (hub exists; Favorites + Recently Played still pending)
- [x] Improve Search tab with better states and UX
- [x] Confirm mini player and now playing flow are stable
- [ ] Add artist browsing and artist detail improvements
- [ ] Add album browsing flow (list exists, no detail screen yet)
- [ ] Add favorites or liked songs (AudioManager has the fields; no UI hookup)
- [ ] Improve playlist creation and editing UX

## Phase 4 — Content & Data
- [ ] Decide final MVP data source
- [ ] Option A: polished local demo catalog (current state, 9 tracks)
- [ ] Option B: Firebase-backed catalog
- [ ] Add structured song metadata model
- [ ] Add artist metadata model
- [ ] Add album metadata model
- [ ] Add cover art/content validation

## Phase 5 — Video Module
- [x] Decide whether Video stays in MVP navigation *(cut from MVP — archived)*
- [ ] If re-added, build basic video catalog screen
- [ ] If re-added, add video detail/player strategy

## Phase 6 — Firebase Preparation
- [x] Add Firebase project for Vision Music (project `visionmusic-dev`)
- [x] Configure Android package (`com.visionmusic.app`)
- [x] Configure iOS bundle
- [x] Add FlutterFire CLI setup *(options file generated)*
- [ ] Connect Firebase Auth *(scaffolded; enable Google provider in console)*
- [ ] Connect Firestore for catalog metadata
- [ ] Connect Storage for audio/artwork/video assets
- [ ] Define content collections and security rules

## Suggested Firebase Collections
- users
- artists
- albums
- songs
- playlists
- featured_sections
- app_config

## Admin / Operations Later
- [ ] Content publishing workflow
- [ ] Artist upload flow
- [ ] Moderation/review workflow
- [ ] Analytics and reporting
- [ ] Subscription/payment system

## Immediate Recommended Next Steps
1. Open project on Mac, run `flutter clean && flutter pub get`
2. Run `flutter analyze` — confirm warning count is low
3. Run `flutter run -d macos` (fastest sanity check) then `flutter run -d <iPhone>`
4. Decide MVP auth scope (guest-only, or guest + Google)
5. Decide local-demo vs Firebase-backed content
6. Follow `FINALIZATION_PLAN.md` for the shipping steps
