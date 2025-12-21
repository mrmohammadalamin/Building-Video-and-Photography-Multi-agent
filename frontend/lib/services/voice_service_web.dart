import 'dart:js' as js;
import 'package:flutter/foundation.dart';

/// Web implementation using voice_helper.js
class VoiceServiceImpl {
  bool _isListening = false;
  
  Future<bool> initialize() async {
    // Check if voice_helper.js is loaded
    final hasHelper = js.context.hasProperty('voiceHelper');
    debugPrint('VoiceHelper available: $hasHelper');
    return hasHelper;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onStateChange,
    Function(String)? onError,
  }) async {
    try {
      final voiceHelper = js.context['voiceHelper'];
      
      if (voiceHelper == null) {
        onError?.call('Voice helper not available');
        return;
      }

      // Create JS-compatible callbacks
      final jsOnResult = js.allowInterop((String text) {
        debugPrint('Web voice result: $text');
        onResult(text);
      });

      final jsOnStateChange = js.allowInterop((bool listening) {
        debugPrint('Web voice state: $listening');
        _isListening = listening;
        onStateChange(listening);
      });

      // Call the JS method
      voiceHelper.callMethod('startListening', [jsOnResult, jsOnStateChange]);
      
      debugPrint('Web voice started');
    } catch (e) {
      debugPrint('Web voice error: $e');
      onError?.call('Error: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      final voiceHelper = js.context['voiceHelper'];
      voiceHelper?.callMethod('stopListening', []);
      _isListening = false;
    } catch (e) {
      debugPrint('Stop error: $e');
    }
  }

  bool get isListening => _isListening;
  bool get isAvailable => js.context.hasProperty('voiceHelper');

  void dispose() {
    stopListening();
  }
}
