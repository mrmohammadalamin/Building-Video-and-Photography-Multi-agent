enum AppMode {
  photographer,
  videographer,
}

extension AppModeExtension on AppMode {
  String get label {
    switch (this) {
      case AppMode.photographer:
        return 'Photographer';
      case AppMode.videographer:
        return 'Videographer';
    }
  }

  String get iconAsset {
    switch (this) {
      case AppMode.photographer:
        return 'assets/icons/camera.png'; // Placeholder
      case AppMode.videographer:
        return 'assets/icons/video.png'; // Placeholder
    }
  }
}
