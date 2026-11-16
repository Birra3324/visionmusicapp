// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Vision Music';

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
      'Reproducir automáticamente la siguiente canción de la cola';

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

  @override
  String get welcome => 'Te damos la bienvenida a Vision Music';

  @override
  String greeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get recent => 'Recientes';

  @override
  String get all => 'Todo';

  @override
  String get added => 'Añadidos';

  @override
  String get listen => 'Escuchar';

  @override
  String get music => 'Música';

  @override
  String get videos => 'Vídeos';

  @override
  String get exploreMusic => 'Explorar música';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get audioCatalogTitle =>
      'Nuestro catálogo de audio estará disponible pronto';

  @override
  String get audioCatalogDescription =>
      'Descubre los vídeos oficiales de Vision Entertainment mientras preparamos los lanzamientos de audio.';

  @override
  String get watchMusicVideos => 'Ver vídeos musicales';

  @override
  String get guestListener => 'Oyente invitado';

  @override
  String get activitySaved =>
      'Tu actividad de escucha se guarda en este dispositivo.';

  @override
  String get loginDescription =>
      'Descubre artistas oromo, álbumes, canciones y vídeos musicales.';

  @override
  String get signInGoogle => 'Iniciar sesión con Google';

  @override
  String get signInUnavailable =>
      'Inicio de sesión no disponible temporalmente';

  @override
  String get guestAvailable => 'Puedes continuar sin iniciar sesión.';

  @override
  String get localActivity =>
      'Los favoritos y el historial se guardan en este dispositivo.';

  @override
  String signedInAs(String name) {
    return 'Sesión iniciada como $name';
  }

  @override
  String get favorites => 'Favoritos';

  @override
  String get favoritesHint =>
      'Toca el corazón de una canción para guardarla aquí.';

  @override
  String get favoritesEmpty => 'Tus favoritos aparecerán aquí.';

  @override
  String get exploreCatalog => 'Explorar el catálogo';

  @override
  String get recentlyPlayed => 'Reproducidas recientemente';

  @override
  String get recentHint => 'Aquí aparecerá lo que has escuchado.';

  @override
  String get recentEmpty => 'Reproduce una canción para iniciar tu historial.';

  @override
  String get yourCollection => 'Tu colección';

  @override
  String get collectionHint => 'Tu música y tus listas guardadas.';

  @override
  String get playlists => 'Listas de reproducción';

  @override
  String get playlistsHint => 'Crea y organiza tus listas';

  @override
  String get artists => 'Artistas';

  @override
  String get albums => 'Álbumes';

  @override
  String get songs => 'Canciones';

  @override
  String get noAlbums => 'Todavía no hay álbumes.';

  @override
  String songCount(int count) {
    return 'Canciones: $count';
  }

  @override
  String artistCount(int count) {
    return 'Artistas: $count';
  }

  @override
  String albumCount(int count) {
    return 'Álbumes: $count';
  }

  @override
  String favoriteCount(int count) {
    return 'Favoritos: $count';
  }

  @override
  String recentCount(int count) {
    return 'Reproducidas recientemente: $count';
  }

  @override
  String get videoLibraryHint => 'Vídeos musicales, pódcasts y más';

  @override
  String get removeFavorite => 'Quitar de favoritos';

  @override
  String get addFavorite => 'Añadir a favoritos';

  @override
  String get channelDescription =>
      'Descubre nuestros vídeos musicales en YouTube.';

  @override
  String get openChannel => 'Abrir el canal de YouTube';

  @override
  String get loadingVideos => 'Cargando vídeos…';

  @override
  String get videoLoadError => 'No se pudieron cargar los vídeos';

  @override
  String get checkConnection => 'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get searchVideos => 'Buscar vídeos';

  @override
  String get videoSearchHint => 'Vídeos y artistas';

  @override
  String get clear => 'Borrar';

  @override
  String get back => 'Volver';

  @override
  String get noVideoMatches => 'No hay vídeos coincidentes.';

  @override
  String get featured => 'Destacados';

  @override
  String get upNext => 'A continuación';

  @override
  String get openYouTube => 'Abrir en YouTube';

  @override
  String get watchYouTube => 'Ver en YouTube';

  @override
  String get playVideo => 'Reproducir vídeo';

  @override
  String get videoUnpublished => 'Este vídeo aún no se ha publicado.';

  @override
  String get videoPlaybackError =>
      'No se pudo reproducir el vídeo. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get noCategoryVideos => 'No hay vídeos en esta categoría';

  @override
  String get youTubeError => 'No se pudo abrir YouTube. Inténtalo de nuevo.';

  @override
  String get lyricsLoadError => 'No se pudo cargar la letra';

  @override
  String get tryLater => 'Inténtalo de nuevo en un momento.';

  @override
  String get lyricsUnavailable => 'La letra aún no está disponible';

  @override
  String get lyricsSourceHint =>
      'Solo mostramos letras del artista o de una fuente autorizada.';

  @override
  String get volume => 'Volumen';

  @override
  String volumePercent(int count) {
    return '$count por ciento';
  }

  @override
  String get noSongPlaying => 'No se está reproduciendo ninguna canción';

  @override
  String get playbackPosition => 'Posición de reproducción';

  @override
  String get songPlaybackError =>
      'No se pudo reproducir la canción. Inténtalo de nuevo.';

  @override
  String get newPlaylist => 'Nueva lista';

  @override
  String get renamePlaylist => 'Renombrar lista';

  @override
  String get playlistName => 'Nombre de la lista';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get rename => 'Renombrar';

  @override
  String get deletePlaylistTitle => '¿Eliminar la lista?';

  @override
  String deletePlaylistMessage(String name) {
    return '¿Eliminar «$name»? Las canciones seguirán en tu catálogo.';
  }

  @override
  String get createPlaylist => 'Crear lista';

  @override
  String get noPlaylists => 'No hay listas';

  @override
  String managePlaylist(String name) {
    return 'Gestionar $name';
  }

  @override
  String get emptyPlaylist =>
      'Esta lista está vacía. Añade canciones desde su menú.';

  @override
  String moreSongOptions(String title) {
    return 'Más opciones para $title';
  }

  @override
  String get removeFromPlaylist => 'Quitar de la lista';

  @override
  String get addToQueue => 'Añadir a la cola';

  @override
  String get removeFromLibrary => 'Quitar de la biblioteca';

  @override
  String get addToLibrary => 'Añadir a la biblioteca';

  @override
  String get addToPlaylist => 'Añadir a una lista';

  @override
  String get share => 'Compartir';

  @override
  String get shareCopied => 'Texto para compartir copiado.';

  @override
  String get addedToPlaylist => 'Añadido a la lista.';

  @override
  String watchSong(String title) {
    return 'Ver $title en YouTube';
  }

  @override
  String playSong(String title) {
    return 'Reproducir $title';
  }

  @override
  String playSongBy(String artist, String title) {
    return 'Reproducir $title de $artist';
  }

  @override
  String get startupError => 'No se pudo iniciar Vision Music.';

  @override
  String get loadingApp => 'Abriendo Vision Music…';

  @override
  String get slowConnection =>
      'Esto está tardando más de lo habitual. Comprueba tu conexión.';

  @override
  String get allowSignInWindow =>
      'Permite la ventana de inicio de sesión de Google en tu navegador y vuelve a intentarlo.';

  @override
  String get signInCanceled =>
      'Se canceló el inicio de sesión. Inténtalo de nuevo o continúa como invitado.';

  @override
  String get accountUnavailable =>
      'Esta cuenta no está disponible. Contacta con soporte.';

  @override
  String get noArtistSongs => 'Todavía no hay canciones de este artista.';

  @override
  String get categoryMusic => 'Vídeos musicales';

  @override
  String get categoryLive => 'Actuaciones en directo';

  @override
  String get categoryStudio => 'Sesiones de estudio';

  @override
  String get categoryInterviews => 'Entrevistas';

  @override
  String get categoryPodcasts => 'Fragmentos de pódcasts';

  @override
  String get categoryConcerts => 'Conciertos';

  @override
  String get categoryNew => 'Nuevos lanzamientos';

  @override
  String get categoryClassics => 'Clásicos oromo';
}
