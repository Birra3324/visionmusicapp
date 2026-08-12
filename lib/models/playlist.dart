/// A playlist stores only indices into the global tracks list.
/// This avoids having to serialize full Song objects.
class Playlist {
  final String id;
  final String name;
  final List<int> trackIndices; // indices into AudioManager.tracks

  const Playlist({
    required this.id,
    required this.name,
    required this.trackIndices,
  });

  Playlist copyWith({String? id, String? name, List<int>? trackIndices}) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      trackIndices: trackIndices ?? this.trackIndices,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'trackIndices': trackIndices,
  };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final indicesDynamic = json['trackIndices'] as List<dynamic>? ?? const [];
    final indices = indicesDynamic.map((e) => e as int).toList();

    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      trackIndices: indices,
    );
  }
}
