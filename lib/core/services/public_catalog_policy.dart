/// Pure validation rules shared by the listener catalog repository and tests.
/// Backend Security Rules must enforce the same boundary independently.
class PublicCatalogPolicy {
  const PublicCatalogPolicy._();

  static bool isPublishedAndApproved(Map<String, dynamic> data) =>
      data['status'] == 'published' && data['approved'] == true;

  static String? approvedAudioPath(Map<String, dynamic> data) {
    if (!isPublishedAndApproved(data)) return null;

    final direct = data['publishedAudioUrl'];
    if (direct is String && isRemoteMediaPath(direct)) return direct;

    final renditions = data['renditions'];
    if (renditions is Map) {
      for (final key in const ['aac256', 'aac128', 'aac64', 'mp3']) {
        final rendition = renditions[key];
        if (rendition is! Map ||
            rendition['approved'] != true ||
            rendition['public'] != true) {
          continue;
        }
        final url = rendition['url'];
        if (url is String && isRemoteMediaPath(url)) return url;
      }
    }

    final legacy = data['filePath'];
    return legacy is String && isRemoteMediaPath(legacy) ? legacy : null;
  }

  static bool isRemoteMediaPath(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty || uri.userInfo.isNotEmpty) {
      return false;
    }
    if (uri.scheme == 'gs') return uri.path.length > 1;
    if (uri.scheme != 'https' && uri.scheme != 'http') return false;
    if (uri.host != 'firebasestorage.googleapis.com') return true;

    final path = uri.pathSegments;
    return path.length == 5 &&
        path[0] == 'v0' &&
        path[1] == 'b' &&
        path[2].isNotEmpty &&
        path[3] == 'o' &&
        path[4].isNotEmpty &&
        uri.queryParameters['alt'] == 'media';
  }
}
