import 'package:flutter/foundation.dart';
import '../models/app_mode.dart';

class ModeService extends ChangeNotifier {
  AppMode _currentMode = AppMode.photographer;

  AppMode get currentMode => _currentMode;

  bool get isPhotographer => _currentMode == AppMode.photographer;
  bool get isVideographer => _currentMode == AppMode.videographer;

  void setMode(AppMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
      debugPrint('App Mode switched to: ${mode.label}');
    }
  }

  void toggleMode() {
    setMode(_currentMode == AppMode.photographer 
        ? AppMode.videographer 
        : AppMode.photographer);
  }
}
