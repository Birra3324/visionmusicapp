import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visionmusicapp/app/main_shell.dart';
import 'package:visionmusicapp/features/auth/auth_service.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  String? _error;

  Future<void> _continueAsGuest() async {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true;
      _error = null;
    });

    try {
      await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool firebaseReady = AuthService.instance.isFirebaseReady;

    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kDarkCard.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/visionlogo.jpg',
                        height: 72,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.library_music_rounded,
                          size: 56,
                          color: kVisionGoldLight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Vision Music',
                        style: TextStyle(
                          color: kTextMain,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Discover Oromo artists, albums, songs, and music videos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTextSoft, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kVisionGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                          onPressed: (!_isSigningIn && firebaseReady)
                              ? _handleGoogleSignIn
                              : null,
                          icon: _isSigningIn
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(Icons.g_mobiledata_rounded),
                          label: Text(
                            firebaseReady
                                ? 'Sign in with Google'
                                : 'Sign in temporarily unavailable',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!firebaseReady)
                        const Text(
                          'You can continue without signing in.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kTextSoft, fontSize: 12),
                        ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: _isSigningIn ? null : _continueAsGuest,
                        child: Text(
                          l10n.continueAsGuest,
                          style: const TextStyle(color: kTextSoft),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Favorites and recent listening are saved on this device.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTextSoft, fontSize: 12),
                      ),
                      if (firebaseReady) ...[
                        const SizedBox(height: 20),
                        StreamBuilder<User?>(
                          stream: AuthService.instance.authStateChanges(),
                          builder: (context, snapshot) {
                            final user = snapshot.data;
                            if (user == null) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              'Signed in as ${user.email ?? user.displayName ?? 'Vision Music user'}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: kVisionGoldLight,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
