import 'dart:math' as math;
import 'package:flutter/material.dart';

class KitchenCounter extends StatelessWidget {
  final int unlocked;
  final double t;
  final Size size;

  const KitchenCounter({
    super.key,
    required this.unlocked,
    required this.t,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final top = size.height * 0.56;
    return Positioned(
      top: top, left: 0, right: 0,
      bottom: 90,
      child: Stack(
        children: [
          _counterTop(),
          _counterBody(),
          _tools(),
          if (unlocked == 0) _emptyHint(),
        ],
      ),
    );
  }

  Widget _counterTop() {
    return Positioned(
      top: 0, left: 0, right: 0, height: 14,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD4C5A8), Color(0xFFBFB090)],
          ),
          border: Border(top: BorderSide(color: Color(0xFFE0D4BC), width: 2)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
        ),
      ),
    );
  }

  Widget _counterBody() {
    return Positioned(
      top: 14, left: 0, right: 0, bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC8B898), Color(0xFFB8A888)],
          ),
        ),
      ),
    );
  }

  Widget _tools() {
    return Positioned(
      top: -50, left: 20, right: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (unlocked >= 1) _Tool(emoji: '🍳', label: 'Cast Iron', bob: math.sin(t * 0.6) * 2),
          if (unlocked >= 3) ...[
            const SizedBox(width: 16),
            _HerbPot(t: t),
          ],
          if (unlocked >= 6) ...[
            const SizedBox(width: 16),
            _Tool(emoji: '🤖', label: 'KitchenAid', bob: math.sin(t * 0.4 + 1) * 2, size: 48),
          ],
          const Spacer(),
          if (unlocked >= 2) _Tool(emoji: '🫙', label: '', bob: math.sin(t * 0.5 + 2) * 2, size: 30),
          if (unlocked >= 8) ...[
            const SizedBox(width: 10),
            _Tool(emoji: '🍝', label: 'Pasta', bob: math.sin(t * 0.7) * 2, size: 34),
          ],
        ],
      ),
    );
  }

  Widget _emptyHint() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Text(
          'Laga ditt första recept\noch se köket vakna till liv.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF2C1A0E).withOpacity(0.25),
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final String emoji;
  final String label;
  final double bob;
  final double size;

  const _Tool({required this.emoji, required this.label, required this.bob, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, bob),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: size)),
          if (label.isNotEmpty)
            Text(label, style: TextStyle(fontSize: 8, color: const Color(0xFF2C1A0E).withOpacity(0.4), letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _HerbPot extends StatelessWidget {
  final double t;
  const _HerbPot({required this.t});

  @override
  Widget build(BuildContext context) {
    final sway = math.sin(t * 0.3) * 4.0;
    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.rotationZ(sway * math.pi / 180),
      child: const Text('🌿', style: TextStyle(fontSize: 38)),
    );
  }
}
