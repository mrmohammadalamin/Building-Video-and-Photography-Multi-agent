import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'models/chat_models.dart';
import 'services/mode_service.dart';
import 'services/voice_service.dart';
import 'services/tts_service.dart';
import 'models/app_mode.dart';
import 'models/photography_types.dart';
import 'screens/editor_screen.dart';
import 'screens/video_player_screen.dart';
import 'screens/modes/photographer_mode.dart';
import 'screens/modes/videographer_mode.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'models/videography_types.dart';

enum CameraStatus {
  initializing,
  ready,
  noPermissions,
  noCameras,
  error,
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraStatus _cameraStatus = CameraStatus.initializing;
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  // Phase 2 State
  int _compositionScore = 0;
  String _lightingQuality = "Unknown";
  String _aiSuggestion = "Analyzing scene...";
  bool _isReadyToShoot = false;
  Timer? _sceneAnalysisTimer;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _showProactiveGuidance = true;

  // Gallery State
  final List<CapturedImage> _imageGallery = [];
  bool _isRecording = false;
  XFile? _recordedVideo;

  // Chat History
  final List<ChatMessage> _chatHistory = [];

  // Voice & TTS Services
  final VoiceService _voiceService = VoiceService();
  final TtsService _ttsService = TtsService();
  bool _isListening = false;
  bool _isVoiceGuidanceEnabled = true;
  PhotographyType _selectedPhotographyType = PhotographyType.general;
  VideographyType _selectedVideographyType = VideographyType.cinematic;

  bool _isProcessingCapture = false;

  // Technical Camera State
  double _currentZoom = 1.0;
  double _maxZoom = 1.0;
  double _minZoom = 1.0;
  double _currentExposure = 0.0;
  bool _isTorchOn = false;
  bool _isAiAssistEnabled = true;
  String? _selectedEffect;
  String? _effectOverlayUrl;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeVoice();

    // Start analysis after a short delay to ensure camera is ready
    Future.delayed(const Duration(seconds: 3), _startSceneAnalysis);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _sceneAnalysisTimer?.cancel();
    _recordingTimer?.cancel();
    _voiceService.dispose();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      try {
        _cameras = await availableCameras();
        if (_cameras.isEmpty) {
          setState(() => _cameraStatus = CameraStatus.noCameras);
          return;
        }
        await _initializeCameraController(_cameras[0]);
      } catch (e) {
        debugPrint("Camera initialization error: $e");
        setState(() => _cameraStatus = CameraStatus.error);
      }
    } else {
      // Mobile permission logic
      var status = await Permission.camera.status;
      if (status.isDenied) status = await Permission.camera.request();
      if (await Permission.microphone.isDenied)
        await Permission.microphone.request();

      if (status.isGranted) {
        try {
          _cameras = await availableCameras();
          if (_cameras.isEmpty) {
            setState(() => _cameraStatus = CameraStatus.noCameras);
          } else {
            await _initializeCameraController(_cameras[0]);
          }
        } catch (e) {
          setState(() => _cameraStatus = CameraStatus.error);
        }
      } else {
        setState(() => _cameraStatus = CameraStatus.noPermissions);
      }
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (mounted) {
        _maxZoom = await controller.getMaxZoomLevel();
        _minZoom = await controller.getMinZoomLevel();
        setState(() => _cameraStatus = CameraStatus.ready);
      }
    } on CameraException catch (e) {
      debugPrint("Camera error: $e");
      if (mounted) {
        setState(() => _cameraStatus = CameraStatus.error);
      }
    }
  }

  Future<void> _initializeVoice() async {
    await _ttsService.initialize();
    await _voiceService.initialize();
  }

  void _startListening() {
    _ttsService.speak("");

    _voiceService.startListening(
      onResult: (text) {
        if (mounted) {
          _handleVoiceCommand(text);
        }
      },
      onStateChange: (isListening) {
        if (mounted) {
          setState(() => _isListening = isListening);
          if (isListening) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Listening..."),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.blueAccent,
            ));
          }
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red));
        }
      },
    );
  }

  void _toggleListening() {
    if (_isListening) {
      _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      _ttsService.speak(" ");
      _startListening();
    }
  }

  void _handleVoiceCommand(String command) {
    debugPrint('Voice command: $command');

    setState(() {
      _chatHistory.add(ChatMessage(
        text: command,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    final lowerCommand = command.toLowerCase();
    String response = "I didn't understand that.";

    final modeService = Provider.of<ModeService>(context, listen: false);

    // Context-Aware Commands
    if (modeService.isPhotographer) {
      // Photographer Mode Commands
      if (lowerCommand.contains('capture') ||
          lowerCommand.contains('take') ||
          lowerCommand.contains('photo')) {
        response = "Taking photo";
        _takePicture();
      } else if (lowerCommand.contains('switch') ||
          lowerCommand.contains('flip')) {
        response = "Switching lens";
        _switchCamera();
      }
    } else {
      // Videographer Mode Commands
      if (lowerCommand.contains('record') ||
          lowerCommand.contains('start') ||
          lowerCommand.contains('action')) {
        if (!_isRecording) {
          response = "Rolling action";
          _toggleVideoRecording();
        } else {
          response = "Already recording";
        }
      } else if (lowerCommand.contains('stop') ||
          lowerCommand.contains('cut')) {
        if (_isRecording) {
          response = "Cut! Great take.";
          _toggleVideoRecording();
        } else {
          response = "Not recording.";
        }
      }
    }

    // Common Commands
    if (lowerCommand.contains('video mode')) {
      modeService.setMode(AppMode.videographer);
      response = "Switching to video mode";
    } else if (lowerCommand.contains('photo mode')) {
      modeService.setMode(AppMode.photographer);
      response = "Switching to photographer mode";
    }

    _ttsService.speak(response);
  }

  void _startSceneAnalysis() {
    // Analyze every 3 seconds for both modes
    _sceneAnalysisTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final modeService = Provider.of<ModeService>(context, listen: false);
      if (mounted &&
          _cameraStatus == CameraStatus.ready &&
          _controller != null &&
          _controller!.value.isInitialized &&
          !_isProcessingCapture) {
        // CRITICAL: On Web/iOS Safari, calling takePicture during video recording
        // often breaks the stream/preview. We skip analysis during active recording
        // unless we are in Photographer mode.
        if (modeService.isVideographer && _isRecording) {
          return;
        }

        // Run analysis
        _captureAndAnalyzeFrame(modeService);
      }
    });
  }

  // ...

  void _onEffectChanged(String? effect) {
    setState(() {
      _selectedEffect = effect;
      if (effect == null) {
        _effectOverlayUrl = null;
      }
    });

    if (effect != null) {
      _ttsService.speak("Applying $effect effect.");
      _triggerEffectProcessing(effect);
    }
  }

  Future<void> _triggerEffectProcessing(String effect) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();

      final modeService = Provider.of<ModeService>(context, listen: false);
      final endpoint =
          modeService.isPhotographer ? "/apply_effect" : "/video_effect";

      var request = http.MultipartRequest(
          'POST', Uri.parse("${Config.baseUrl}$endpoint"));
      request.fields['effect_type'] = effect;

      // If it's not one of our predefined keys, treat it as a custom prompt
      request.fields['custom_prompt'] = effect;

      if (modeService.isPhotographer) {
        request.files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: 'frame.jpg'));
      } else {
        request.fields['context'] = _selectedVideographyType.label;
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var resBody = await response.stream.bytesToString();
        var data = json.decode(resBody);

        String relativeUrl =
            data['overlay_url'] ?? data['veo_overlay_stream'] ?? "";

        setState(() {
          if (relativeUrl.isNotEmpty) {
            _effectOverlayUrl = relativeUrl.startsWith('/')
                ? "${Config.baseUrl}$relativeUrl"
                : relativeUrl;
          } else {
            _effectOverlayUrl = null;
          }
        });

        _ttsService.speak("AI effect transformed successfully.");
      } else {
        _ttsService.speak("AI transformation failed. Status code ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error processing effect: $e");
      String errorMsg = "Connectivity issue. Please visit ${Config.baseUrl} in a new tab to trust the certificate.";
      _ttsService.speak("Network error. Please check your connection to the AI engine.");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'FIX NOW',
            onPressed: () {
              // We can't easily open a window from here in some contexts, but we can give instructions
            },
          ),
        ),
      );
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    final lensDirection = _controller!.description.lensDirection;
    CameraDescription newCamera;

    if (lensDirection == CameraLensDirection.front) {
      newCamera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras[0]);
    } else {
      newCamera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras[0]);
    }

    await _initializeCameraController(newCamera);
  }

  Future<void> _captureAndAnalyzeFrame([ModeService? modeService]) async {
    try {
      if (_controller == null ||
          !_controller!.value.isInitialized ||
          _controller!.value.isTakingPicture)
        return; // takingPicture check might block video recording? verifying...

      // If recording video, 'takePicture' might stop recording on some devices or throw error.
      // However, 'takePicture' on web/mobile during recording is tricky.
      // For this prototype, we pause 'takePicture' if 'isRecordingVideo' is true,
      // OR we accept that we might not get analysis WHILE recording.
      // User request implies "instruction... based on selections", which implies PRE-recording or DURING.
      // On many mobile devices, taking a picture while recording video is possible but `takePicture` might not work.
      // We will try. If it fails, catch error.

      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();

      modeService ??= Provider.of<ModeService>(context, listen: false);
      String currentContext = "";

      if (modeService!.isPhotographer) {
        currentContext =
            "Photography: ${_selectedPhotographyType.promptContext}";
      } else {
        currentContext =
            "Videography: ${_selectedVideographyType.promptContext}";
      }

      final uri = Uri.parse(Config.analyzeSceneUrl);
      var request = http.MultipartRequest('POST', uri);
      request.fields['context'] = currentContext;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'frame.jpg',
      ));

      final response = await request.send();
      if (response.statusCode == 200) {
        final jsonBody = await response.stream.bytesToString();
        final data = json.decode(jsonBody);

        if (mounted) {
          final newSuggestion = data['suggestion'] ?? "No suggestion";

          if (_isVoiceGuidanceEnabled &&
              newSuggestion != "No suggestion" &&
              newSuggestion != _aiSuggestion) {
            _ttsService.speak(newSuggestion);
          }

          setState(() {
            _compositionScore = data['composition_score'] ?? 0;
            _lightingQuality = data['lighting'] ?? "Unknown";
            _aiSuggestion = newSuggestion;
            _isReadyToShoot = data['is_ready_to_shoot'] ?? false;
          });

          // Apply AI Technical Adjustments if enabled
          if (_isAiAssistEnabled && data['technical_adjustments'] != null) {
            final adj = data['technical_adjustments'];
            if (adj['zoom_level'] != null) {
              _setZoom(adj['zoom_level'].toDouble());
            }
            if (adj['exposure_offset'] != null) {
              _setExposure(adj['exposure_offset'].toDouble());
            }
            if (adj['torch_on'] != null) {
              _toggleTorch(adj['torch_on']);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Scene analysis error: $e");
    }
  }

  Future<void> _setZoom(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      // Clamp to supported range
      double finalZoom = zoom.clamp(_minZoom, _maxZoom);
      await _controller!.setZoomLevel(finalZoom);
      setState(() => _currentZoom = finalZoom);
    } catch (e) {
      debugPrint("Zoom error: $e");
    }
  }

  Future<void> _setExposure(double offset) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      // Exposure range is usually -2.0 to 2.0
      double finalOffset = offset.clamp(-2.0, 2.0);
      await _controller!.setExposureOffset(finalOffset);
      setState(() => _currentExposure = finalOffset);
    } catch (e) {
      debugPrint("Exposure error: $e");
    }
  }

  Future<void> _toggleTorch(bool on) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.setFlashMode(on ? FlashMode.torch : FlashMode.off);
      setState(() => _isTorchOn = on);
    } catch (e) {
      debugPrint("Torch error: $e");
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessingCapture) return;

    setState(() => _isProcessingCapture = true);

    try {
      final XFile image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();

      setState(() {
        _imageGallery.insert(
            0,
            CapturedImage(
              imagePath: image.path,
              type: ImageType.captured,
              bytes: bytes,
            ));
      });
    } catch (e) {
      debugPrint("Error taking picture: $e");
    } finally {
      if (mounted) setState(() => _isProcessingCapture = false);
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      // Stop recording
      try {
        final XFile video = await _controller!.stopVideoRecording();
        _recordingTimer?.cancel();
        setState(() {
          _isRecording = false;
          _recordedVideo = video;
          _recordingDuration = Duration.zero;
          _imageGallery.insert(
              0, CapturedImage(imagePath: video.path, type: ImageType.video));
        });
      } catch (e) {
        debugPrint("Error stopping video recording: $e");
      }
    } else {
      // Start recording
      try {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() => _recordingDuration += const Duration(seconds: 1));
          }
        });
      } catch (e) {
        debugPrint("Error starting video recording: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeService = Provider.of<ModeService>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // 1. Top Bar with Mode Switcher
          SafeArea(child: _buildTopBar(modeService)),

          // 2. Main Content Area
          Expanded(
            child: Stack(
              children: [
                modeService.isPhotographer
                    ? PhotographerMode(
                        controller: _controller,
                        isReady: _cameraStatus == CameraStatus.ready,
                        compositionScore: _compositionScore,
                        lightingQuality: _lightingQuality,
                        aiSuggestion: _aiSuggestion,
                        isReadyToShoot: _isReadyToShoot,
                        onCapture: _takePicture,
                        onSwitchCamera: _switchCamera,
                        selectedType: _selectedPhotographyType,
                        onTypeChanged: (type) {
                          setState(() => _selectedPhotographyType = type);
                          _ttsService.speak("${type.label} mode active.");
                          // Trigger re-analysis immediately with new context
                          _captureAndAnalyzeFrame();
                        },
                        isProcessing: _isProcessingCapture,
                        currentZoom: _currentZoom,
                        maxZoom: _maxZoom,
                        minZoom: _minZoom,
                        onZoomChanged: _setZoom,
                        currentExposure: _currentExposure,
                        onExposureChanged: _setExposure,
                        isTorchOn: _isTorchOn,
                        onToggleTorch: _toggleTorch,
                        isAiAssistEnabled: _isAiAssistEnabled,
                        onToggleAiAssist: (val) =>
                            setState(() => _isAiAssistEnabled = val),
                        selectedEffect: _selectedEffect,
                        onEffectChanged: _onEffectChanged,
                      )
                    : VideographerMode(
                        controller: _controller,
                        isReady: _cameraStatus == CameraStatus.ready,
                        isRecording: _isRecording,
                        recordingDuration: _recordingDuration,
                        onToggleRecording: _toggleVideoRecording,
                        onSwitchCamera: _switchCamera,
                        selectedType: _selectedVideographyType,
                        onTypeChanged: (type) {
                          setState(() => _selectedVideographyType = type);
                          _ttsService.speak("${type.label} style selected.");
                        },
                        currentZoom: _currentZoom,
                        maxZoom: _maxZoom,
                        minZoom: _minZoom,
                        onZoomChanged: _setZoom,
                        currentExposure: _currentExposure,
                        onExposureChanged: _setExposure,
                        isTorchOn: _isTorchOn,
                        onToggleTorch: _toggleTorch,
                        isAiAssistEnabled: _isAiAssistEnabled,
                        onToggleAiAssist: (val) =>
                            setState(() => _isAiAssistEnabled = val),
                        selectedEffect: _selectedEffect,
                        onEffectChanged: _onEffectChanged,
                      ),

                // 4. Real-time AI Effect Overlay
                if (_effectOverlayUrl != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.9, // More visible transformation
                        child: Image.network(
                          _effectOverlayUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 3. Bottom Controls (Minimal - just voice now, since actions are in mode widgets)
          Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildVoiceInputBar(),
                _buildGallery(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ensure _buildVoiceInputBar is simplified as controls are now in the Mode widgets
  Widget _buildVoiceInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black,
      child: GestureDetector(
        onTap: _toggleListening,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
            border: _isListening
                ? Border.all(color: Colors.deepPurpleAccent, width: 2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.deepPurpleAccent : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                _isListening ? "Listening..." : "Tap to speak to Gemini",
                style: TextStyle(
                  color: _isListening ? Colors.white : Colors.grey,
                  fontStyle: _isListening ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallery() {
    if (_imageGallery.isEmpty) {
      return Container(height: 80, color: Colors.black);
    }

    return Container(
      height: 80,
      color: Colors.black,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageGallery.length,
        itemBuilder: (context, index) {
          final item = _imageGallery[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () {
                if (item.type == ImageType.captured) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditorScreen(image: item),
                    ),
                  );
                } else if (item.type == ImageType.video) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoPlayerScreen(videoPath: item.imagePath),
                    ),
                  );
                }
              },
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.type == ImageType.video)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Icon(Icons.videocam,
                                color: Colors.white, size: 32),
                          ),
                        )
                      else if (item.bytes != null)
                        Image.memory(item.bytes!, fit: BoxFit.cover)
                      else
                        Image.network(
                          item.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _changeMode(ModeService modeService, AppMode mode) {
    if (modeService.currentMode == mode) return;
    
    _ttsService.clearQueueAndStop();
    modeService.setMode(mode);
    _ttsService.speak("${mode == AppMode.photographer ? 'Photographer' : 'Videographer'} mode active.");
  }

  Widget _buildTopBar(ModeService modeService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mode Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                _buildModeButton(
                  icon: Icons.camera_alt,
                  label: "Photo",
                  isSelected: modeService.isPhotographer,
                  onTap: () => _changeMode(modeService, AppMode.photographer),
                  activeColor: Colors.deepPurpleAccent,
                ),
                _buildModeButton(
                  icon: Icons.videocam,
                  label: "Video",
                  isSelected: modeService.isVideographer,
                  onTap: () => _changeMode(modeService, AppMode.videographer),
                  activeColor: Colors.redAccent,
                ),
              ],
            ),
          ),

          // Voice Guidance Toggle
          IconButton(
            icon: Icon(
              _isVoiceGuidanceEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isVoiceGuidanceEnabled = !_isVoiceGuidanceEnabled;
                if (!_isVoiceGuidanceEnabled) _ttsService.clearQueueAndStop();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withAlpha(50) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : Colors.white54,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
