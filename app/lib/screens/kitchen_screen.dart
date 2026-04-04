import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/kitchen_shelf.dart';
import '../widgets/kitchen_counter.dart';
import '../widgets/ambient_window.dart';
import 'menu_screen.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambient;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadRecipes();
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await RecipeService.fetchRecipes();
      if (mounted) setState(() => _recipes = recipes);
    } catch (_) {}
  }

  int get _hour => DateTime.now().hour;

  Color get _wallColor {
    if (_hour >= 6 && _hour < 10) return const Color(0xFFFFF0D0);
    if (_hour >= 10 && _hour < 17) return const Color(0xFFFFF8EC);
    if (_hour >= 17 && _hour < 21) return const Color(0xFFFFE0B0);
    return const Color(0xFF2A1E40);
  }

  Color get _skyColor {
    if (_hour >= 6 && _hour < 10) return const Color(0xFFFFB347);
    if (_hour >= 10 && _hour < 17) return const Color(0xFF87CEEB);
    if (_hour >= 17 && _hour < 21) return const Color(0xFFFF7040);
    return const Color(0xFF0D0820);
  }

  int get _unlockedCount => _recipes.where((r) => !r.isLocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ambient,
        builder: (context, _) {
          final t = _ambient.value * 2 * math.pi;
          return _buildScene(context, t);
        },
      ),
    );
  }

  Widget _buildScene(BuildContext context, double t) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        _buildWall(size),
        AmbientWindow(skyColor: _skyColor, t: t, size: size),
        _buildRestaurantName(size),
        KitchenShelf(unlocked: _unlockedCount, size: size),
        KitchenCounter(unlocked: _unlockedCount, t: t, size: size),
        _buildMenuButton(context, size),
      ],
    );
  }

  Widget _buildWall(Size size) {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _wallColor,
              _wallColor.withOpacity(0.85),
              const Color(0xFFD4B898),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantName(Size size) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2C1A0E).withOpacity(0.85),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: const Color(0xFFC4914A).withOpacity(0.4)),
            ),
            child: const Text(
              '✦  Ellens Bistro  ✦',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFF5C842),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, Size size) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuScreen(recipes: _recipes)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFC4914A), Color(0xFFD4A85A)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC4914A).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📋', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                'Visa min meny',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C0E04),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
