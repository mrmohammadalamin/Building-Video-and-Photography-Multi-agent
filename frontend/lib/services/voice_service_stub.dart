/// Stub implementation (should never be used, just for conditional import)
class VoiceServiceImpl {
  Future<bool> initialize() async => false;

  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onStateChange,
    Function(String)? onError,
  }) async {
    onError?.call('Platform not supported');
  }

  Future<void> stopListening() async {}

  bool get isListening => false;
  bool get isAvailable => false;

  void dispose() {}
}
