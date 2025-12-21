import 'package:flutter/material.dart';

/// Proactive feedback overlay for real-time photography guidance
class ProactiveFeedbackOverlay extends StatelessWidget {
  final int compositionScore;
  final String lighting;
  final String suggestion;
  final bool isReadyToShoot;

  const ProactiveFeedbackOverlay({
    super.key,
    required this.compositionScore,
    required this.lighting,
    required this.suggestion,
    required this.isReadyToShoot,
  });

  @override
  Widget build(BuildContext context) {
    // Color based on score
    final scoreColor = _getScoreColor();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scoreColor.withAlpha(128),
          width: 2,
        ),
      ),
      constraints: const BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score indicator
          Row(
            children: [
              Icon(
                isReadyToShoot ? Icons.check_circle : Icons.info_outline,
                color: scoreColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Score: $compositionScore/10',
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: compositionScore / 10,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          
          // Lighting
          Text(
            '💡 $lighting Light',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          
          // Suggestion
          Text(
            suggestion,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor() {
    if (compositionScore >= 8) return Colors.green;
    if (compositionScore >= 6) return Colors.orange;
    return Colors.red;
  }
}
