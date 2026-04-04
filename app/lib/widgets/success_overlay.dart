import 'package:flutter/material.dart';
import '../app_theme.dart';

class SuccessOverlay extends StatefulWidget {
  final String emoji;
  final String title;
  final int xp;
  final VoidCallback onDismiss;

  const SuccessOverlay({
    super.key,
    required this.emoji,
    required this.title,
    required this.xp,
    required this.onDismiss,
  });

  static void show(
    BuildContext context, {
    required String emoji,
    required String title,
    required int xp,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (ctx, _, __) => SuccessOverlay(
          emoji: emoji,
          title: title,
          xp: xp,
          onDismiss: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), widget.onDismiss);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Scaffold(
        backgroundColor: AppColors.dark.withOpacity(0.92),
        body: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.emoji, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  Text(widget.title, style: AppTextStyles.heading(26), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '+${widget.xp} XP',
                      style: AppTextStyles.label(18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Tryck för att fortsätta',
                    style: AppTextStyles.body(13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
