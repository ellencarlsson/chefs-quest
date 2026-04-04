import 'dart:math' as math;
import 'package:flutter/material.dart';

class AmbientWindow extends StatelessWidget {
  final Color skyColor;
  final double t;
  final Size size;

  const AmbientWindow({
    super.key,
    required this.skyColor,
    required this.t,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final top = size.height * 0.12;
    return Positioned(
      top: top,
      left: size.width * 0.5 - 65,
      child: SizedBox(
        width: 130,
        height: 100,
        child: Stack(
          children: [
            _windowFrame(),
            _sky(),
            _sun(),
            _curtainLeft(t),
            _curtainRight(t),
            _steam(t),
            _crossbars(),
          ],
        ),
      ),
    );
  }

  Widget _windowFrame() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8B6340), width: 5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
      ),
    );
  }

  Widget _sky() {
    return Positioned(
      left: 5, right: 5, top: 5, bottom: 5,
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [skyColor, skyColor.withOpacity(0.6)],
          ),
        ),
      ),
    );
  }

  Widget _sun() {
    // Sun moves horizontally based on hour
    final hour = DateTime.now().hour;
    final progress = ((hour - 6) / 12).clamp(0.0, 1.0);
    final left = 10.0 + progress * 80.0;
    final top = 15.0 - math.sin(progress * math.pi) * 10;
    return Positioned(
      left: left, top: top,
      child: Container(
        width: 18, height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hour >= 17 ? const Color(0xFFFF7040) : const Color(0xFFFFD700),
          boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 8)],
        ),
      ),
    );
  }

  Widget _curtainLeft(double t) {
    final sway = math.sin(t * 0.4) * 5.0;
    return Positioned(
      left: 5, top: 5, bottom: 5,
      child: Transform(
        alignment: Alignment.topLeft,
        transform: Matrix4.rotationZ(sway * math.pi / 180),
        child: Container(
          width: 22,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5E6C8), Color(0xFFE8D4A8)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _curtainRight(double t) {
    final sway = math.sin(t * 0.4 + math.pi) * 5.0;
    return Positioned(
      right: 5, top: 5, bottom: 5,
      child: Transform(
        alignment: Alignment.topRight,
        transform: Matrix4.rotationZ(-sway * math.pi / 180),
        child: Container(
          width: 22,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8D4A8), Color(0xFFF5E6C8)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _steam(double t) {
    final x = math.sin(t * 0.7) * 6;
    final opacity = (0.4 + math.sin(t) * 0.2).clamp(0.0, 1.0);
    return Positioned(
      bottom: -28, left: 55 + x,
      child: Opacity(
        opacity: opacity,
        child: Column(
          children: List.generate(4, (i) {
            final dx = math.sin(t * 0.5 + i * 0.8) * 3;
            return Transform.translate(
              offset: Offset(dx, 0),
              child: Container(
                width: 2, height: 8,
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5 - i * 0.1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _crossbars() {
    return Positioned(
      left: 5, right: 5, top: 5, bottom: 5,
      child: Column(
        children: [
          const Spacer(),
          Container(height: 3, color: const Color(0xFF8B6340)),
          const Spacer(),
        ],
      ),
    );
  }
}
