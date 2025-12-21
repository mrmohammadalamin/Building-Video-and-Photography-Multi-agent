import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../models/videography_types.dart';

class VideographerMode extends StatefulWidget {
  final CameraController? controller;
  final bool isReady;
  final bool isRecording;
  final Duration recordingDuration;
  final VoidCallback onToggleRecording;
  final VoidCallback onSwitchCamera;
  final VideographyType selectedType;
  final Function(VideographyType) onTypeChanged;

  // Camera Controls
  final double currentZoom;
  final double maxZoom;
  final double minZoom;
  final Function(double) onZoomChanged;
  final double currentExposure;
  final Function(double) onExposureChanged;
  final bool isTorchOn;
  final Function(bool) onToggleTorch;
  final bool isAiAssistEnabled;
  final Function(bool) onToggleAiAssist;
  final String? selectedEffect;
  final Function(String?) onEffectChanged;

  const VideographerMode({
    super.key,
    required this.controller,
    required this.isReady,
    required this.isRecording,
    required this.recordingDuration,
    required this.onToggleRecording,
    required this.onSwitchCamera,
    required this.selectedType,
    required this.onTypeChanged,
    required this.currentZoom,
    required this.maxZoom,
    required this.minZoom,
    required this.onZoomChanged,
    required this.currentExposure,
    required this.onExposureChanged,
    required this.isTorchOn,
    required this.onToggleTorch,
    required this.isAiAssistEnabled,
    required this.onToggleAiAssist,
    required this.onEffectChanged,
    this.selectedEffect,
  });

  @override
  State<VideographerMode> createState() => _VideographerModeState();
}

class _VideographerModeState extends State<VideographerMode> {
  bool _isToolboxOpen = true;
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Camera Preview
        if (widget.isReady && widget.controller != null)
          Positioned.fill(
            child: CameraPreview(widget.controller!),
          )
        else
          Container(
            color: Colors.black,
            child: const Center(child: CircularProgressIndicator()),
          ),

        // 2. Cinematic Grid
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
        ),

        // 3. Side Toolbox Panel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: _isToolboxOpen ? 0 : -280,
          top: 0,
          bottom: 0,
          child: _buildToolbox(),
        ),

        // 4. Toolbox Toggle Button
        Positioned(
          left: _isToolboxOpen ? 280 : 10,
          top: 80,
          child: IconButton(
            icon: Icon(
              _isToolboxOpen ? Icons.chevron_left : Icons.video_settings,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => setState(() => _isToolboxOpen = !_isToolboxOpen),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ),

        // 5. Info Bar (Top)
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 8, left: _isToolboxOpen ? 296 : 80),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle,
                      color: widget.isRecording ? Colors.red : Colors.grey,
                      size: 12),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(widget.recordingDuration),
                    style: TextStyle(
                      fontFamily: 'Courier',
                      color: widget.isRecording ? Colors.red : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text("4K 24FPS",
                      style: TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),

        // 6. Sidebar Controls (Right Side - Zoom)
        Positioned(
          right: 16,
          top: 150,
          bottom: 250,
          child: Column(
            children: [
              const Icon(Icons.zoom_in, color: Colors.white70, size: 20),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: widget.currentZoom,
                    min: widget.minZoom,
                    max: widget.maxZoom,
                    onChanged: widget.onZoomChanged,
                    activeColor: Colors.redAccent,
                    inactiveColor: Colors.white24,
                  ),
                ),
              ),
              const Icon(Icons.zoom_out, color: Colors.white70, size: 20),
            ],
          ),
        ),

        // 7. Bottom Record Control
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 48),
                GestureDetector(
                  onTap: widget.onToggleRecording,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white24,
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: widget.isRecording ? 32 : 64,
                        width: widget.isRecording ? 32 : 64,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: widget.isRecording
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                          borderRadius: widget.isRecording
                              ? BorderRadius.circular(8)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onSwitchCamera,
                  icon: const Icon(Icons.cameraswitch,
                      color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbox() {
    return Container(
      width: 280,
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: const [
                  Icon(Icons.video_library, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Text(
                    "VEO TOOLBOX",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader("CINEMATOGRAPHY STYLE"),
                  const SizedBox(height: 12),
                  _buildStyleGrid(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("AI OVERLAYS"),
                  const SizedBox(height: 12),
                  _buildEffectChips(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("CUSTOM VIDEO FX PROMPT"),
                  const SizedBox(height: 12),
                  _buildCustomPromptField(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("PRODUCTION SETTINGS"),
                  const SizedBox(height: 12),
                  _buildQuickSettings(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildStyleGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VideographyType.values.map((type) {
        final isSelected = widget.selectedType == type;
        return InkWell(
          onTap: () => widget.onTypeChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.redAccent : Colors.white10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.red : Colors.white24,
              ),
            ),
            child: Text(
              type.label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEffectChips() {
    final effects = {
      null: "None",
      "steam_loop": "AI Steam",
      "particle_slowmo": "Cinematic",
      "lighting_transition": "Dynamic",
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: effects.entries.map((e) {
        final isSelected = widget.selectedEffect == e.key;
        return ChoiceChip(
          label: Text(e.value, style: const TextStyle(fontSize: 11)),
          selected: isSelected,
          onSelected: (val) => widget.onEffectChanged(val ? e.key : null),
          selectedColor: Colors.redAccent.withOpacity(0.6),
          backgroundColor: Colors.white10,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomPromptField() {
    return Column(
      children: [
        TextField(
          controller: _promptController,
          maxLines: 2,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: "Describe custom video effect...",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_promptController.text.isNotEmpty) {
                widget.onEffectChanged(_promptController.text);
              }
            },
            icon: const Icon(Icons.movie_creation_outlined, size: 16),
            label: const Text("GENERATE FX"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSettings() {
    return Column(
      children: [
        SwitchListTile(
          value: widget.isTorchOn,
          onChanged: widget.onToggleTorch,
          title: const Text("Lighting/Torch",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          secondary: Icon(Icons.lightbulb_outline,
              color: widget.isTorchOn ? Colors.amber : Colors.white38),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: widget.isAiAssistEnabled,
          onChanged: widget.onToggleAiAssist,
          title: const Text("AI Auto-Assist",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          secondary: Icon(Icons.auto_awesome,
              color:
                  widget.isAiAssistEnabled ? Colors.redAccent : Colors.white38),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.exposure, color: Colors.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                value: widget.currentExposure,
                min: -2.0,
                max: 2.0,
                onChanged: widget.onExposureChanged,
                activeColor: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..strokeWidth = 1;

    canvas.drawLine(
        Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, 2 * size.height / 3),
        Offset(size.width, 2 * size.height / 3), paint);
    canvas.drawLine(
        Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(2 * size.width / 3, 0),
        Offset(2 * size.width / 3, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
