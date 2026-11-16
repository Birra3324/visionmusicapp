import 'package:firebase_auth/firebase_auth.dart';

/// Keep provider diagnostics out of the listener-facing sign-in screen.
String signInErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'unauthorized-domain':
      case 'operation-not-allowed':
        return 'Google sign-in is not available at this address. '
            'Please use the app link or continue as a guest.';
      case 'popup-blocked':
        return 'Allow the Google sign-in window in your browser, then try again.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Sign-in was canceled. Try again or continue as a guest.';
      case 'network-request-failed':
        return 'Could not connect to Google. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please wait a moment and try again.';
      case 'user-disabled':
        return 'This account is unavailable. Please contact support.';
      case 'account-exists-with-different-credential':
        return 'This account uses another sign-in method. Please contact support.';
    }
  }
  return 'Could not sign in. Please try again or continue as a guest.';
}
