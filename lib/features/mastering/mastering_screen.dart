import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';

import 'audio_mastering_service.dart';
import 'mastering_models.dart';

class MasteringScreen extends StatefulWidget {
  const MasteringScreen({super.key});

  @override
  State<MasteringScreen> createState() => _MasteringScreenState();
}

class _MasteringScreenState extends State<MasteringScreen> {
  final _service = AudioMasteringService();
  final _player = AudioPlayer();
  MasteringSettings _settings = const MasteringSettings();
  AudioAnalysis? _before;
  AudioAnalysis? _after;
  String? _inputPath;
  String? _inputName;
  String? _outputPath;
  String? _error;
  bool _busy = false;
  double _progress = 0;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _importSong() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['wav', 'mp3', 'm4a', 'aac', 'flac'],
    );
    final file = result?.files.single;
    if (file?.path == null) return;
    setState(() {
      _busy = true;
      _progress = 0.15;
      _error = null;
      _inputPath = file!.path;
      _inputName = file.name;
      _outputPath = null;
      _after = null;
    });
    try {
      final analysis = await _service.analyze(file!.path!);
      if (!mounted) return;
      setState(() {
        _before = analysis;
        _progress = 1;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _master() async {
    if (_inputPath == null || _inputName == null) {
      setState(() => _error = 'Import a song before mastering.');
      return;
    }
    setState(() {
      _busy = true;
      _progress = 0.35;
      _error = null;
    });
    try {
      final output = await _service.master(
        inputPath: _inputPath!,
        sourceName: _inputName!,
        settings: _settings,
      );
      if (!mounted) return;
      setState(() {
        _outputPath = output;
        _progress = 0.82;
      });
      final analysis = await _service.analyze(output);
      if (!mounted) return;
      setState(() {
        _after = analysis;
        _progress = 1;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _preview(bool enhanced) async {
    final path = enhanced ? _outputPath : _inputPath;
    if (path == null) return;
    try {
      await _player.setFilePath(path);
      await _player.play();
    } catch (error) {
      if (mounted) setState(() => _error = 'Preview failed: $error');
    }
  }

  Future<void> _export() async {
    final output = _outputPath;
    if (output == null) return;
    final savedPath = await FilePicker.saveFile(
      dialogTitle: 'Save mastered audio',
      fileName: output.split('/').last,
      bytes: await File(output).readAsBytes(),
    );
    if (!mounted || savedPath == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mastered audio exported successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Master Audio'),
          backgroundColor: Colors.transparent,
          actions: [
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                      _settings = const MasteringSettings();
                      _outputPath = null;
                      _after = null;
                    }),
              child: const Text('Reset'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
          children: [
            _hero(),
            if (_busy) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _progress,
                color: kVisionGoldLight,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              _message(_error!, Colors.redAccent),
            ],
            const SizedBox(height: 16),
            if (_before != null) _comparison(),
            const SizedBox(height: 16),
            _targetCard(),
            const SizedBox(height: 16),
            _toneCard(),
            const SizedBox(height: 16),
            _modulesCard(),
            const SizedBox(height: 16),
            _exportCard(),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _busy || _inputPath == null ? null : _master,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(_outputPath == null ? 'Auto Master' : 'Master Again'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
                backgroundColor: const Color(0xFF7B35CC),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.graphic_eq_rounded, color: Color(0xFFB26DFF), size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Professional mastering on your device',
                style: TextStyle(
                  color: kTextMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _inputName ?? 'Import WAV, MP3, M4A, AAC, or FLAC audio.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kTextSoft, height: 1.4),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _busy ? null : _importSong,
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(_inputPath == null ? 'Import Song' : 'Choose Another'),
        ),
      ],
    ),
  );

  Widget _comparison() => _card(
    title: 'A / B Compare',
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _analysisColumn('Original', _before!, false)),
            const SizedBox(width: 10),
            Expanded(
              child: _after == null
                  ? _emptyResult()
                  : _analysisColumn('Mastered', _after!, true),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _analysisColumn(String title, AudioAnalysis value, bool enhanced) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: enhanced ? const Color(0xFFB26DFF) : kTextMain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${value.integratedLufs.toStringAsFixed(1)} LUFS',
            style: const TextStyle(
              color: kTextMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${value.truePeakDbtp.toStringAsFixed(1)} dBTP',
            style: const TextStyle(color: kTextSoft, fontSize: 12),
          ),
          Text(
            'LRA ${value.loudnessRange.toStringAsFixed(1)}',
            style: const TextStyle(color: kTextSoft, fontSize: 12),
          ),
          IconButton.filledTonal(
            onPressed: enhanced && _outputPath == null
                ? null
                : () => _preview(enhanced),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }

  Widget _emptyResult() => Container(
    height: 142,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Text(
      'Master to see\nfinal measurements',
      textAlign: TextAlign.center,
      style: TextStyle(color: kTextSoft),
    ),
  );

  Widget _targetCard() => _card(
    title: 'Mastering Target',
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MasteringTarget.values.map((target) {
        return ChoiceChip(
          label: Text('${target.label}\n${target.lufs.toInt()} LUFS'),
          selected: _settings.target == target,
          onSelected: (_) =>
              setState(() => _settings = _settings.copyWith(target: target)),
        );
      }).toList(),
    ),
  );

  Widget _toneCard() => _card(
    title: 'Tone & Intensity',
    child: Column(
      children: [
        _slider(
          'Bass',
          _settings.bassGain,
          -3,
          3,
          (v) => _settings.copyWith(bassGain: v),
        ),
        _slider(
          'Clarity',
          _settings.clarityGain,
          -3,
          3,
          (v) => _settings.copyWith(clarityGain: v),
        ),
        _slider(
          'Vocal Presence',
          _settings.vocalGain,
          -3,
          3,
          (v) => _settings.copyWith(vocalGain: v),
        ),
        _slider(
          'Stereo Width',
          _settings.stereoWidth,
          0.7,
          1.3,
          (v) => _settings.copyWith(stereoWidth: v),
        ),
        _slider(
          'Intensity',
          _settings.intensity,
          0,
          1,
          (v) => _settings.copyWith(intensity: v),
        ),
      ],
    ),
  );

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    MasteringSettings Function(double) update,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(color: kTextMain, fontSize: 13),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: _busy
                ? null
                : (v) => setState(() => _settings = update(v)),
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.end,
            style: const TextStyle(color: kTextSoft, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _modulesCard() => _card(
    title: 'DSP Engine',
    child: Column(
      children: [
        _module(
          'EQ',
          Icons.equalizer_rounded,
          _settings.eq,
          (v) => _settings.copyWith(eq: v),
        ),
        _module(
          'Dynamic EQ / De-esser',
          Icons.auto_graph_rounded,
          _settings.dynamicEq,
          (v) => _settings.copyWith(dynamicEq: v),
        ),
        _module(
          'Compressor',
          Icons.compress_rounded,
          _settings.compressor,
          (v) => _settings.copyWith(compressor: v),
        ),
        _module(
          'Multiband Compressor',
          Icons.multiline_chart_rounded,
          _settings.multibandCompressor,
          (v) => _settings.copyWith(multibandCompressor: v),
        ),
        _module(
          'Saturation',
          Icons.local_fire_department_outlined,
          _settings.saturation,
          (v) => _settings.copyWith(saturation: v),
        ),
        _module(
          'Stereo Imaging',
          Icons.surround_sound_rounded,
          _settings.stereoImaging,
          (v) => _settings.copyWith(stereoImaging: v),
        ),
        _module(
          'True-Peak Limiter',
          Icons.speed_rounded,
          _settings.truePeakLimiter,
          (v) => _settings.copyWith(truePeakLimiter: v),
        ),
      ],
    ),
  );

  Widget _module(
    String label,
    IconData icon,
    bool value,
    MasteringSettings Function(bool) update,
  ) => SwitchListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    secondary: Icon(icon, color: const Color(0xFFB26DFF)),
    title: Text(label, style: const TextStyle(color: kTextMain)),
    value: value,
    onChanged: _busy ? null : (v) => setState(() => _settings = update(v)),
  );

  Widget _exportCard() => _card(
    title: 'Export',
    child: Column(
      children: [
        SegmentedButton<MasteringFormat>(
          segments: MasteringFormat.values
              .map(
                (format) => ButtonSegment(
                  value: format,
                  label: Text(format.name.toUpperCase()),
                ),
              )
              .toList(),
          selected: {_settings.format},
          onSelectionChanged: (values) => setState(
            () => _settings = _settings.copyWith(format: values.first),
          ),
        ),
        if (_outputPath != null) ...[
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _export,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Export Mastered Audio'),
          ),
        ],
      ],
    ),
  );

  Widget _message(String text, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Text(text, style: TextStyle(color: color)),
  );

  Widget _card({String? title, required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kDarkCard.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFC58BFF),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
        ],
        child,
      ],
    ),
  );
}
