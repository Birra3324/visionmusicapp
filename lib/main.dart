import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:visionmusicapp/audio/audio_handler.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/core/services/app_config.dart';
import 'package:visionmusicapp/core/services/app_observability.dart';
import 'package:visionmusicapp/core/services/firebase_bootstrap.dart';
import 'package:visionmusicapp/core/services/firestore_song_repository.dart';
import 'package:visionmusicapp/core/services/local_song_repository.dart';
import 'package:visionmusicapp/core/services/song_repository.dart';
import 'package:visionmusicapp/core/services/video_service.dart';
import 'package:visionmusicapp/features/auth/login_screen.dart';
import 'package:visionmusicapp/mock_songs.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/features/recognition/services/recognition_service.dart';
import 'package:visionmusicapp/features/recognition/services/recognition_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrapper());
}

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  late Future<void> _initFuture;
  late final AudioManager _audioManager;
  late final MusicRecognitionService _recognitionService;
  FirebaseBootstrapResult? _firebaseBootstrapResult;

  @override
  void initState() {
    super.initState();
    _initFuture = _initServices();
  }

  Future<void> _initServices() async {
    await SettingsManager.instance.init();

    _firebaseBootstrapResult = await FirebaseBootstrap.initialize();
    await AppObservability.instance.initialize(
      firebaseReady: _firebaseBootstrapResult?.isReady ?? false,
    );

    // Initialise video service (uses Firebase if available)
    VideoServiceLocator.init();

    final tracks = await _loadCatalog();
    _audioManager = AudioManager(initialTracks: tracks);
    await _audioManager.initializePersistentState();

    await AudioService.init(
      builder: () => VisionAudioHandler(_audioManager),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.visionmusic.app.channel.audio',
        androidNotificationChannelName: 'Vision Music',
        androidNotificationOngoing: true,
      ),
    );

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _recognitionService = MusicRecognitionService(
      repository: MusicRecognitionRepository(baseUrl: 'http://127.0.0.1:8081'),
    );
  }

  Future<List<Song>> _loadCatalog() async {
    final firebaseReady = _firebaseBootstrapResult?.isReady ?? false;
    if (AppConfig.useFirebaseCatalog && firebaseReady) {
      final SongRepository remote = FirestoreSongRepository();
      final remoteTracks = await remote.fetchAll();
      if (remoteTracks.isNotEmpty) return remoteTracks;
      if (!AppConfig.fallbackToLocalOnEmpty) return remoteTracks;
    }
    // Default / fallback: bundled mock catalog.
    const SongRepository local = LocalSongRepository();
    final localTracks = await local.fetchAll();
    return localTracks.isEmpty ? List<Song>.from(mockSongs) : localTracks;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFC39A4A)),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Startup failed:\n${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _audioManager),
            ChangeNotifierProvider.value(value: SettingsManager.instance),
            ChangeNotifierProvider.value(value: _recognitionService),
          ],
          child: VisionMusicApp(
            firebaseBootstrapResult: _firebaseBootstrapResult,
          ),
        );
      },
    );
  }
}

class VisionMusicApp extends StatelessWidget {
  final FirebaseBootstrapResult? firebaseBootstrapResult;

  const VisionMusicApp({super.key, required this.firebaseBootstrapResult});

  @override
  Widget build(BuildContext context) {
    final settingsManager = context.watch<SettingsManager>();
    final isRTL = settingsManager.localeCode == 'ar';

    return MaterialApp(
      title: 'Vision Music',
      debugShowCheckedModeBanner: false,
      theme: buildVisionGoldTheme(),
      darkTheme: buildVisionGoldTheme(),
      themeMode: ThemeMode.dark,
      locale: settingsManager.locale,
      // Localization support
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('om'), // Afaan Oromo
        Locale('am'), // Amharic
        Locale('ar'), // Arabic
        Locale('fr'), // French
        Locale('es'), // Spanish
      ],
      builder: (context, child) {
        // Ensure RTL is applied for Arabic
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: LoginScreen(
        key: ValueKey(firebaseBootstrapResult?.isReady ?? false),
      ),
    );
  }
}
