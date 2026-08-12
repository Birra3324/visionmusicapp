import 'package:json_annotation/json_annotation.dart';

part 'playback_settings.g.dart';

@JsonSerializable()
class PlaybackSettings {
  final bool autoplay;
  final bool shuffle;
  final bool repeat;
  final int crossfadeSeconds;
  final String theme; // 'dark', 'light', 'system'
  final String streamingQuality; // 'low', 'normal', 'high'

  const PlaybackSettings({
    this.autoplay = true,
    this.shuffle = false,
    this.repeat = false,
    this.crossfadeSeconds = 0,
    this.theme = 'dark',
    this.streamingQuality = 'high',
  });

  PlaybackSettings copyWith({
    bool? autoplay,
    bool? shuffle,
    bool? repeat,
    int? crossfadeSeconds,
    String? theme,
    String? streamingQuality,
  }) {
    return PlaybackSettings(
      autoplay: autoplay ?? this.autoplay,
      shuffle: shuffle ?? this.shuffle,
      repeat: repeat ?? this.repeat,
      crossfadeSeconds: crossfadeSeconds ?? this.crossfadeSeconds,
      theme: theme ?? this.theme,
      streamingQuality: streamingQuality ?? this.streamingQuality,
    );
  }

  factory PlaybackSettings.fromJson(Map<String, dynamic> json) =>
      _$PlaybackSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$PlaybackSettingsToJson(this);
}
