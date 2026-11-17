import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/models/video.dart';

/// Owner confirmed that every old audio/name/photo pairing was a design sample.
/// Add only original audio with confirmed metadata and matching video evidence.
/// See docs/AUDIO_CATALOG.md. An empty catalog must never fall back to samples.
const bundledSongs = <Song>[];
const String kPlaceholderCover = 'assets/images/visionlogo.jpg';

/// Real videos verified on @visionentertainment4507, independent of audio.
/// Use each video's own YouTube thumbnail, never the old sample artwork.
final List<Video> bundledVideos = List<Video>.unmodifiable([
  Video(
    id: 'mv_yosan',
    title: '3Obsa (Official Video)',
    artistName: 'Yosan Getahun',
    videoUrl: 'https://www.youtube.com/watch?v=8zlm6JVbi2U',
    category: 'music_videos',
    duration: const Duration(minutes: 5, seconds: 29),
    isFeatured: true,
  ),
  Video(
    id: 'mv_shukri',
    title: 'Marartuu (Official Video)',
    artistName: 'Shukri Jamal',
    videoUrl: 'https://www.youtube.com/watch?v=F1cfzTGxcCs',
    category: 'music_videos',
    duration: const Duration(minutes: 3, seconds: 26),
  ),
  Video(
    // Preserve the existing ID for saved links, but correct its category.
    id: 'studio_andualem',
    title: 'Gumgume (Official Video)',
    artistName: 'Andualem Gosaa',
    videoUrl: 'https://www.youtube.com/watch?v=LK0J9Au84-o',
    category: 'music_videos',
    duration: const Duration(minutes: 5, seconds: 19),
  ),
]);
