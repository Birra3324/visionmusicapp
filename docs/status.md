# Status — Days 26–27

Public documentation for the Vision Music listener: [github.com/Birra3324/visionmusicapp](https://github.com/Birra3324/visionmusicapp).

Live site: [www.visionmusic.et](https://www.visionmusic.et). This checklist covers the public client only. Admin and backend repositories stay private and are not linked here.

Calendar date 2026-09-23 is plan Day 22. Days 19–25 already shipped on the customer-operations-agent repo, so this pass advances to Vision Music public docs (Days 26–27).

## Days 26–27 checklist

| Day | Intent | Status |
| --- | --- | --- |
| 26 | Recruiter README, client-only architecture, private boundary, portfolio links, move internal notes off the root | **Done** |
| 27 | 10–15 minute guest walkthrough and a screenshot guide | **Done** (no new image binaries; none were in the repo) |

### Day 26 — README and boundary

- [x] README states what the app is, the live site, the stack, and how to run it
- [x] Architecture diagram is the Flutter listener only
- [x] Admin studio, publishing, and service accounts are called out as private and are not linked
- [x] Links to [visionmusic-site](https://github.com/Birra3324/visionmusic-site), [ai-intake-demo](https://github.com/Birra3324/ai-intake-demo), [company-rag-assistant](https://github.com/Birra3324/company-rag-assistant), and [customer-operations-agent](https://github.com/Birra3324/customer-operations-agent)
- [x] Root `HANDOFF_*`, `BACKEND_SETUP_*`, audits, and other ops notes moved to [docs/internal](internal/README.md) with a not-for-public-ops banner
- [x] `firebase-key.json` and service-account JSON patterns added to `.gitignore`
- [x] FlutterFire client files (`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`) left as existing public client config. No new secrets added

### Day 27 — walkthrough and screenshots

- [x] [docs/demo.md](demo.md) covers clone, `flutter run` or Chrome, Continue as Guest, playback, Library, and Search in 10–15 minutes
- [x] Walkthrough does not require the admin studio, a service account, or a YouTube API key
- [x] [docs/screenshots/README.md](screenshots/README.md) explains how to capture login, Now Playing, Library, and Search
- [x] No invented screenshot binaries. Artist photos and launcher icons were not reused as product shots
- [x] One existing home capture on the public marketing site is linked, not copied into this repo

## Verification

| Check | Status | Notes |
| --- | --- | --- |
| Secrets in the new docs | Clean | New pages name client config files and tell readers not to commit service accounts. They do not add keys, keystores, or admin credentials. |
| Private repos | Not opened | README and this checklist do not link admin or backend repositories. |
| UI screenshots in this repo | None suitable | No `_demo_screenshots` or `store_prep` images. Capture steps are documented. |
| Flutter test / analyze | Not run here | The Flutter SDK is not installed in the docs environment. Commands in the README match `pubspec.yaml` (`sdk: ^3.10.1`). |

## Still true

- Guest mode plays the bundled catalog while `AppConfig.useFirebaseCatalog` is false
- Code in this repository is for portfolio review. Tracks and artwork stay with Vision Entertainment
- [docs/internal](internal/README.md) keeps the older engineering notes. It is not a runbook
