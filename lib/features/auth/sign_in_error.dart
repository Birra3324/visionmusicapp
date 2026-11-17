import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';

/// Keep provider diagnostics out of localized listener-facing errors.
String signInErrorMessage(Object error, {AppLocalizations? strings}) {
  final l10n = strings ?? lookupAppLocalizations(const Locale('en'));
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'popup-blocked':
        return l10n.allowSignInWindow;
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return l10n.signInCanceled;
      case 'network-request-failed':
        return l10n.checkConnection;
      case 'too-many-requests':
        return l10n.tryLater;
      case 'user-disabled':
      case 'account-exists-with-different-credential':
        return l10n.accountUnavailable;
    }
  }
  return '${l10n.signInUnavailable}. ${l10n.guestAvailable}';
}
