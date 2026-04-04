import 'package:flutter/material.dart';

const _kCategories = [
  _Category('Frukost', '🍳', Color(0xFFF5A623), Color(0xFFE8820A)),
  _Category('Lunch', '🥗', Color(0xFF4CAF50), Color(0xFF2E7D32)),
  _Category('Middag', '🍽️', Color(0xFFC4514A), Color(0xFF8B2420)),
  _Category('Bakverk', '🎂', Color(0xFF9575CD), Color(0xFF5E35B1)),
  _Category('Drycker', '🍷', Color(0xFF5C6BC0), Color(0xFF283593)),
];

class KitchenShelf extends StatelessWidget {
  final int unlocked;
  final Size size;

  const KitchenShelf({super.key, required this.unlocked, required this.size});

  @override
  Widget build(BuildContext context) {
    final top = size.height * 0.34;
    return Positioned(
      top: top,
      left: 0, right: 0,
      height: 120,
      child: Stack(
        children: [
          _shelfBack(),
          _books(),
          _shelfBoard(),
        ],
      ),
    );
  }

  Widget _shelfBack() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8D5B0), Color(0xFFDCC89A)],
          ),
        ),
      ),
    );
  }

  Widget _shelfBoard() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 10,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B6340), Color(0xFF6B4820)],
          ),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
      ),
    );
  }

  Widget _books() {
    return Positioned(
      bottom: 10, left: 20, right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          _kCategories.length,
          (i) => _BookSpine(
            category: _kCategories[i],
            recipeCount: _recipeCountForIndex(i),
          ),
        ),
      ),
    );
  }

  int _recipeCountForIndex(int i) {
    // Distribute unlocked recipes across categories, Middag gets most
    const weights = [0.2, 0.15, 0.35, 0.2, 0.1];
    return (unlocked * weights[i]).round();
  }
}

class _BookSpine extends StatelessWidget {
  final _Category category;
  final int recipeCount;

  const _BookSpine({required this.category, required this.recipeCount});

  bool get _locked => recipeCount == 0;
  double get _width => _locked ? 14 : (14 + recipeCount * 5.0).clamp(14, 44);
  double get _height => _locked ? 55 : (55 + recipeCount * 4.0).clamp(55, 88);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _spine(),
        const SizedBox(height: 3),
        Text(category.emoji, style: TextStyle(fontSize: _locked ? 12 : 16)),
      ],
    );
  }

  Widget _spine() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        gradient: _locked
            ? const LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)])
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [category.light, category.dark],
              ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(_locked ? 0.1 : 0.25), blurRadius: 4, offset: const Offset(2, 1)),
        ],
      ),
      child: _locked ? _lockedContent() : _unlockedContent(),
    );
  }

  Widget _lockedContent() {
    return const Center(
      child: RotatedBox(
        quarterTurns: 3,
        child: Text('· · ·', style: TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 2)),
      ),
    );
  }

  Widget _unlockedContent() {
    return Center(
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          category.name.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _Category {
  final String name;
  final String emoji;
  final Color light;
  final Color dark;

  const _Category(this.name, this.emoji, this.light, this.dark);
}
