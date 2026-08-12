import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:visionmusicapp/core/services/youtube_config.dart';
import 'package:visionmusicapp/core/services/video_repository.dart';
import 'package:visionmusicapp/models/video.dart';
import 'package:visionmusicapp/mock_videos.dart';

/// YouTube API repository for fetching videos from your channel
///
/// Requires:
/// - YouTube Data API v3 key (Google Cloud Console)
/// - Channel ID from YouTube Studio
///
/// Falls back to mock data if API is not configured
class YouTubeRepository implements VideoRepository {
  final http.Client _client;

  YouTubeRepository({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<Video>> getAllVideos() async {
    if (!YouTubeConfig.isConfigured) {
      debugPrint('YouTube API not configured. Using mock data.');
      return mockVideos;
    }

    try {
      final url = YouTubeConfig.channelVideosUrl;
      if (url == null) return mockVideos;

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint('YouTube API error: ${response.statusCode}');
        return mockVideos;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?;

      if (items == null || items.isEmpty) {
        return mockVideos;
      }

      // Convert YouTube items to Video objects
      final videos = <Video>[];
      for (final item in items) {
        final video = await _convertYouTubeItem(item as Map<String, dynamic>);
        if (video != null) {
          videos.add(video);
        }
      }

      return videos.isEmpty ? mockVideos : videos;
    } catch (e) {
      debugPrint('Error fetching YouTube videos: $e');
      return mockVideos;
    }
  }

  @override
  Future<List<Video>> getVideosByType(VideoType type) async {
    // YouTube API doesn't support filtering by custom types
    // Fetch all and filter locally
    final allVideos = await getAllVideos();
    return allVideos.where((v) => v.type == type).toList();
  }

  @override
  Future<Video?> getVideoById(String id) async {
    if (!YouTubeConfig.isConfigured) {
      try {
        return mockVideos.firstWhere((v) => v.id == id);
      } catch (_) {
        return null;
      }
    }

    try {
      final url = YouTubeConfig.getVideoDetailsUrl(id);
      if (url == null) return null;

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?;

      if (items == null || items.isEmpty) return null;

      return _convertYouTubeItem(items[0] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error fetching video by ID: $e');
      return null;
    }
  }

  Future<Video?> _convertYouTubeItem(Map<String, dynamic> item) async {
    try {
      final snippet = item['snippet'] as Map<String, dynamic>?;
      final id = item['id'] as Map<String, dynamic>?;

      if (snippet == null) return null;

      final videoId = id?['videoId'] as String? ?? item['id'] as String?;
      if (videoId == null) return null;

      final title = snippet['title'] as String? ?? 'Untitled';
      final channelTitle =
          snippet['channelTitle'] as String? ?? 'Unknown Artist';
      final description = snippet['description'] as String?;
      final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
      final thumbnailUrl =
          thumbnails?['high']?['url'] ??
          thumbnails?['medium']?['url'] ??
          thumbnails?['default']?['url'];

      // Try to determine video type from title/description
      final type = _detectVideoType(title, description ?? '');

      return Video(
        id: videoId,
        title: title,
        artistName: channelTitle,
        description: description,
        thumbnailUrl: thumbnailUrl,
        videoUrl: 'https://www.youtube.com/watch?v=$videoId',
        type: type,
        releaseDateOverride: DateTime.tryParse(
          snippet['publishedAt'] as String? ?? '',
        ),
        tags: _extractTags(title, description ?? ''),
      );
    } catch (e) {
      debugPrint('Error converting YouTube item: $e');
      return null;
    }
  }

  VideoType _detectVideoType(String title, String description) {
    final text = '${title.toLowerCase()} ${description.toLowerCase()}';

    if (text.contains('podcast') || text.contains('episode')) {
      return VideoType.podcast;
    }
    if (text.contains('interview') || text.contains('talk with')) {
      return VideoType.interview;
    }
    if (text.contains('live') ||
        text.contains('concert') ||
        text.contains('performance')) {
      return VideoType.liveSession;
    }
    if (text.contains('documentary') || text.contains('behind the scenes')) {
      return VideoType.documentary;
    }
    if (text.contains('official video') || text.contains('music video')) {
      return VideoType.musicVideo;
    }

    // Default to music video for most content
    return VideoType.musicVideo;
  }

  List<String> _extractTags(String title, String description) {
    final tags = <String>[];
    final text = '${title.toLowerCase()} ${description.toLowerCase()}';

    if (text.contains('oromo')) tags.add('oromo');
    if (text.contains('ethiopian')) tags.add('ethiopian');
    if (text.contains('music')) tags.add('music');
    if (text.contains('official')) tags.add('official');
    if (text.contains('live')) tags.add('live');
    if (text.contains('new')) tags.add('new');

    return tags;
  }
}
