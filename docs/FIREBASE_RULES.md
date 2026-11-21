# Firebase security rules live in visionmusic-backend

The live Firestore and Storage rules for project `visionmusic-dev` are kept and
tested in the **visionmusic-backend** repository (`rules/firestore.rules`,
`rules/storage.rules`, emulator tests in `emulator-tests/`). Deploy them from
there.

This repo used to carry its own, older copies (songs readable by anyone, no
`status`/`approved` check). They no longer matched what is live, and running
`firebase deploy` here would have replaced the live rules with the weaker ones,
so they were removed and `firebase.json` no longer points at any rules.

What the app must respect (live rules, Nov 2026):
- `songs/`, `videos/`: readable only when `status == 'published'` and
  `approved == true`; every query must filter on both. No client writes.
- `videoCategories/`: public read, no client writes.
- `users/{uid}/...` (favorites, library, recentlyPlayed, playlists): owner only.
- Songs are served from the CDN (`https://cdn.visionmusic.et/catalog.json`),
  not from Firestore or Firebase Storage.
