/// Select the catalog without substituting demo content in a live build.
Future<List<T>> loadCatalog<T>({
  required bool useFirebase,
  required bool firebaseReady,
  required bool allowLocalFallback,
  required Future<List<T>> Function() loadRemote,
  required Future<List<T>> Function() loadLocal,
}) async {
  if (!useFirebase) return loadLocal();
  if (firebaseReady) {
    final remote = await loadRemote();
    if (remote.isNotEmpty) return remote;
  }
  return allowLocalFallback ? loadLocal() : <T>[];
}
