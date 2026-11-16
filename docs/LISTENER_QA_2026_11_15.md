# Listener QA — November 15, 2026

## Scope and source state

This pass continues the audio-catalog reset while the owner prepares original
masters from Telegram. No sample audio is restored, and no paid service,
automatic publishing, production deployment or store submission is enabled.

## Repairs

- **Language-switch crash:** Afaan Oromo lacked Flutter framework localization
  delegates. The app keeps its Oromo strings and uses an explicit English
  fallback only for framework controls Flutter does not translate. Material,
  Cupertino and Widgets delegates cover every advertised locale.
- **Text and layout:** language selection now fits at 320 px with double-sized
  text; Search scrolls with the keyboard and large text; narrow video categories
  use a single column. Play/pause and shuffle labels in Oromo and Amharic were
  corrected using the references below. This is not a full linguistic review.
- **Catalog and queue:** the full catalog, favorites and library are independent
  of the play queue. Removing or replacing queued tracks cannot remove songs
  from Search or saved collections. Failed loads clear false current-track
  metadata and expose a retry message; automatic/transport failures are caught.
- **Search:** artist suggestions come from the actual catalog. Empty audio
  search offers Watch, with no hard-coded sample artists. Search result rows
  support keyboard interaction and semantic labels.
- **Playlists:** new-playlist dialogs own and dispose their text controllers;
  creating a playlist from a song uses a live parent context after closing the
  picker. Names are trimmed, blank names rejected, IDs avoid same-tick collisions,
  and adding the same song twice is idempotent. Rename, delete (with confirmation)
  and removal of individual songs are available. Disposed controllers do not
  notify late listeners. Writes from separate dialogs/screens are serialized and
  refresh saved state before editing, preserving changes made by another open
  screen. Stable song-ID storage from the prior pass is retained.
- **Truthful offline behavior:** removed the Download action and the flag-only
  implementation that claimed a file was saved without downloading one. Library
  and favorite saving still work. Offline downloads need real file caching.
- **Startup:** invalid saved repeat modes safely fall back; guest Home and Profile
  work when Firebase is unavailable.

## Verification

The test suite covers all six locales at 320 px with 2x text, guest Home without
Firebase, keyboard-open Search, dialog-to-dialog playlist creation, full playlist
create/rename/delete, concurrent edits from separate playlist controllers,
catalog/queue separation, and invalid source/settings handling. Final analyzer,
105-test default and strict-live runs passed, with no analyzer issues. Platform
build receipts are recorded with the task output.

The release web build succeeded and its local server returned HTTP 200 for the
entry page, application JavaScript and asset manifest. The built bundle contains
zero sample audio files. Manual browser verification confirmed the repaired
Oromo Profile and navigation after reproducing the original red-screen crash.
Browser control became unavailable during the last setting-restore step, so a
final visual check of every changed screen is not claimed.

The initial iOS simulator attempt found generated Swift-package metadata at
13.0 while the project and Firebase plugins require 15.0. Regenerating iOS
configuration aligned the generated package with the existing iOS 15 project
minimum. No SDK source or global Flutter configuration was changed. Build
completion is tracked in the output receipt. The iOS simulator build passed.
Android's global license warning was for the unrelated microXR emulator package;
it was not accepted. The actual build verified the required SDK licenses were
already accepted and installed NDK 28.2.13676358, Build Tools 35 and Platform 34. Android build completion is
tracked in the output receipt. Native device playback and low-bandwidth Ethiopian
network testing remain separate release checks. Real-audio end-to-end checks
await source masters.

The pinned toolchain still warns about future Kotlin Gradle Plugin migration and
the existing custom CocoaPods integration. These require a coordinated dependency
upgrade before changing Flutter versions; they are not current app-code errors.

## References

- Android SDK package installation and licenses:
  https://developer.android.com/tools/sdkmanager

- Flutter internationalization and delegates:
  https://docs.flutter.dev/ui/internationalization
- Flutter iOS configuration regeneration for Swift-package minimum versions:
  https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers#how-to-use-a-swift-package-manager-flutter-plugin-that-requires-a-higher-os-version
- ICT Development Office / Ethiopian Languages Research Center, *Translation of
  ICT Terms into three major Ethiopian Languages*, entries 2016 (Pause key) and
  2048 (multimedia Play). Mirror of the source document:
  https://oromianeconomist.com/wp-content/uploads/2017/08/ict-glossary-in-afaan-oromoo-amharic-and-tigarinya.pdf
- LibreOffice Oromo UI uses Taphachiisi for Play:
  https://help.libreoffice.org/latest/om/text/simpress/01/06060000.html

Full Oromo/Amharic copy review by a fluent speaker remains necessary before public
release; English framework fallback is not presented as a completed translation.
