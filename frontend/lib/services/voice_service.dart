// Conditional import: use Web version on Web, Mobile version on native platforms
import 'voice_service_stub.dart'
    if (dart.library.html) 'voice_service_web.dart'
    if (dart.library.io) 'voice_service_mobile.dart';

export 'voice_service_stub.dart'
    if (dart.library.html) 'voice_service_web.dart'
    if (dart.library.io) 'voice_service_mobile.dart';

/// Cross-platform voice service that delegates to platform-specific implementations
class VoiceService {
  final VoiceServiceImpl _impl = VoiceServiceImpl();

  Future<bool> initialize() => _impl.initialize();

  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onStateChange,
    Function(String)? onError,
  }) =>
      _impl.startListening(
        onResult: onResult,
        onStateChange: onStateChange,
        onError: onError,
      );

  Future<void> stopListening() => _impl.stopListening();

  bool get isListening => _impl.isListening;
  bool get isAvailable => _impl.isAvailable;

  void dispose() => _impl.dispose();
}
