# Microphone-only iOS validation

Build 106 was delivered with ITMS-90683. PR #16 removes the unused
`permission_handler` dependency and asks the existing `AudioRecorder` for
microphone permission. The pinned `record_ios` implementation requests only
`AVCaptureDevice` authorization for `.audio`. No location usage description is
added to Info.plist. Build number 107 is a proposal, not a reservation in App
Store Connect.

## Public code checks without protected music

The original PR CI failure (run 44144558499, job 134256028444) consisted of three
`asset_does_not_exist` analyzer warnings for the protected release-audio paths.
Public CI does not have the decryption key. Removing analyzer diagnostics or
committing real masters would not be an appropriate fix.

Public CI now supplies three explicitly synthetic, quarter-second silence
fixtures to satisfy the declared assets. The preparation script refuses to
replace existing audio. Cleanup verifies its own manifest, exact filenames and
known fixture hashes before removing anything. These files are for code tests
and unsigned native analysis only; builds containing them must not be distributed.

The release-media size assertion has a `protected_audio` test tag. Public code
checks exclude it. The protected release workflow still decrypts authenticated
originals and runs all tests, including that assertion. Its environment approval,
hash verification, upload conditions and plaintext cleanup remain in place.

## Permission regression tests

The service accepts an optional recorder for testing; ordinary callers continue
to use `AudioRecorder`. Three tests cover permission granted (capture starts),
permission denied (capture never starts), and a permission API exception
(service error, no capture). These tests mock the recorder and path provider;
they do not record microphone audio or contact the recognition service.

Local analyzer: no issues. Both default and strict-live code suites passed
121 tests with `protected_audio` excluded. The fixture helper and native audit
helper each passed three Python regression tests.

## Native validation

After an unsigned build, run:

```sh
python3 scripts/audit_ios_permissions.py build/ios/iphoneos/Runner.app
```

The audit requires a microphone usage description, rejects location usage
descriptions, and scans the executable and embedded Mach-O binaries for the
location authorization selectors and removed permission-plugin symbols. It
reports any generic CoreLocation references separately for review. It skips
Flutter's bundled assets and does not read recordings.

The normal validation workflow may run on `fix/ios-location-warning` with
`upload_to_testflight=false`, `use_firebase_catalog=false`, and `ref` equal to
that branch. This uses synthetic audio, no signing secrets, and no upload job.
The same native audit also runs in the protected release path before archive.

The automated service tests do not establish behavior of the iPhone OS permission
dialog. On a reachable physical test iPhone, check a fresh denial (no capture),
a fresh grant (capture starts), and cancellation. Confirm that location access
is never requested. No physical iPhone was reachable during the local checks.

No merge, TestFlight upload, App Store submission or production change is
authorized by this validation document.
