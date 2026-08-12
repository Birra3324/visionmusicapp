# Handoff Prompt — VisionMusic Production QA Pass

Run this with Claude Code from a terminal on the Mac that has Flutter, Xcode, and the iPhone attached:

```bash
cd /Users/birragemedi/Desktop/visionmusicapp
claude
```

Then paste everything below the line.

---

You are performing a production-readiness QA pass on VisionMusic, a Flutter music app in this repository. Audit thoroughly, diagnose every confirmed issue, implement safe minimal fixes, and verify the result on the connected physical iPhone.

## Non-negotiable constraints

- Preserve all existing work. The working tree is dirty on `main` and that is expected — never run `git reset`, `git checkout -- .`, `git stash drop`, or `git clean`. Do not revert unrelated modifications.
- Inspect the current implementation before editing any file.
- Make focused, minimal changes. No refactors of working code.
- Do not add placeholder controls, "coming soon" text, debug banners, or developer notices to production UI.
- Keep the existing premium visual identity: black, warm white, burgundy, gold. See `lib/vision_theme.dart`.
- Never claim something works unless you actually ran it or observed it. If you could not test something, say so explicitly and list it as unverified.
- Do not weaken tests or add `// ignore:` comments to silence the analyzer instead of fixing the cause.

## Repository orientation

Read these before you start, they contain prior findings and will save you time:
`TECHNICAL_AUDIT_2026-08-10.md`, `FINALIZATION_PLAN.md`, `VISION_MUSIC_MVP_CHECKLIST.md`, `LOCALIZATION_FIX_SUMMARY.md`, `VIDEO_FEATURE_SUMMARY.md`, `FIREBASE_SETUP.md`, `YOUTUBE_SETUP.md`.

Key source areas:

- Entry and shell: `lib/main.dart`, `lib/app/main_shell.dart`
- Audio: `lib/audio_manager.dart`, `lib/audio/audio_handler.dart`, `lib/settings_manager.dart`
- Now playing / mini-player: `lib/now_playing_screen.dart`, `lib/widgets/mini_player.dart`
- Video: `lib/features/video/*`, `lib/core/services/video_service.dart`, `video_repository.dart`, `youtube_repository.dart`, `youtube_config.dart`
- Data: `lib/core/services/song_repository.dart`, `local_song_repository.dart`, `firestore_song_repository.dart`, `app_config.dart`, `firebase_bootstrap.dart`
- Screens: `lib/gold_discover_screen.dart`, `lib/features/search/search_hub_screen.dart`, `lib/features/library/library_hub_screen.dart`, `lib/features/profile/profile_hub_screen.dart`, `lib/playlists_screen.dart`, `lib/playlist_detail_screen.dart`
- Localization: `lib/l10n/app_localizations*.dart` (en, om, am, ar, es, fr), `l10n.yaml`
- Catalog: `lib/mock_songs.dart`, `lib/mock_videos.dart`

`lib/_archive/**`, `backup-catalog-fix/**`, `_audit-backup-*`, and `_recovered-from-apk/` are excluded from analysis. Do not fix or modify them; do confirm nothing in `lib/` still imports from them.

Already verified statically — do not spend time re-checking: all 8 audio and 7 image asset paths referenced by `lib/mock_songs.dart` resolve to files that exist on disk. Note `assets/audio/lagaa.m4a` appears orphaned (no code reference); confirm before removing, and prefer leaving it.

iOS signing is already configured: team `A28Z9442CF`, bundle id `com.visionmusic.app`, automatic signing.

## Required workflow, in order

1. `git status` and save the output so you can prove at the end that you destroyed nothing.
2. `flutter --version`, `flutter pub get`, then `flutter analyze` and `flutter test`. Record the full baseline output verbatim before touching anything.
3. Run the app on the physical iPhone (`flutter devices`, then `flutter run -d <device-id>`) and drive it while watching logs. Reproduce each suspected defect before fixing it.
4. Fix only confirmed issues. For each fix, state what you observed that proved the bug.
5. Add regression tests for every meaningful logic fix. Current tests are `test/audio_manager_persistence_test.dart`, `test/song_test.dart`, `test/widget_test.dart` — follow their existing style.
6. `dart format lib test`, then `flutter analyze` and `flutter test` again. Both must be clean.
7. Build a signed iOS release: `flutter build ipa --release` (or `flutter build ios --release` then archive). Report any signing failure verbatim rather than working around it.
8. Install and launch on the connected iPhone. Confirm the installed build matches current source — bump or read `version:` in `pubspec.yaml` (currently `1.0.0+3`) and verify the running build number, or add a build-stamp assertion you can observe at runtime without adding visible UI clutter.

## Audit scope

**Audio playback.** Play/pause; seek and progress updates; next/previous; shuffle, repeat, autoplay; queue behavior; rapid track switching; missing or invalid audio files; background playback; lock-screen and Control Center controls; interruptions (phone call, other app audio) and resume on return. Verify `audio_service` and `audio_session` are configured correctly for iOS background audio and that the `UIBackgroundModes` audio entitlement is present in `ios/Runner/Info.plist`.

**Video.** Featured carousel; video search; direct playback; YouTube links; related videos; full-screen enter/exit; returning from playback; invalid, missing, and unpublished URLs; and confirm audio actually pauses when a video starts.

**Navigation and layout.** Home, Watch, Library, Search, Profile. Mini-player behavior on every screen. Bottom nav safe-area handling. Nothing hidden behind the mini-player or nav bar. No clipped tabs, cards, labels, or metadata. Test small iPhones (SE), large iPhones (Pro Max), landscape where supported, large accessibility text sizes, and RTL layout under Arabic.

**Search and library.** Search by title, artist, album. Suggestion chips. Empty and no-results states. Favorites, saved songs, recent history, offline status. Playlist creation and editing. Persistence across a full app kill and relaunch.

**Settings and localization.** Language switching across English, Afaan Oromo, Amharic, Arabic, French, Spanish. RTL correctness. Autoplay, shuffle, repeat persistence. Find any setting or control that is wired to nothing and either make it work or remove it — do not leave dead controls in the UI.

**Stability.** Rapid navigation, repeated play/pause, opening and closing screens many times, missing artwork fallbacks, network failure states, Firebase unavailable or unconfigured, guest mode, startup and shutdown. Watch for unhandled exceptions, RenderFlex overflow warnings, and controller/stream leaks from missing `dispose()`.

## Deliverable

A final report containing: confirmed problems found (with the evidence that confirmed each), exact fixes implemented, files changed, tests added, analyzer and test results before and after, the iOS build and iPhone install result, and remaining risks or features that still require backend configuration (Firebase, YouTube API key, Firestore rules and indexes).

Do not stop at recommendations. Implement and verify every safe in-scope fix. Anything you could not verify on device must be listed plainly as unverified.
