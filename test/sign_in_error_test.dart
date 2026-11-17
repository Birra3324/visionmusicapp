import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/features/auth/sign_in_error.dart';

void main() {
  test('provider diagnostics never appear in listener-facing errors', () {
    const diagnostic = 'INTERNAL_DIAGNOSTIC_WITH_ACCOUNT_DETAILS';
    for (final code in [
      'unauthorized-domain',
      'operation-not-allowed',
      'popup-blocked',
      'popup-closed-by-user',
      'cancelled-popup-request',
      'network-request-failed',
      'too-many-requests',
      'user-disabled',
      'account-exists-with-different-credential',
      'unknown-provider-error',
    ]) {
      final message = signInErrorMessage(
        FirebaseAuthException(code: code, message: diagnostic),
      );
      expect(message, isNotEmpty);
      expect(message, isNot(contains(diagnostic)));
      expect(message, isNot(contains(code)));
    }
    expect(
      signInErrorMessage(Exception(diagnostic)),
      isNot(contains(diagnostic)),
    );
  });

  test(
    'canceling sign-in offers recovery without reporting account failure',
    () {
      final message = signInErrorMessage(
        FirebaseAuthException(code: 'popup-closed-by-user'),
      );
      expect(message.toLowerCase(), contains('canceled'));
      expect(message.toLowerCase(), contains('guest'));
      expect(message.toLowerCase(), isNot(contains('disabled')));
    },
  );
}
