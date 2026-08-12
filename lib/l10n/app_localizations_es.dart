// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Música Vision';

  @override
  String get home => 'Inicio';

  @override
  String get search => 'Búsqueda';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausa';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get shuffle => 'Mezclar';

  @override
  String get repeat => 'Repetir';

  @override
  String get lyrics => 'Letras';

  @override
  String get detectLanguage => 'Detectar idioma';

  @override
  String get detectSong => 'Detectar canción';

  @override
  String get settings => 'Configuración';

  @override
  String get equalizer => 'Ecualizador';

  @override
  String get speed => 'Velocidad';

  @override
  String get loop => 'Bucle';

  @override
  String get transpose => 'Transposición';

  @override
  String get language => 'Idioma';

  @override
  String get languageChanged => 'Idioma cambiado a español';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get aiTranslationNotConnected =>
      'Motor de traducción de IA no conectado aún';

  @override
  String get generateLyrics => 'Generar letras';

  @override
  String get translateLyrics => 'Traducir letras';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get originalLyrics => 'Letras originales';

  @override
  String get translatedLyrics => 'Letras traducidas';

  @override
  String get noLyricsAvailable => 'No hay letras disponibles';

  @override
  String get audioLanguageDetectionComing =>
      'Detección de idioma de audio próximamente';

  @override
  String get watch => 'Ver';

  @override
  String get library => 'Biblioteca';

  @override
  String get profile => 'Perfil';

  @override
  String get playback => 'Reproducción';

  @override
  String get autoplay => 'Reproducción automática';

  @override
  String get autoplayDescription =>
      'Reproducir automáticamente la siguiente canción relacionada';

  @override
  String get shuffleDescription => 'Reproducir canciones en orden aleatorio';

  @override
  String get repeatDescription => 'Repetir la cola actual';

  @override
  String get searchDescription =>
      'Busca canciones, artistas y álbumes en el catálogo de Vision Music.';

  @override
  String get searchHint => 'Canciones, artistas, álbumes…';

  @override
  String get searchQuestion => '¿Qué quieres escuchar?';

  @override
  String get searchInstructions => 'Busca por canción, artista o álbum.';

  @override
  String get noMatches => 'No se encontraron resultados.';

  @override
  String get continueAsGuest => 'Continuar como invitado';
}
