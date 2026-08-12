import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../vision_theme.dart';
import '../../domain/recognition_state.dart';
import '../../services/recognition_service.dart';
import '../widgets/recognition_result_view.dart';

class MusicIdentificationScreen extends StatefulWidget {
  const MusicIdentificationScreen({super.key});

  @override
  State<MusicIdentificationScreen> createState() => _MusicIdentificationScreenState();
}

class _MusicIdentificationScreenState extends State<MusicIdentificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicRecognitionService>(
      builder: (context, service, _) {
        final isListening = service.status == MusicRecognitionStatus.listening;
        final hasResult = service.status == MusicRecognitionStatus.matchedInternal ||
            service.status == MusicRecognitionStatus.matchedExternal ||
            service.status == MusicRecognitionStatus.noMatch;

        return Scaffold(
          backgroundColor: kBackgroundDark,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: kTextMain),
              onPressed: () {
                service.cancel();
                Navigator.pop(context);
              },
            ),
          ),
          body: Stack(
            children: [
              if (hasResult && service.result != null || service.status == MusicRecognitionStatus.noMatch)
                RecognitionResultView(
                  result: service.result,
                  status: service.status,
                  onRetry: () => service.startRecognition(),
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMainActionButton(service, isListening),
                      const SizedBox(height: 48),
                      _buildStatusText(service),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainActionButton(MusicRecognitionService service, bool isListening) {
    return GestureDetector(
      onTap: () {
        if (isListening) {
          service.stopAndRecognize();
        } else {
          service.startRecognition();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isListening)
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kVisionGold.withValues(alpha: 0.15),
                ),
              ),
            ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kVisionGold, kVisionGoldDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kVisionGold.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isListening ? Icons.mic_rounded : Icons.search_rounded,
              size: 56,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(MusicRecognitionService service) {
    String text = 'Tap to identify music';
    bool showLoading = false;

    switch (service.status) {
      case MusicRecognitionStatus.listening:
        text = 'Listening...';
        break;
      case MusicRecognitionStatus.uploading:
        text = 'Uploading sample...';
        showLoading = true;
        break;
      case MusicRecognitionStatus.recognizing:
        text = 'Identifying...';
        showLoading = true;
        break;
      case MusicRecognitionStatus.requestingPermission:
        text = 'Requesting microphone access...';
        break;
      case MusicRecognitionStatus.permissionDenied:
        text = 'Microphone permission denied';
        break;
      case MusicRecognitionStatus.networkError:
        text = 'Network error. Try again.';
        break;
      case MusicRecognitionStatus.serviceError:
        text = 'Recognition service unavailable.';
        break;
      default:
        break;
    }

    return Column(
      children: [
        if (showLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: CircularProgressIndicator(color: kVisionGold),
          ),
        Text(
          text,
          style: kStyleHeadline.copyWith(color: kTextMain),
        ),
      ],
    );
  }
}
