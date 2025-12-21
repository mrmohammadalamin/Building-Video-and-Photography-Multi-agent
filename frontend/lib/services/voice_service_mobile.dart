import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Native platform implementation using speech_to_text
class VoiceServiceImpl {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Failed to initialize speech: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onStateChange,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call("Microphone not available");
        return;
      }
    }

    if (_isListening) return;

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        listenMode: stt.ListenMode.confirmation,
      );
      _isListening = true;
      onStateChange(true);
    } catch (e) {
      debugPrint('Error starting to listen: $e');
      onError?.call("Voice error: $e");
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      await _speech.stop();
      _isListening = false;
    } catch (e) {
      debugPrint('Error stopping: $e');
    }
  }

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  void dispose() {
    _speech.cancel();
  }
}
