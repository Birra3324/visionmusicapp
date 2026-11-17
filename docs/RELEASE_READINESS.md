# Vision Music release readiness

Prepared for review; no deployment or App Store/TestFlight submission is authorized by this change.

## Catalog configuration

Live builds use `--dart-define=USE_FIREBASE_CATALOG=true --dart-define=FALLBACK_TO_LOCAL_CATALOG=false`. They show only the existing repository's published, approved remote catalog. Empty or unavailable Firebase does not silently substitute demo music. Local demo builds keep the default `USE_FIREBASE_CATALOG=false`.

Before release, verify Firebase configuration, App Check registration, and at least one approved published track in the intended project. The code does not provision a bucket, publish music, or enable a deployed backend.

## iOS validation and release

The iOS workflow defaults to validation: tests and an unsigned release build with no Apple signing secrets and no TestFlight upload. Flutter and the dependency lockfile are pinned to the locally tested 3.44.4 SDK. The Xcode project records the SDK-generated Swift Package integration and resolved versions used for the successful build; the existing custom Podfile remains.

Xcode's Crashlytics phase now skips symbol uploads unless `VM_UPLOAD_CRASHLYTICS_SYMBOLS=true` and signing is enabled. This fixes the unsigned build failure when `flutterfire` is absent. Only the optional signed archive job installs FlutterFire CLI 1.5.0 and enables that upload.

After Birra approves a specific release, configure required reviewers on the GitHub `app-store` environment and verify its Apple signing secrets. Environment protection has not been created or verified by this code change. Only then may a workflow be dispatched with `upload_to_testflight=true`. A checked input is not a substitute for Birra's approval.

## Validation

- 76 Flutter tests passed with live-catalog defines.
- `flutter analyze --no-pub --no-fatal-infos` passed with two pre-existing info-level style suggestions.
- `flutter build ios --release --no-codesign --dart-define=USE_FIREBASE_CATALOG=true --dart-define=FALLBACK_TO_LOCAL_CATALOG=false` succeeded on Flutter 3.44.4 / Xcode 26.6.
- Workflow YAML and shell syntax, the default no-upload path, and the actual Xcode script's unsigned/unapproved upload guards were checked locally.

The unsigned build does not validate Apple signing, App Store Connect credentials, live backend provisioning, or store acceptance. Those remain separate approved release checks.
