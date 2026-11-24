import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/features/auth/account_deletion.dart';

class _RecentLogin implements Exception {}

void main() {
  late List<String> calls;
  late int deleteAttempts;

  AccountDeletion build({required int failFirstDeletes, Object? error}) {
    calls = [];
    deleteAttempts = 0;
    return AccountDeletion(
      deleteUser: () async {
        deleteAttempts++;
        calls.add('delete');
        if (deleteAttempts <= failFirstDeletes) throw error ?? _RecentLogin();
      },
      reauthenticate: () async => calls.add('reauth'),
      signOutProviders: () async => calls.add('signOut'),
      isRecentLoginError: (e) => e is _RecentLogin,
    );
  }

  test('deletes the account, then signs out', () async {
    await build(failFirstDeletes: 0).run();
    expect(calls, ['delete', 'signOut']);
  });

  test('asks the listener to sign in again when Firebase needs it', () async {
    await build(failFirstDeletes: 1).run();
    expect(calls, ['delete', 'reauth', 'delete', 'signOut']);
  });

  test('other errors are reported and nothing is signed out', () async {
    final deletion = build(failFirstDeletes: 1, error: StateError('offline'));
    await expectLater(deletion.run(), throwsStateError);
    expect(calls, ['delete']);
  });
}
