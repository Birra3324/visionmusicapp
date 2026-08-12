import 'dart:convert';

import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:path_provider/path_provider.dart';

import 'mastering_models.dart';

class MasteringException implements Exception {
  const MasteringException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AudioMasteringService {
  Future<AudioAnalysis> analyze(String inputPath) async {
    final infoSession = await FFprobeKit.getMediaInformation(inputPath);
    final info = infoSession.getMediaInformation();
    if (info == null) {
      throw const MasteringException('This audio file could not be decoded.');
    }

    final properties = info.getAllProperties() ?? const <String, dynamic>{};
    final streams = (properties['streams'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final audioStream = streams.cast<Map<String, dynamic>?>().firstWhere(
      (stream) => stream?['codec_type'] == 'audio',
      orElse: () => null,
    );
    final sampleRate =
        int.tryParse('${audioStream?['sample_rate'] ?? 44100}') ?? 44100;
    final channels = (audioStream?['channels'] as num?)?.toInt() ?? 2;
    final duration =
        double.tryParse('${properties['format']?['duration'] ?? 0}') ??
        double.tryParse(info.getDuration() ?? '') ??
        0;

    final command =
        '-hide_banner -i ${quote(inputPath)} -af '
        'loudnorm=I=-14:TP=-1:LRA=11:print_format=json -f null -';
    final session = await FFmpegKit.execute(command);
    final logs = await session.getAllLogsAsString();
    final values = _lastJsonObject(logs ?? '');

    return AudioAnalysis(
      integratedLufs: _number(values['input_i'], -18),
      truePeakDbtp: _number(values['input_tp'], -2),
      loudnessRange: _number(values['input_lra'], 8),
      durationSeconds: duration,
      sampleRate: sampleRate,
      channels: channels,
    );
  }

  Future<String> master({
    required String inputPath,
    required String sourceName,
    required MasteringSettings settings,
  }) async {
    final directory = await getTemporaryDirectory();
    final base = sourceName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final extension = settings.format.name;
    final outputPath =
        '${directory.path}/${base}_vision_master_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final filters = buildFilterChain(settings);
    final codec = switch (settings.format) {
      MasteringFormat.wav => '-c:a pcm_s${settings.bitDepth == 16 ? 16 : 24}le',
      MasteringFormat.mp3 => '-c:a libmp3lame -b:a ${settings.bitrateKbps}k',
      MasteringFormat.aac => '-c:a aac -b:a ${settings.bitrateKbps}k',
    };
    final command =
        '-y -hide_banner -i ${quote(inputPath)} -vn -af ${quote(filters)} '
        '-ar ${settings.sampleRate} $codec ${quote(outputPath)}';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      final output = await session.getOutput();
      final lines = output?.split('\n') ?? const <String>[];
      final detail = lines.isEmpty ? '' : lines.last;
      throw MasteringException('Mastering failed. $detail'.trim());
    }
    return outputPath;
  }

  String buildFilterChain(MasteringSettings settings) {
    final filters = <String>['highpass=f=25'];
    if (settings.eq) {
      filters.addAll([
        'equalizer=f=90:t=q:w=0.8:g=${settings.bassGain.toStringAsFixed(2)}',
        'equalizer=f=3500:t=q:w=1.1:g=${settings.clarityGain.toStringAsFixed(2)}',
        'equalizer=f=1800:t=q:w=1.2:g=${settings.vocalGain.toStringAsFixed(2)}',
      ]);
    }
    if (settings.dynamicEq) {
      filters.add(
        'deesser=i=${(0.12 + settings.intensity * 0.18).toStringAsFixed(3)}',
      );
    }
    if (settings.compressor) {
      final ratio = 1.8 + settings.intensity * 2.2;
      filters.add(
        'acompressor=threshold=-18dB:ratio=${ratio.toStringAsFixed(2)}:'
        'attack=20:release=220:makeup=1.5dB',
      );
    }
    if (settings.multibandCompressor) {
      filters.add(
        'mcompand=0.01,0.10 6:-70,-60,-20 -5 -90 0.05,0.20 '
        '6:-70,-60,-18 -4 -90 0.10,0.30 6:-70,-60,-16 -3 -90 '
        '200 2000',
      );
    }
    if (settings.saturation) {
      filters.add('asoftclip=type=tanh:threshold=0.95:output=0.95');
    }
    if (settings.stereoImaging) {
      filters.add(
        'stereotools=mlev=${settings.stereoWidth.toStringAsFixed(2)}',
      );
    }
    filters.add(
      'loudnorm=I=${settings.target.lufs}:TP=${settings.target.truePeak}:LRA=11',
    );
    if (settings.truePeakLimiter) {
      filters.add('alimiter=limit=0.891:attack=5:release=50:level=false');
    }
    return filters.join(',');
  }

  String quote(String value) => "'${value.replaceAll("'", "'\\''")}'";

  Map<String, dynamic> _lastJsonObject(String value) {
    final matches = RegExp(r'\{[\s\S]*?\}').allMatches(value).toList();
    for (final match in matches.reversed) {
      try {
        return jsonDecode(match.group(0)!) as Map<String, dynamic>;
      } catch (_) {}
    }
    return const {};
  }

  double _number(dynamic value, double fallback) =>
      double.tryParse('$value') ?? fallback;
}
