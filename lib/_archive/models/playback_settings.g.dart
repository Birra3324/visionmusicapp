// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaybackSettings _$PlaybackSettingsFromJson(Map<String, dynamic> json) =>
    PlaybackSettings(
      autoplay: json['autoplay'] as bool? ?? true,
      shuffle: json['shuffle'] as bool? ?? false,
      repeat: json['repeat'] as bool? ?? false,
      crossfadeSeconds: (json['crossfadeSeconds'] as num?)?.toInt() ?? 0,
      theme: json['theme'] as String? ?? 'dark',
      streamingQuality: json['streamingQuality'] as String? ?? 'high',
    );

Map<String, dynamic> _$PlaybackSettingsToJson(PlaybackSettings instance) =>
    <String, dynamic>{
      'autoplay': instance.autoplay,
      'shuffle': instance.shuffle,
      'repeat': instance.repeat,
      'crossfadeSeconds': instance.crossfadeSeconds,
      'theme': instance.theme,
      'streamingQuality': instance.streamingQuality,
    };
