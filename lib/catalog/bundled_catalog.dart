import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/models/video.dart';

/// Local candidate based on the owner's recordings and independent matching.
/// Shilimii uses a delivery encoding of the owner's WAV master.
const bundledSongs = <Song>[
  Song(
    id: 'vision_gumgume',
    title: 'Gumgume',
    artist: 'Andualem Gosaa',
    filePath: 'assets/release_audio/gumgume.mp3',
    imagePath: kPlaceholderCover,
    duration: Duration(milliseconds: 310437),
  ),
  Song(
    id: 'vision_qondaala',
    title: 'Qondaala',
    artist: 'Fayyisaa Furii',
    filePath: 'assets/release_audio/qondaala.m4a',
    imagePath: kPlaceholderCover,
    duration: Duration(seconds: 340),
  ),
  Song(
    id: 'vision_shilimii',
    title: 'Shilimii',
    artist: 'Daanga H Qananii',
    filePath: 'assets/release_audio/shilimii.m4a',
    imagePath: kPlaceholderCover,
    duration: Duration(seconds: 288),
  ),
];
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
