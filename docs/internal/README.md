# Internal notes

Historical engineering notes for the Vision Music listener. Kept so the earlier write-ups are still in the tree.

These pages are not a public operations guide. They are not instructions for the private admin studio or backend. Do not follow them against production. Do not commit service-account JSON, keystores, `firebase-key.json`, or admin credentials. FlutterFire client config that already lives in the app (`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`) is restricted client configuration, not a server secret.

Recruiters should start at the [repository README](../../README.md), the [demo](../demo.md), and the [Days 26–27 status](../status.md).

## Handoff prompts

Session prompts from earlier implementation passes:

- [HANDOFF_PROMPT.md](HANDOFF_PROMPT.md)
- [HANDOFF_PROMPT_DEVICE_GATE.md](HANDOFF_PROMPT_DEVICE_GATE.md)
- [HANDOFF_PROMPT_IOS.md](HANDOFF_PROMPT_IOS.md)
- [HANDOFF_PROMPT_PHASE1.md](HANDOFF_PROMPT_PHASE1.md)
- [HANDOFF_PROMPT_QA_PRODUCTION.md](HANDOFF_PROMPT_QA_PRODUCTION.md)
- [HANDOFF_PROMPT_SIMULATORS.md](HANDOFF_PROMPT_SIMULATORS.md)
- [HANDOFF_PROMPT_YOUTUBE.md](HANDOFF_PROMPT_YOUTUBE.md)

## Setup and import notes

Maintainer procedures. Several tell you to create a service-account key locally. That key must stay untracked.

- [BACKEND_SETUP_FIREBASE_AWS.md](BACKEND_SETUP_FIREBASE_AWS.md)
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- [FIREBASE_MIGRATION_PLAN.md](FIREBASE_MIGRATION_PLAN.md)
- [YOUTUBE_SETUP.md](YOUTUBE_SETUP.md)
- [HOW_TO_IMPORT_VIDEOS.md](HOW_TO_IMPORT_VIDEOS.md)
- [IMPORT_COMMANDS.md](IMPORT_COMMANDS.md)
- [VIDEO_LINKS_TO_FILL_IN.md](VIDEO_LINKS_TO_FILL_IN.md)

The importer script remains at `tools/import_youtube_videos.py`.

## Audits, schema, and shipping checklists

- [TECHNICAL_AUDIT_2026-08-10.md](TECHNICAL_AUDIT_2026-08-10.md)
- [VISION_MUSIC_MASTER_AUDIT.md](VISION_MUSIC_MASTER_AUDIT.md)
- [CATALOG_AUDIT.md](CATALOG_AUDIT.md)
- [PUBLIC_APP_QA_REPORT.md](PUBLIC_APP_QA_REPORT.md)
- [_QA_WORKING_NOTES.md](_QA_WORKING_NOTES.md)
- [SECURITY_MODEL.md](SECURITY_MODEL.md)
- [FIRESTORE_SCHEMA.md](FIRESTORE_SCHEMA.md)
- [ADMIN_API_CONTRACT.md](ADMIN_API_CONTRACT.md)
- [COST_ESTIMATE.md](COST_ESTIMATE.md)
- [VISION_MUSIC_ROADMAP.md](VISION_MUSIC_ROADMAP.md)
- [VISION_MUSIC_MVP_CHECKLIST.md](VISION_MUSIC_MVP_CHECKLIST.md)
- [FINALIZATION_PLAN.md](FINALIZATION_PLAN.md)
- [TESTFLIGHT_READINESS_CHECKLIST.md](TESTFLIGHT_READINESS_CHECKLIST.md)
- [LOCALIZATION_FIX_SUMMARY.md](LOCALIZATION_FIX_SUMMARY.md)
- [VIDEO_FEATURE_SUMMARY.md](VIDEO_FEATURE_SUMMARY.md)
