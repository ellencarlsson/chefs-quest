import 'package:flutter/material.dart';
import '../app_theme.dart';

class LevelXpWidget extends StatelessWidget {
  final int level;
  final int currentXp;
  final int maxXp;

  const LevelXpWidget({
    super.key,
    required this.level,
    required this.currentXp,
    required this.maxXp,
  });

  double get _progress => (currentXp / maxXp).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 5,
              valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.15)),
            ),
          ),
          // Progress ring
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$level',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Text(
                'LVL',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
