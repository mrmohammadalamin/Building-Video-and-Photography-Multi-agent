import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../models/photography_types.dart';
import '../../widgets/proactive_feedback_overlay.dart';

class PhotographerMode extends StatefulWidget {
  final CameraController? controller;
  final bool isReady;
  final int compositionScore;
  final String lightingQuality;
  final String aiSuggestion;
  final bool isReadyToShoot;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final PhotographyType selectedType;
  final Function(PhotographyType) onTypeChanged;
  final bool isProcessing;

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

  const PhotographerMode({
    super.key,
    required this.controller,
    required this.isReady,
    required this.compositionScore,
    required this.lightingQuality,
    required this.aiSuggestion,
    required this.isReadyToShoot,
    required this.onCapture,
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
    this.isProcessing = false,
  });

  @override
  State<PhotographerMode> createState() => _PhotographerModeState();
}

class _PhotographerModeState extends State<PhotographerMode> {
  bool _isToolboxOpen = true;
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Camera Preview (Main Background)
        if (widget.isReady && widget.controller != null)
          Positioned.fill(
            child: CameraPreview(widget.controller!),
          )
        else
          Container(
            color: Colors.black,
            child: const Center(child: CircularProgressIndicator()),
          ),

        // 2. AI Guidance Overlay (Top Area)
        if (widget.compositionScore > 0)
          Positioned(
            top: 100,
            left: _isToolboxOpen ? 296 : 16, // Shift when toolbox is open
            right: 16,
            child: ProactiveFeedbackOverlay(
              compositionScore: widget.compositionScore,
              lighting: widget.lightingQuality,
              suggestion: widget.aiSuggestion,
              isReadyToShoot: widget.isReadyToShoot,
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
              _isToolboxOpen
                  ? Icons.chevron_left
                  : Icons.settings_input_component,
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

        // 5. Sidebar Controls (Right Side - Zoom)
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
                    activeColor: Colors.deepPurpleAccent,
                    inactiveColor: Colors.white24,
                  ),
                ),
              ),
              const Icon(Icons.zoom_out, color: Colors.white70, size: 20),
            ],
          ),
        ),

        // 6. Center Bottom Shutter
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 48), // Balancing spacer
                GestureDetector(
                  onTap: widget.isProcessing ? null : widget.onCapture,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white24,
                    ),
                    child: Center(
                      child: Container(
                        height: 64,
                        width: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: widget.isProcessing
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                    color: Colors.deepPurple, strokeWidth: 3),
                              )
                            : const Icon(Icons.camera_alt,
                                color: Colors.black, size: 32),
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
                  Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
                  SizedBox(width: 12),
                  Text(
                    "AI TOOLBOX",
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
                  _buildSectionHeader("PHOTOGRAPHY STYLE"),
                  const SizedBox(height: 12),
                  _buildStyleGrid(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("AI EFFECTS"),
                  const SizedBox(height: 12),
                  _buildEffectChips(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("CUSTOM EFFECT PROMPT"),
                  const SizedBox(height: 12),
                  _buildCustomPromptField(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("CAMERA SETTINGS"),
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
      children: PhotographyType.values.map((type) {
        final isSelected = widget.selectedType == type;
        return InkWell(
          onTap: () => widget.onTypeChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurpleAccent : Colors.white10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.deepPurpleAccent.withOpacity(0.4)
                    : Colors.white24,
              ),
            ),
            child: Text(
              type.label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
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
      "steam": "AI Steam",
      "fresh": "Fresh Food",
      "glow": "Cinematic",
      "product": "Pro Detail",
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
          selectedColor: Colors.deepPurpleAccent.withOpacity(0.6),
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
            hintText: "Describe your custom effect...",
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
            icon: const Icon(Icons.flash_on, size: 16),
            label: const Text("GENERATE EFFECT"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
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
          title: const Text("Torch/Flash",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          secondary: Icon(Icons.flash_on,
              color: widget.isTorchOn ? Colors.amber : Colors.white38),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: widget.isAiAssistEnabled,
          onChanged: widget.onToggleAiAssist,
          title: const Text("AI Auto-Assist",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          secondary: Icon(Icons.auto_awesome,
              color: widget.isAiAssistEnabled
                  ? Colors.deepPurpleAccent
                  : Colors.white38),
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
