# Listener translations and slow-network checks

This pass covers the listener app while original audio masters are being
prepared. The audio catalog stays empty; the three reviewed YouTube links and
Vision Entertainment channel remain available. No paid service is introduced.

## Changes

- All six UI catalogs (English, Afaan Oromo, Amharic, Arabic, French and Spanish)
  now contain the same 156 messages. Login, Home, Library, Search, playlists,
  Watch, player controls, errors and empty states use localized copy. Song and
  artist names remain catalog content. Common Oromo framework actions are
  translated; unused framework surfaces such as date pickers retain English.
- Bundled Roboto, Noto Sans Ethiopic and Noto Sans Arabic cover all characters in
  these UI catalogs. Fonts total 717,920 bytes before compression. Licenses,
  source links and static-font conversion details are in `assets/fonts/README.md`.
  The renderer also loads from the app's own host. Neither is dependent on a
  Google font/CanvasKit CDN request for the checked screens.
- At 320 logical pixels and twice normal text size, all six locales fit the
  tested listener screens. Watch's channel/header/loading/error content scrolls;
  the featured area expands for large text. Guest labels wrap without truncation;
  shared navigation styles retain the bundled font fallback. Arabic uses
  right-to-left layout, with loader direction scoped to its HTML container so
  Flutter accessibility targets stay on-screen.
- Watch fetches categories and all published videos concurrently, then derives
  featured/category groups locally. This uses two catalog queries instead of a
  separate query for every category. Catalog requests time out after 12 seconds;
  retries discard stale results, and late responses cannot update disposed UI.
- Firebase startup and optional analytics have bounded waits. Audio source
  resolution and player initialization time out; failed loads clear the false
  playing state. Native video initialization has a 20-second limit and a retry
  control. Browser startup displays localized loading feedback, a slow-connection
  message after 20 seconds and a reload action when the initial download fails.

## Automated verification

- `flutter analyze`: no issues.
- `flutter test`: 117 passed.
- `flutter test --dart-define=USE_FIREBASE_CATALOG=true --dart-define=FALLBACK_TO_LOCAL_CATALOG=false`:
  117 passed.
- Web release, Android debug APK and iOS simulator builds passed with Flutter
  3.44.4 / Dart 3.12.2 / Xcode 26.6. Font manifests in all three builds contain
  the intended bundled families; web and APK contain zero sample audio files.
- New regressions cover translation keys and interpolation fields, web startup
  translation consistency, six-locale narrow/large-text layouts, hung catalog
  reads, one-read category grouping, timeout/retry, stale responses and leaving
  the screen during a pending request. Search semantics verify artist/title
  ordering. Existing catalog, playback-state and playlist tests remain green.

## Browser checks

The browser checks use isolated headless Chrome, a 390 x 844 viewport, fresh
contexts, disabled HTTP cache for throttled scenarios and Chrome DevTools
network emulation. They do not touch the owner's signed-in Chrome profile.
Measurements run against localhost and are not field measurements in Ethiopia.

| Scenario | Startup | Transferred | Result |
| --- | --- | --- | --- |
| Uncompressed: 1.6 Mbps, 150 ms latency | 55.9 s | 10.97 MB | Passed |
| Uncompressed: 512 kbps, 400 ms latency | 173.8 s | 10.97 MB | Passed |
| Gzip: 512 kbps, 400 ms latency | 66.0 s | 4.08 MB | Passed |
| Oromo: external hosts blocked, then offline navigation | 12.9 s to guest login | Local assets only | Passed |
| Amharic: offline navigation | — | — | Passed |
| Arabic: RTL controls and offline navigation | — | — | Passed |
| Initial download failure, Oromo retry, successful reload | — | — | Passed |

The uncompressed server is Python's static HTTP preview; the gzip server is a
local QA fixture. Compression reduced measured transfer from about 10.97 MB to
4.08 MB, but the first web load still took about 66 seconds at 512 kbps. These are
representative cold-load measurements from this pass; final text-wrap and Arabic
accessibility fixes were subsequently smoke-tested without repeating unchanged
transfer scenarios. Navigation, locale rendering and startup retry pass on the
final build. No font or CanvasKit CDN request occurs on the checked screens.

Intentionally blocking Google services makes the pinned FlutterFire module loader
emit one failed `firebase-app.js` dynamic-import rejection in the browser console.
The 12-second initialization bound still reaches usable guest navigation. The
harness records this induced provider failure explicitly and rejects all other
uncaught browser errors; normal and offline-navigation runs report none.


Offline navigation means switching already-loaded app screens after network
loss. It does not mean the app can be installed or cold-opened offline, or that
audio/YouTube videos have been downloaded. The startup-failure scenario blocks
`main.dart.js`, verifies the Oromo retry control, then unblocks it and verifies
successful startup. External-host blocking checks guest access without Google
services; Google sign-in itself still requires its provider and connectivity.

## Remaining release checks

The translation implementation is complete for the listener screens exercised
here. It has reference checks and automated/rendering validation, not a fluent
human translator's certification. A fluent Oromo/Amharic copy review remains
appropriate before public release. Real song lyrics are not generated or changed.

Real-master playback, final song/video matching and physical-phone testing on
Ethiopian networks remain for the audio-intake/release stage. Large cold web
downloads still need compressed hosting and realistic phone/network checks.
Firebase Hosting supports automatic gzip/Brotli; the local compression test
models that behavior but does not verify a deployed host. No deployment, merge,
billing change or store publication was performed in this pass.

## Primary references

- [Flutter internationalization](https://docs.flutter.dev/ui/internationalization)
- [Flutter web initialization and local renderer configuration](https://docs.flutter.dev/platform-integration/web/initialization)
- [Playwright network testing](https://playwright.dev/docs/network)
- [Firebase Hosting compression](https://firebase.google.com/docs/hosting)
- [LibreOffice Oromo Save terminology](https://help.libreoffice.org/latest/om/text/shared/01/01060000.html)
- [LibreOffice Amharic Save terminology](https://help.libreoffice.org/latest/am/text/shared/01/01060000.html)
- [LibreOffice Oromo Open terminology](https://help.libreoffice.org/latest/om/text/shared/01/01020000.html)

Earlier listener repairs and their evidence are in `LISTENER_QA_2026_11_15.md`.
