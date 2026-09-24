# Demo — 10 to 15 minutes

Listener walkthrough for [Vision Music](https://github.com/Birra3324/visionmusicapp). No admin console, no service account, and no API key.

The catalog flag in `lib/core/services/app_config.dart` is off, so the app plays the eight bundled tracks in `assets/audio/` (listed in `lib/mock_songs.dart`). Guest favorites stay on the device.

Live marketing site, separate from this client: [www.visionmusic.et](https://www.visionmusic.et).

## Before you start (about 2 minutes)

Flutter stable with Dart 3.10 or newer.

```bash
git clone https://github.com/Birra3324/visionmusicapp.git
cd visionmusicapp
flutter pub get
flutter devices
flutter run -d chrome
```

Use a phone, simulator, or desktop id from `flutter devices` if Chrome is not listed. `flutter run` with no device flag picks one.

Wait for the gold login card. If Firebase is not ready, the Google button reads **Sign in temporarily unavailable**. That is expected for this walkthrough. Use guest mode.

## 1. Guest entry (1 minute)

On the login card, tap **Continue as Guest**.

You land on Home. The greeting is generic because there is no Firebase user. The line under the guest button on the login card is the contract for this mode: favorites and recent listening are saved on this device.

Skip Google Sign-In. It needs a configured Firebase project and is not required to play the bundled catalog.

## 2. Playback (3 minutes)

Home lists the bundled catalog under Recent, Popular, New, and Trending. Those tabs reorder the same local tracks.

Tap **Markato** (Ali Birra). The row starts playback and opens Now Playing.

Check:

- Title and artist match the row you tapped
- Play and pause move the progress bar
- The mini-player sits above the bottom navigation after you go back
- Tapping the mini-player returns to Now Playing

Background notification controls are a mobile `audio_service` behavior. Chrome is enough to show the player UI and hear the bundled file.

If a row shows "This song could not be played," confirm `flutter pub get` finished and the matching file exists under `assets/audio/`.

## 3. Library (3 minutes)

Open the **Library** tab.

1. Tap **Explore catalog** under Favorites (or open **Songs** in Your Collection).
2. On a song row, tap the heart. The tooltip is **Add to favorites**.
3. Return to Library. The song is listed under Favorites.
4. Play a second track from Home, then come back. **Recently Played** shows it.
5. Open **Playlists**, create a list, and add the current song from the row overflow menu (**Add to Playlist**).

Hearts and recents survive an app restart on the same device. They are not an account in the cloud.

## 4. Search (2 minutes)

Open **Search**, or tap the search field on Home (it switches to the Search tab).

- Tap the **Ali Birra** chip. **Markato** appears.
- Tap **Shukri Jamal**. **Marartuu** appears.
- Type `Gumgume`. **Andualem Gosa** appears.
- Type `zzzz`. The empty copy is **No matches found.**

Search matches title, artist, and album on the in-memory catalog. It does not call a private search API.

## 5. Profile (2 minutes)

Open **Profile**.

- The header reads **Guest listener**.
- Change **Language** to Afaan Oromo, then back to English. Arabic (`العربية`) flips the layout to right-to-left.
- Toggle **Shuffle** or **Repeat**. They drive the same `AudioManager` as the player.

## What you are not demonstrating

- The Watch tab. It is in the shell, and several mock video URLs are still placeholders. Audio is the demo.
- Firestore as the live catalog. `useFirebaseCatalog` is false.
- Admin publishing, transcoding, service-account imports, or store submission. Those notes, if you need the history, are under [docs/internal](internal/README.md) and are not part of this script.

## If you have five extra minutes

Capture the four shots in [docs/screenshots/README.md](screenshots/README.md): login, Now Playing, Library favorites, and Search results. This repository does not ship those images yet. The marketing repo has one home-screen capture linked from that page.
