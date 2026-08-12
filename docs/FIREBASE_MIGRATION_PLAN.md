# Firebase migration plan — P1-9

**Written 2026-08-11. Nothing has been changed in Firebase. This is a plan for you to execute.**

## The problem

> **STATUS 2026-08-12: COMPLETED.** The app now targets `visionmusic-dev`.
> The text below describes the original situation and is kept for history.

Your current project is `device-streaming-6b79dd0d` — an auto-generated Firebase Studio /
device-streaming identifier, not a project anyone chose to create. Two consequences:

1. There is **one environment**. Development and production are the same database. A bad write
   during testing hits real user data.
2. **macOS is registered under the iOS appId** (`1:543708513948:ios:cac17d5f49c12db9f04f59` appears
   under both platforms in `firebase.json`). Analytics will misattribute, and platform-scoped App
   Check cannot be applied correctly.

Neither is urgent while the catalogue is bundled locally and there are no real users. Both become
expensive the moment `AppConfig.useFirebaseCatalog` is `true` and people have accounts.

**Do this before Firestore becomes the live catalogue, not after.**

## What to create in the Firebase console

Two projects:

| Project ID | Purpose |
| --- | --- |
| `visionmusic-dev` | Development, testing, emulator target. Safe to wipe. |
| `vision-music-prod` | Real users. Treated as production from day one. |

In **each** project, register four apps separately — do not reuse appIds across platforms:

| Platform | Bundle / package |
| --- | --- |
| Android | `com.visionmusic.app` |
| iOS | `com.visionmusic.app` |
| macOS | `com.visionmusic.app` — **its own registration**, not the iOS one |
| Web | default |

Then in each project enable: Authentication (Email/Password, Google, and Apple — the App Store
requires Apple Sign In wherever Google is offered), Firestore, and Storage.

## Wiring it up

Run FlutterFire once per environment rather than editing config by hand:

```bash
flutterfire configure --project=visionmusic-dev
```

This regenerates `lib/firebase_options.dart` and the platform config files. Commit those — the
`apiKey` values inside are client identifiers, not secrets. **Security rules are the boundary**, and
those now live in `firestore.rules` and `storage.rules` in the repository.

For two environments in one codebase, the cleanest approach is Dart entrypoints — `main_dev.dart`
and `main_prod.dart` — each initialising with its own `DefaultFirebaseOptions`, sharing the same
`main()` body. Avoid build flavours until you actually need different bundle IDs; they add Xcode and
Gradle complexity you do not currently need.

## Deploying the new rules

Against dev first, always:

```bash
firebase use visionmusic-dev
firebase deploy --only firestore:rules,storage

# Verify, then:
firebase use vision-music-prod
firebase deploy --only firestore:rules,storage
```

Add emulator tests before the production deploy. A rule that denies too much is a bug you find in
minutes; one that allows too much is a breach you find much later.

## Migrating data

There is no user data worth migrating today, which is precisely why this is the right moment. If
that changes before you migrate, export with `gcloud firestore export` and import into the new
project — but the cheap version of this plan expires the day someone real signs up.

## What must never enter the repository

Service account JSON keys. `flutterfire configure` does not create them, and nothing in the app
needs one. If you later add Cloud Functions or an admin script, the key belongs in a secret manager
or CI secret store — never in git, and never in the Flutter bundle.

## Checklist

- [ ] Create `visionmusic-dev` and `vision-music-prod`
- [ ] Register Android, iOS, macOS and web separately in each
- [ ] Enable Auth (Email, Google, Apple), Firestore, Storage
- [ ] `flutterfire configure` per environment
- [ ] Deploy rules to dev, test, then prod
- [ ] Add emulator rule tests
- [ ] Enable App Check on both
- [ ] Only then flip `AppConfig.useFirebaseCatalog`
