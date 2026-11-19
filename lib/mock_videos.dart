import 'catalog/bundled_catalog.dart';
import 'models/video.dart';

/// Compatibility name for the curated local video catalog.
final List<Video> mockVideos = bundledVideos;

List<Video> get featuredMockVideos =>
    mockVideos.where((v) => v.isFeatured).toList();

Map<String, List<Video>> get mockVideosByCategory {
  final map = <String, List<Video>>{};
  for (final video in mockVideos) {
    map.putIfAbsent(video.category, () => []).add(video);
  }
  return map;
}
