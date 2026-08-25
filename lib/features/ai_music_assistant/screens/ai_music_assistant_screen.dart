import 'package:flutter/material.dart';

import '../models/music_assistant_result.dart';
import '../services/music_assistant_logger.dart';
import '../services/music_assistant_service.dart';
import '../services/music_assistant_validator.dart';

class AiMusicAssistantScreen extends StatefulWidget {
  final MusicAssistantService service;

  const AiMusicAssistantScreen({
    super.key,
    required this.service,
  });

  @override
  State<AiMusicAssistantScreen> createState() =>
      _AiMusicAssistantScreenState();
}

class _AiMusicAssistantScreenState
    extends State<AiMusicAssistantScreen> {
  final _ideaController = TextEditingController();
  final _moodController = TextEditingController();
  final _genreController = TextEditingController();

  final _logger = MusicAssistantLogger();

  MusicAssistantResult? _result;
  String? _error;

  bool _safeMode = true;
  bool _loading = false;

  @override
  void dispose() {
    _ideaController.dispose();
    _moodController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    FocusScope.of(context).unfocus();

    final validationError = MusicAssistantValidator.validate(
      idea: _ideaController.text,
      mood: _moodController.text,
      genre: _genreController.text,
    );

    if (validationError != null) {
      setState(() {
        _error = validationError;
        _result = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await widget.service.generate(
        idea: _ideaController.text,
        mood: _moodController.text,
        genre: _genreController.text,
        safeMode: _safeMode,
      );

      _logger.success(
        idea: _ideaController.text,
        safeMode: _safeMode,
        responseSummary:
            '${result.arrangement.length} arrangement sections, '
            '${result.instrumentation.length} instruments',
      );

      if (!mounted) return;

      setState(() {
        _result = result;
      });
    } catch (error) {
      _logger.failure(
        idea: _ideaController.text,
        error: error,
        safeMode: _safeMode,
      );

      if (!mounted) return;

      setState(() {
        _result = null;
        _error =
            'AI generation is temporarily unavailable. '
            'Your song idea has been preserved. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Music Assistant'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _ideaController,
              maxLines: 4,
              maxLength: MusicAssistantValidator.maxIdeaLength,
              decoration: const InputDecoration(
                labelText: 'Song idea',
                hintText:
                    'Example: Emotional Oromo love song with a hopeful ending',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _moodController,
              decoration: const InputDecoration(
                labelText: 'Mood',
                hintText: 'Emotional, uplifting, cinematic...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _genreController,
              decoration: const InputDecoration(
                labelText: 'Genre',
                hintText: 'Oromo pop, 6/8, Afrobeat...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Safe Mode'),
              subtitle: const Text(
                'Keep generated recommendations suitable '
                'for a general audience.',
              ),
              value: _safeMode,
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() {
                        _safeMode = value;
                      });
                    },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _generate,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _loading ? 'Generating...' : 'Generate Production Plan',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              _ResultSection(
                title: 'Production Prompt',
                child: SelectableText(
                  _result!.productionPrompt,
                ),
              ),
              _ResultSection(
                title: 'Arrangement',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0;
                        i < _result!.arrangement.length;
                        i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${i + 1}. ${_result!.arrangement[i]}',
                        ),
                      ),
                  ],
                ),
              ),
              _ResultSection(
                title: 'Instrumentation',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final instrument
                        in _result!.instrumentation)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $instrument'),
                      ),
                  ],
                ),
              ),
              _ResultSection(
                title: 'Production Direction',
                child: SelectableText(
                  _result!.productionDirection,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ResultSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
