import 'package:camera/camera.dart';
import 'dart:typed_data';

/// Represents a message in the chat conversation
class ChatMessage {
  final String text;
  final bool isUser; // true if from user, false if from AI
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Represents a captured or generated image
class CapturedImage {
  final String imagePath; // Local path or URL
  final DateTime timestamp;
  final String? caption; // Optional description
  final ImageType type;
  final Uint8List? bytes; // Raw bytes for robust Web display

  CapturedImage({
    required this.imagePath,
    required this.type,
    this.caption,
    this.bytes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Type of image in the gallery
enum ImageType {
  captured,    // Photo taken by camera
  generated,   // AI-generated image
  video,       // Recorded video
}
