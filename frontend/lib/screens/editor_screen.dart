import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_models.dart';
import '../services/mode_service.dart';

class EditorScreen extends StatefulWidget {
  final CapturedImage image;

  const EditorScreen({super.key, required this.image});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  // Filter state
  double _contrast = 1.0;
  double _brightness = 0.0;
  double _saturation = 1.0;
  ColorFilter? _activeFilter;
  String _activeFilterName = "Normal";

  final Map<String, ColorFilter> _filters = {
    "Normal": const ColorFilter.mode(Colors.transparent, BlendMode.dst),
    "Grayscale": const ColorFilter.matrix([
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    "Sepia": const ColorFilter.matrix([
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    "Invert": const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ]),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Editing Studio", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.greenAccent),
            onPressed: () {
              // Save changes (mock)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Image saved to gallery!")),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview
          Expanded(
            child: Center(
              child: ColorFiltered(
                colorFilter: _activeFilter ?? _filters["Normal"]!,
                child: _buildImage(),
              ),
            ),
          ),

          // Sliders
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black87,
            child: Column(
              children: [
                _buildSlider("Brightness", _brightness, -1.0, 1.0, (val) => setState(() => _brightness = val)),
                _buildSlider("Contrast", _contrast, 0.0, 3.0, (val) => setState(() => _contrast = val)),
                _buildSlider("Saturation", _saturation, 0.0, 3.0, (val) => setState(() => _saturation = val)),
              ],
            ),
          ),

          // Filter Selector
          Container(
            height: 100,
            color: Colors.grey[900],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final name = _filters.keys.elementAt(index);
                final filter = _filters.values.elementAt(index);
                final isSelected = name == _activeFilterName;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeFilter = filter;
                      _activeFilterName = name;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: isSelected ? Border.all(color: Colors.blueAccent, width: 2) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(name, style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: Colors.deepPurpleAccent,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (widget.image.bytes != null) {
      return Image.memory(widget.image.bytes!, fit: BoxFit.contain);
    } else {
      return Image.network(widget.image.imagePath, fit: BoxFit.contain);
    }
  }
}
