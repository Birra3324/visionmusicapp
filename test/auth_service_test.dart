import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/features/auth/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Firebase is not ready until initializeApp has run', () {
    expect(AuthService.instance.isFirebaseReady, isFalse);
  });

  test('signOut is a no-op when Firebase was never initialized', () async {
    await AuthService.instance.signOut();
  });
}
