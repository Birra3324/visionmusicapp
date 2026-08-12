import 'dart:math' as math;

enum MasteringTarget {
  streaming('Streaming', -14, -1),
  youtube('YouTube', -13, -1),
  loud('Loud / Club', -9, -1),
  dynamic('Dynamic', -16, -1);

  const MasteringTarget(this.label, this.lufs, this.truePeak);

  final String label;
  final double lufs;
  final double truePeak;
}

enum MasteringFormat { wav, mp3, aac }

class AudioAnalysis {
  const AudioAnalysis({
    required this.integratedLufs,
    required this.truePeakDbtp,
    required this.loudnessRange,
    required this.durationSeconds,
    required this.sampleRate,
    required this.channels,
  });

  final double integratedLufs;
  final double truePeakDbtp;
  final double loudnessRange;
  final double durationSeconds;
  final int sampleRate;
  final int channels;

  double get dynamicRange => math.max(0, loudnessRange + 3);
}

class MasteringSettings {
  const MasteringSettings({
    this.eq = true,
    this.dynamicEq = true,
    this.compressor = true,
    this.multibandCompressor = true,
    this.saturation = true,
    this.stereoImaging = true,
    this.truePeakLimiter = true,
    this.bassGain = 1.2,
    this.clarityGain = 0.8,
    this.vocalGain = 0.6,
    this.stereoWidth = 1.1,
    this.intensity = 0.65,
    this.target = MasteringTarget.streaming,
    this.format = MasteringFormat.wav,
    this.sampleRate = 44100,
    this.bitDepth = 24,
    this.bitrateKbps = 320,
  });

  final bool eq;
  final bool dynamicEq;
  final bool compressor;
  final bool multibandCompressor;
  final bool saturation;
  final bool stereoImaging;
  final bool truePeakLimiter;
  final double bassGain;
  final double clarityGain;
  final double vocalGain;
  final double stereoWidth;
  final double intensity;
  final MasteringTarget target;
  final MasteringFormat format;
  final int sampleRate;
  final int bitDepth;
  final int bitrateKbps;

  MasteringSettings copyWith({
    bool? eq,
    bool? dynamicEq,
    bool? compressor,
    bool? multibandCompressor,
    bool? saturation,
    bool? stereoImaging,
    bool? truePeakLimiter,
    double? bassGain,
    double? clarityGain,
    double? vocalGain,
    double? stereoWidth,
    double? intensity,
    MasteringTarget? target,
    MasteringFormat? format,
    int? sampleRate,
    int? bitDepth,
    int? bitrateKbps,
  }) {
    return MasteringSettings(
      eq: eq ?? this.eq,
      dynamicEq: dynamicEq ?? this.dynamicEq,
      compressor: compressor ?? this.compressor,
      multibandCompressor: multibandCompressor ?? this.multibandCompressor,
      saturation: saturation ?? this.saturation,
      stereoImaging: stereoImaging ?? this.stereoImaging,
      truePeakLimiter: truePeakLimiter ?? this.truePeakLimiter,
      bassGain: bassGain ?? this.bassGain,
      clarityGain: clarityGain ?? this.clarityGain,
      vocalGain: vocalGain ?? this.vocalGain,
      stereoWidth: stereoWidth ?? this.stereoWidth,
      intensity: intensity ?? this.intensity,
      target: target ?? this.target,
      format: format ?? this.format,
      sampleRate: sampleRate ?? this.sampleRate,
      bitDepth: bitDepth ?? this.bitDepth,
      bitrateKbps: bitrateKbps ?? this.bitrateKbps,
    );
  }
}
