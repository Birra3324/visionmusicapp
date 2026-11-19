# Android locale and listener validation

## Evidence and scope

Crashlytics issue `2050909045b4bc44cb47b606e2064bd4` was inspected on
November 19. Its 25 fatal events were all foreground events from one Samsung
SM-N976N running Android 12 and app 1.0.1 (4). The representative stack is
`MaterialLocalizations.of` → `_TextFieldState._getEffectiveDecoration` →
`_TextFieldState.build` → `ListenableBuilder`.

The events do not contain a locale custom key, and Logs & Breadcrumbs is empty.
The affected person's locale and build 4's source commit cannot be established
from that evidence. Positive beta feedback about build 4 does not validate this
draft's candidate (pubspec 1.0.1+8).

Of the six languages advertised by this app, Flutter's stock Material delegate
does not support `om`. The existing fallback delegates in this draft supply
Material, Cupertino and Widgets resources while preserving the app's Oromo
translations. The regression control deliberately removes those fallbacks.

## Added regression coverage

`test/text_field_locale_test.dart` and
`integration_test/text_field_locale_test.dart` run the same assertions:

- Demonstrate the failure with the legacy delegates and an Oromo TextField.
- Start the actual `VisionMusicApp` with each saved supported locale.
- Enter guest mode, open Search, focus its TextField and type a fixture title.
- Change language while Search remains focused.
- Open the actual playlist-name dialog, type, change language while focused,
  and submit the localized Create button.
- Require usable Material strings and no framework exceptions in the candidate.

Only a synthetic song descriptor is used; it is never played. Expected control
exceptions are captured by the test rather than forwarded to Crashlytics.
The isolated Android emulator has Wi-Fi and mobile data disabled for the final
native run. No owner's browser profile or physical phone is modified.

The profile-mode control additionally requires the null-check exception and
`_TextFieldState._getEffectiveDecoration` in its stack, matching the reported
failure path. This establishes a reproducible cause, not the missing locale of
the historical events.

Text entry uses a registered Flutter test input channel on the device. Profile
mode rejects the unregistered test client's sentinel ID, which otherwise makes
`enterText` silently leave fields empty. Both the Search text and dialog text
are explicitly checked before and after language changes. This is an Android
framework/device regression check, not validation of a physical phone's IME.

## Host results

- Full suites: 124 tests passed in default mode and 124 in strict live mode.
- The final focused regression suite: seven tests passed.
- Translation and network coverage includes six 156-message catalogs, 320px
  layouts at 2x text size, bounded requests, retry recovery, stale responses and
  leaving a screen while a request is pending.
- The listener's production code, translations and web assets are unchanged
  from the November 15 tested source tree. The recorded browser/network evidence
  in `TRANSLATION_NETWORK_QA_2026_11_15.md` remains applicable; the slow-load
  timings there are November 15 measurements, not newly repeated field tests.

## Release boundaries

The Android test device is an isolated ARM64 Android 14 emulator. A physical
Samsung/Android 12 check, an explicitly selected merge/release target and a new
beta rollout remain separate steps. This validation does not close the live
Crashlytics issue or establish that a replacement version has reached testers.

The audio catalog remains empty until approved masters and metadata are ready.
Fluent translation review and real-phone checks on Ethiopian networks remain
release checks. No merge, upload, deployment, billing change or paid service is
part of this validation.

References: [Flutter internationalization](https://docs.flutter.dev/ui/internationalization),
[Flutter device integration tests](https://docs.flutter.dev/testing/integration-tests),
[profile-mode integration tests](https://docs.flutter.dev/cookbook/testing/integration/profiling).
