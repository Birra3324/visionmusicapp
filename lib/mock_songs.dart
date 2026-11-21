import 'package:visionmusicapp/song.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Vision Music v1 Catalog — updated 2026-04-27
// 8 verified songs. All audio confirmed unique and correct.
//
// CORRECTIONS 2026-04-27:
//   "Nuho gobana.mp3" confirmed as Markato by Ali Birra (not Nuho Gobana).
//   Entry renamed from nuho_gobana → markato, title updated to Markato.
//   Harargee still PENDING — real audio not yet available.
//
// CORRECTIONS 2026-08-10 (audit):
//   Every cover was shifted by one entry — each song displayed the NEXT
//   artist's photo. Remapped so each song uses its own artist's artwork.
//   Three covers carry printed text that proves ownership:
//     yosan_getahun.jpg  reads "OBSA! — YOSAN GETAHUN"
//     shukri_jamal.jpg   reads "Marartuu — Shukri Jamal"
//     andualem_gosa.jpg  reads "GUMGUME … GOSA"
//
// COVER NOTES:
//   markato      — alii birra.jpeg is 255x198px (very small). Replace when available.
//   hirphaa      — deliberate placeholder: the Vision Music logo. Do NOT restore
//                  hirphaa.jpg; it is the wrong artist (and is gone from disk).
//   lagaa        — placeholder logo. davo.jpg is NOT Davo: it is an "Urjii Iluu"
//                  poster credited to Tekalign Tena, so it must not be used here.
//                  Artist attribution for this row is UNVERIFIED and left as-is
//                  pending confirmation (the audio file is daraara-lagaa.mp3,
//                  which suggests the artist may be Daraaraa rather than Davo).
//   alibiyyanqabaa — Naaima abdurahman.jpeg is 12KB (small). Replace when available.
//
// UNUSED ON DISK: davo.jpg (Tekalign Tena — no matching audio in catalog).
// TRIMMED 2026-11-21:
//   The app now bundles only the three songs Vision Entertainment has
//   confirmed and already publishes on cdn.visionmusic.et (3Obsaa, Marartuu,
//   Gumgume). They are the offline starter set when the CDN can't be reached.
//   Markato, Hirphaa, Lagaa, Kuyubisaa and Alibiyyanqabaa were removed from the
//   app until their rights are confirmed; their audio stays in git history.
//   The notes above are kept for history.
// ─────────────────────────────────────────────────────────────────────────────

/// Shown when a track has no verified artist artwork. Using the brand mark is
/// deliberate — it is better than displaying another artist's face.
const String kPlaceholderCover = 'assets/images/visionlogo.jpg';

const mockSongs = [
  Song(
    id: 'yosan_getahun',
    title: '3Obsaa',
    artist: 'Yosan Getahun',
    albumTitle: 'Single',
    genre: 'Oromo Music',
    filePath: 'assets/audio/yosan_getahun.mp3',
    duration: Duration(minutes: 5, seconds: 13, milliseconds: 652),
    imagePath: 'assets/images/yosan_getahun.jpg',
    youtubeUrl: 'https://www.youtube.com/watch?v=8zlm6JVbi2U',
  ),
  Song(
    id: 'shagoye',
    title: 'Marartuu',
    artist: 'Shukri Jamal',
    albumTitle: 'Single',
    genre: 'Oromo Music',
    filePath: 'assets/audio/shagoye.mp3',
    duration: Duration(minutes: 3, seconds: 19, milliseconds: 576),
    imagePath: 'assets/images/shukri_jamal.jpg',
    youtubeUrl: 'https://www.youtube.com/watch?v=F1cfzTGxcCs',
  ),
  Song(
    id: 'andualem_gosa',
    title: 'Gumgume',
    artist: 'Andualem Gosa',
    albumTitle: 'Single',
    genre: 'Oromo Music',
    filePath: 'assets/audio/gungume_andualem_gosa.mp3',
    duration: Duration(minutes: 5, seconds: 10, milliseconds: 465),
    imagePath: 'assets/images/andualem_gosa.jpg',
    youtubeUrl: 'https://www.youtube.com/watch?v=LK0J9Au84-o',
  ),
];
