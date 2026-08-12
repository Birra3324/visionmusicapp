# VisionMusic Public App QA Report

## Verified

- Audio Master is not reachable from the listener Profile screen.
- Flutter analyzer passes with no issues.
- All 59 unit/widget tests pass, including published-catalog and localization policy tests.
- The iOS simulator build completes successfully after the observability and localization changes.
- The signed iOS release build completes successfully (138.9 MB).
- The signed release installs and launches on the paired physical device named `Birra iphone` (iPhone 16 Pro Max).
- Firestore song reads request only `status == published` and `approved == true`.
- Draft, processing, unapproved, private, and local-path remote documents are rejected by client policy.
- Remote catalog loading times out after 12 seconds and can fall back to the bundled catalog while the rollout flag remains enabled.
- Firestore video repository filters unpublished documents.
- YouTube URLs open through the external official application/browser; the app does not download, extract, or background-play YouTube media.
- Analytics payloads use opaque IDs and do not include search text, names, email, lyrics, or URLs.
- Crashlytics and App Check are initialized only after Firebase succeeds.
- Primary listener navigation, Profile settings, Search, and guest-entry strings are generated for all declared locales.
- Afaan Oromo primary strings have automated coverage.

## Not yet verified

- Firebase console receipt of Analytics and Crashlytics events.
- App Check token metrics and console-side enforcement.
- Backend Security Rules matching the published-and-approved client policy.
- Live published catalog because `AppConfig.useFirebaseCatalog` remains false.
- Full visual review of every screen in every locale.
- Native-speaker review of translations.
- Hands-on playback, offline, interruption, and layout QA on the newly installed physical build.
- TestFlight upload and App Review submission.

## Backend blocker

The repository's current `firestore.rules` allows public reads of every song
and video document. The backend team must update and deploy rules so draft and
processing documents cannot be read directly. Client filtering is not a
security boundary.
