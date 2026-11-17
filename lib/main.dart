import 'package:visionmusicapp/l10n/listener_strings.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import 'package:visionmusicapp/l10n/localization_delegates.dart';
import 'package:provider/provider.dart';
import 'package:visionmusicapp/audio/audio_handler.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/core/services/app_config.dart';
import 'package:visionmusicapp/core/services/catalog_loader.dart';
import 'package:visionmusicapp/core/services/app_observability.dart';
import 'package:visionmusicapp/core/services/firebase_bootstrap.dart';
import 'package:visionmusicapp/core/services/firestore_song_repository.dart';
import 'package:visionmusicapp/core/services/local_song_repository.dart';
import 'package:visionmusicapp/core/services/song_repository.dart';
import 'package:visionmusicapp/core/services/video_service.dart';
import 'package:visionmusicapp/features/auth/login_screen.dart';
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
    try {
      await AppObservability.instance
          .initialize(firebaseReady: _firebaseBootstrapResult?.isReady ?? false)
          .timeout(const Duration(seconds: 3));
    } catch (error) {
      debugPrint('Optional observability initialization unavailable: $error');
    }

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
      repository: MusicRecognitionRepository(
        baseUrl: AppConfig.recognitionBaseUrl,
      ),
    );
  }

  Future<List<Song>> _loadCatalog() => loadCatalog<Song>(
    useFirebase: AppConfig.useFirebaseCatalog,
    firebaseReady: _firebaseBootstrapResult?.isReady ?? false,
    allowLocalFallback: AppConfig.fallbackToLocalOnEmpty,
    loadRemote: () => FirestoreSongRepository().fetchAll(),
    loadLocal: () async {
      const SongRepository local = LocalSongRepository();
      return local.fetchAll();
    },
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: SettingsManager.instance.locale,
            localizationsDelegates: visionLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: buildVisionGoldTheme(),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!snapshot.hasError)
                          const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(
                          snapshot.hasError
                              ? context.l10n.startupError
                              : context.l10n.loadingApp,
                          textAlign: TextAlign.center,
                        ),
                        if (snapshot.hasError) ...[
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.checkConnection,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
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
      localizationsDelegates: visionLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
