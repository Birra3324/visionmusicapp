/// Deletes the signed-in listener's Vision Music account.
///
/// Google Play and the App Store require that anyone who can create an account
/// can also delete it from inside the app. Vision Music keeps no per-user
/// documents in Firestore (playlists and history live on the device), so
/// deleting the Firebase Auth user removes everything the account holds.
///
/// Firebase refuses to delete an account whose last sign-in is not recent
/// (`requires-recent-login`). In that case the listener signs in with Google
/// again and the delete is retried once.
class AccountDeletion {
  AccountDeletion({
    required this.deleteUser,
    required this.reauthenticate,
    required this.signOutProviders,
    required this.isRecentLoginError,
  });

  final Future<void> Function() deleteUser;
  final Future<void> Function() reauthenticate;
  final Future<void> Function() signOutProviders;
  final bool Function(Object error) isRecentLoginError;

  Future<void> run() async {
    try {
      await deleteUser();
    } catch (error) {
      if (!isRecentLoginError(error)) rethrow;
      await reauthenticate();
      await deleteUser();
    }
    await signOutProviders();
  }
}
