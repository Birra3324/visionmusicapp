// Vision Entertainment YouTube Channel Configuration
//
// Channel: https://youtube.com/@visionentertainment4507
//
// To fetch real videos from this channel, you need:
// 1. YouTube Data API v3 key from Google Cloud Console
// 2. Add the API key to your environment or config
//
// For now, videos can be manually added to Firebase or mock data.

class YouTubeConfig {
  /// Your YouTube channel handle
  static const String channelHandle = '@visionentertainment4507';

  /// Your channel URL
  static const String channelUrl =
      'https://youtube.com/@visionentertainment4507';

  /// Channel ID (you can find this in YouTube Studio → Settings → Channel → Advanced)
  /// Replace with your actual channel ID for API calls
  static const String? channelId = null; // e.g., 'UCxxxxxxxxxxxxxxxxxxx'

  /// YouTube Data API v3 key
  /// Get from: https://console.cloud.google.com/apis/credentials
  static const String? apiKey = null;

  /// Check if API is configured
  static bool get isConfigured => channelId != null && apiKey != null;

  /// Build channel videos API URL
  static String? get channelVideosUrl {
    if (!isConfigured) return null;
    return 'https://www.googleapis.com/youtube/v3/search'
        '?part=snippet'
        '&channelId=$channelId'
        '&maxResults=50'
        '&order=date'
        '&type=video'
        '&key=$apiKey';
  }

  /// Build video details API URL
  static String? getVideoDetailsUrl(String videoId) {
    if (!isConfigured) return null;
    return 'https://www.googleapis.com/youtube/v3/videos'
        '?part=snippet,contentDetails,statistics'
        '&id=$videoId'
        '&key=$apiKey';
  }
}
