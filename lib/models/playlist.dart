/// Song IDs keep playlists stable when the catalog is reordered or replaced.
class Playlist {
  final String id;
  final String name;
  final List<String> trackIds;

  /// Preserve old sample-era references for recovery, but never resolve their
  /// positions against a new catalog: those positions could identify any song.
  final List<int> legacyTrackIndices;

  const Playlist({
    required this.id,
    required this.name,
    this.trackIds = const [],
    this.legacyTrackIndices = const [],
  });

  Playlist copyWith({String? id, String? name, List<String>? trackIds}) =>
      Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        trackIds: trackIds ?? this.trackIds,
        legacyTrackIndices: legacyTrackIndices,
      );

  Map<String, dynamic> toJson() => {
    'schemaVersion': 2,
    'id': id,
    'name': name,
    'trackIds': trackIds,
    if (legacyTrackIndices.isNotEmpty) 'trackIndices': legacyTrackIndices,
  };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    id: json['id'] as String,
    name: json['name'] as String,
    trackIds: (json['trackIds'] as List<dynamic>? ?? const []).cast<String>(),
    legacyTrackIndices: (json['trackIndices'] as List<dynamic>? ?? const [])
        .cast<int>(),
  );
}
