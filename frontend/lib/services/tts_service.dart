import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _queue = [];
  bool _isSpeaking = false;
  bool _isProcessing = false;
  String _lastSpokenMessage = '';
  DateTime? _lastSpeakTime;
  final Duration _cooldownDuration = const Duration(seconds: 8);

  Future<void> initialize() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _processQueue();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint("TTS Error: $msg");
        _processQueue();
      });
    } catch (e) {
      debugPrint("TTS Initialization Error: $e");
    }
  }

  /// Adds a message to the queue to be spoken sequentially
  void speak(String text) {
    if (text.isEmpty) return;
    
    // Check cooldown - don't repeat same message within cooldown period
    final now = DateTime.now();
    if (_lastSpeakTime != null && 
        text == _lastSpokenMessage && 
        now.difference(_lastSpeakTime!) < _cooldownDuration) {
      debugPrint('TTS: Skipping repeat message (cooldown)');
      return;
    }
    
    _queue.add(text);
    if (!_isProcessing) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_queue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    
    // If already speaking, wait for the completion handler to trigger next
    if (_isSpeaking) return;

    final text = _queue.removeAt(0);
    _lastSpokenMessage = text;
    _lastSpeakTime = DateTime.now();

    try {
      debugPrint('TTS Queue: Speaking: $text');
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS Speak Error: $e");
      _isSpeaking = false;
      _processQueue(); // Try next on error
    }
  }

  /// Clears the queue and stops current speech
  Future<void> clearQueueAndStop() async {
    _queue.clear();
    await stop();
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _isProcessing = false;
    } catch (e) {
      debugPrint("TTS Stop Error: $e");
    }
  }
  
  bool get isSpeaking => _isSpeaking;
}
