/// Songs bundled in older builds used different ids from the same songs on
/// the CDN. Favorites, library, downloads and recently played are saved on the
/// device by id, so without this map a listener's saved songs would vanish the
/// first time the app loads the CDN catalog (or the reverse, if the CDN is
/// unreachable and the bundled songs are shown).
const Map<String, String> kSongIdAliases = {
  // bundled id      : CDN id
  'yosan_getahun': 'yosan-getahun-3obsa',
  'andualem_gosa': 'andualem-gosa-gumgume',
  'shagoye': 'shukri-jamal-marartuu',
};

/// Returns the id of the same song in the catalog that is loaded now.
/// Unknown ids come back unchanged.
String resolveSongId(String id, Set<String> knownIds) {
  if (knownIds.contains(id)) return id;
  final forward = kSongIdAliases[id];
  if (forward != null && knownIds.contains(forward)) return forward;
  for (final entry in kSongIdAliases.entries) {
    if (entry.value == id && knownIds.contains(entry.key)) return entry.key;
  }
  return id;
}

/// Maps every id in [ids] onto the loaded catalog, keeping order and dropping
/// duplicates created by the mapping.
List<String> resolveSongIds(Iterable<String> ids, Set<String> knownIds) {
  final seen = <String>{};
  final out = <String>[];
  for (final id in ids) {
    final resolved = resolveSongId(id, knownIds);
    if (seen.add(resolved)) out.add(resolved);
  }
  return out;
}
