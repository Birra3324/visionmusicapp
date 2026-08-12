import 'package:visionmusicapp/mock_songs.dart' show kPlaceholderCover;
import 'package:visionmusicapp/models/video.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Vision Music Video Catalog — Demo / Seed Content
//
// CHANNEL: Vision Entertainment
// URL: https://youtube.com/@visionentertainment4507
//
// Replace placeholder YouTube URLs with real video IDs from your channel.
// Example: https://www.youtube.com/watch?v=REAL_VIDEO_ID
// ─────────────────────────────────────────────────────────────────────────────

final List<Video> mockVideos = [
  // ── Music Videos ──────────────────────────────────────────────────────────
  Video(
    id: 'mv_markato',
    title: 'Markato (Official Video)',
    artistName: 'Ali Birra',
    description:
        'The legendary Oromo musician performs his iconic track Markato. '
        'A timeless classic that defined a generation.',
    thumbnailUrl: 'assets/images/alii birra.jpeg',
    videoUrl: 'https://www.youtube.com/watch?v=REPLACE_ALI_BIRRA_MARKATO',
    category: 'music_videos',
    isFeatured: true,
    duration: Duration(minutes: 4, seconds: 30),
    tags: ['oromo', 'classic', 'official', 'ali-birra'],
  ),
  Video(
    id: 'mv_yosan',
    title: '3Obsaa (Official Music Video)',
    artistName: 'Yosan Getahun',
    description:
        'The breakout hit from Yosan Getahun — a modern Oromo masterpiece '
        'blending traditional rhythms with contemporary production.',
    thumbnailUrl: 'assets/images/yosan_getahun.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=8zlm6JVbi2U',
    category: 'music_videos',
    isFeatured: true,
    duration: Duration(minutes: 3, seconds: 58),
    tags: ['oromo', 'modern', 'official', 'yosan'],
  ),
  Video(
    id: 'mv_shukri',
    title: 'Marartuu (Official Video)',
    artistName: 'Shukri Jamal',
    description:
        'Shukri Jamal delivers a soul-stirring performance in this official video for Marartuu.',
    thumbnailUrl: 'assets/images/shukri_jamal.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=F1cfzTGxcCs',
    category: 'music_videos',
    isFeatured: false,
    duration: Duration(minutes: 4, seconds: 12),
    tags: ['oromo', 'official', 'shukri'],
  ),

  // ── Live Performances ─────────────────────────────────────────────────────
  Video(
    id: 'live_hirphaa_finfinne',
    title: 'Hirphaa Gaanfuree — Live at Finfinne',
    artistName: 'Hirphaa Gaanfuree',
    description:
        'An intimate live performance capturing the soul of Oromo music '
        'at the historic Finfinne stage.',
    // hirphaa.jpg was removed: it depicted the wrong artist, and it is not
    // recoverable from git (the object database has missing blobs). Using the
    // brand mark as an explicit placeholder until correct artwork is supplied.
    thumbnailUrl: kPlaceholderCover,
    videoUrl: 'https://www.youtube.com/watch?v=REPLACE_HIRPHAA_LIVE',
    category: 'live_performances',
    isFeatured: true,
    duration: Duration(minutes: 12, seconds: 15),
    tags: ['live', 'oromo', 'finfinne', 'hirphaa'],
  ),
  Video(
    id: 'live_asanti_acoustic',
    title: 'Kuyubisaa — Acoustic Live Session',
    artistName: 'Asanti',
    description:
        'Stripped-down acoustic version of the hit song Kuyubisaa, '
        'filmed live in one take.',
    thumbnailUrl: 'assets/images/asanti.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=REPLACE_ASANTI_ACOUSTIC',
    category: 'live_performances',
    isFeatured: false,
    duration: Duration(minutes: 5, seconds: 45),
    tags: ['acoustic', 'live', 'oromo', 'asanti'],
  ),

  // ── Studio Sessions ───────────────────────────────────────────────────────
  Video(
    id: 'studio_andualem',
    title: 'Gungume — Studio Session',
    artistName: 'Andualem Gosa',
    description:
        'Behind the glass: Andualem Gosa records Gungume in an exclusive '
        'studio session filmed for Vision Entertainment.',
    thumbnailUrl: 'assets/images/andualem_gosa.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=LK0J9Au84-o',
    category: 'studio_sessions',
    isFeatured: false,
    duration: Duration(minutes: 7, seconds: 20),
    tags: ['studio', 'behind-scenes', 'andualem'],
  ),

  // ── Interviews ────────────────────────────────────────────────────────────
  Video(
    id: 'interview_yosan_journey',
    title: 'Yosan Getahun: Journey to 3Obsaa',
    artistName: 'Yosan Getahun',
    description:
        'An in-depth interview on the making of 3Obsaa — from early demos '
        'to the final release that captivated millions.',
    thumbnailUrl: 'assets/images/yosan_getahun.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=REPLACE_YOSAN_INTERVIEW',
    category: 'interviews',
    isFeatured: false,
    duration: Duration(minutes: 18, seconds: 45),
    tags: ['interview', 'behind-the-scenes', 'yosan'],
  ),
  Video(
    id: 'interview_shukri_culture',
    title: 'Shukri Jamal on Oromo Cultural Identity',
    artistName: 'Shukri Jamal',
    description:
        'Shukri speaks candidly about cultural preservation through music '
        'and what it means to be an Oromo artist today.',
    thumbnailUrl: 'assets/images/shukri_jamal.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=REPLACE_SHUKRI_INTERVIEW',
    category: 'interviews',
    isFeatured: false,
    duration: Duration(minutes: 22, seconds: 10),
    tags: ['interview', 'culture', 'identity', 'shukri'],
  ),

  // ── Podcast Clips ─────────────────────────────────────────────────────────
  Video(
    id: 'podcast_davo_oromo',
    title: 'The Sound of Oromo Music — Davo Episode',
    artistName: 'Davo',
    description:
        'An insightful podcast episode on modern Oromo music trends, '
        'the global diaspora sound, and where the genre is heading.',
    thumbnailUrl: 'assets/images/davo.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=REPLACE_DAVO_PODCAST',
    category: 'podcast_clips',
    isFeatured: false,
    duration: Duration(minutes: 35, seconds: 20),
    tags: ['podcast', 'discussion', 'oromo-music', 'davo'],
  ),

  // ── Oromo Classics ────────────────────────────────────────────────────────
  Video(
    id: 'classic_ali_birra_hero',
    title: 'Ali Birra — The Voice of a Generation',
    artistName: 'Ali Birra',
    description:
        'A documentary tribute to the legendary Ali Birra — '
        'exploring his decades-long contribution to Oromo music and culture.',
    thumbnailUrl: 'assets/images/alii birra.jpeg',
    videoUrl: 'https://www.youtube.com/watch?v=REPLACE_ALI_BIRRA_DOC',
    category: 'oromo_classics',
    isFeatured: false,
    duration: Duration(minutes: 28, seconds: 0),
    tags: ['documentary', 'classic', 'oromo', 'ali-birra'],
  ),
  Video(
    id: 'classic_shukri_marartuu_story',
    title: 'Marartuu: The Story Behind the Song',
    artistName: 'Shukri Jamal',
    description:
        'Mini documentary exploring the cultural roots and inspiration '
        'behind Shukri Jamal\'s beloved classic Marartuu.',
    thumbnailUrl: 'assets/images/shukri_jamal.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=REPLACE_SHUKRI_DOC',
    category: 'oromo_classics',
    isFeatured: false,
    duration: Duration(minutes: 8, seconds: 10),
    tags: ['documentary', 'culture', 'classic', 'shukri'],
  ),

  // ── New Releases ──────────────────────────────────────────────────────────
  Video(
    id: 'new_naaima_latest',
    title: 'Naaima Abdurahman — New Single (2024)',
    artistName: 'Naaima Abdurahman',
    description:
        'The newest release from rising star Naaima Abdurahman — '
        'a fresh sound that bridges tradition and contemporary Afro-pop.',
    thumbnailUrl: 'assets/images/Naaima abdurahman.jpeg',
    videoUrl: 'https://www.youtube.com/watch?v=REPLACE_NAAIMA_NEW',
    category: 'new_releases',
    isFeatured: true,
    duration: Duration(minutes: 3, seconds: 42),
    tags: ['new', 'release', 'afro-pop', 'naaima'],
  ),
];

/// Featured videos — those with isFeatured = true
List<Video> get featuredMockVideos =>
    mockVideos.where((v) => v.isFeatured).toList();

/// Videos grouped by category
Map<String, List<Video>> get mockVideosByCategory {
  final map = <String, List<Video>>{};
  for (final v in mockVideos) {
    map.putIfAbsent(v.category, () => []).add(v);
  }
  return map;
}
