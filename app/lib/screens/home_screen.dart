import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'category_screen.dart';

const _kCategories = [
  _Category(
    'Breakfast', 'breakfast',
    'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=600&q=80',
    [Color(0xFFFF9A3C), Color(0xFFFF6B35)],
  ),
  _Category(
    'Lunch', 'lunch',
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
    [Color(0xFF56AB2F), Color(0xFF2E7D32)],
  ),
  _Category(
    'Dinner', 'dinner',
    'https://images.unsplash.com/photo-1559847844-5315695dadae?w=600&q=80',
    [Color(0xFF3D6B4F), Color(0xFF1A3024)],
  ),
  _Category(
    'Snack', 'snack',
    'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?w=600&q=80',
    [Color(0xFFC8933A), Color(0xFF8B5E1A)],
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final recipes = await RecipeService.fetchRecipes();
      if (mounted) setState(() { _recipes = recipes; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _totalXp => _recipes.where((r) => !r.isLocked).fold(0, (s, r) => s + r.xpReward);
  int get _level => (_totalXp / 200).floor() + 1;
  double get _levelProgress => (_totalXp % 200) / 200;

  List<Recipe> _forCategory(String cat) =>
      _recipes.where((r) => r.category == cat).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildCategories(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.dark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chefs Quest', style: AppTextStyles.heading(22)),
              _LevelXpWidget(
                xp: _totalXp,
                level: _level,
                progress: _levelProgress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    const padding = 10.0;
    const outerPadding = 12.0;
    final totalPadding = outerPadding * 2 + padding * (_kCategories.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemHeight = (constraints.maxHeight - totalPadding) / _kCategories.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: outerPadding, vertical: outerPadding),
          child: Column(
            children: _kCategories.indexed.map((entry) {
              final i = entry.$1;
              final cat = entry.$2;
              return Padding(
                padding: EdgeInsets.only(bottom: i < _kCategories.length - 1 ? padding : 0),
                child: SizedBox(
                  height: itemHeight,
                  width: double.infinity,
                  child: _CategoryCard(
                    category: cat,
                    recipeCount: _forCategory(cat.key).length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(
                          category: CategoryInfo(cat.name, '', cat.key),
                          recipes: _forCategory(cat.key),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _LevelXpWidget extends StatelessWidget {
  final int xp;
  final int level;
  final double progress;
  const _LevelXpWidget({required this.xp, required this.level, required this.progress});

  static const double _circleSize = 52.0;
  static const double _barHeight = 22.0;
  static const double _barWidth = 110.0;
  static const double _overlap = 14.0;

  int get _currentLevelXp => xp % 200;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _circleSize,
      width: _circleSize + _barWidth - _overlap,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // XP bar (sits behind circle on the left, extends right)
          Positioned(
            left: _circleSize / 2,
            child: Container(
              width: _barWidth,
              height: _barHeight,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(99)),
                border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(99)),
                    child: Stack(
                      children: [
                        Container(width: constraints.maxWidth * progress,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.gold, Color(0xFFE6A020)],
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '$_currentLevelXp/200 XP',
                            style: AppTextStyles.label(10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Circle (on top, left side)
          Container(
            width: _circleSize,
            height: _circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dark,
              border: Border.all(color: AppColors.gold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Level', style: AppTextStyles.body(8, color: AppColors.gold)),
                Text('$level', style: AppTextStyles.label(16, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _Category category;
  final int recipeCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.recipeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with gradient fallback
            Image.network(
              category.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: category.fallbackColors,
                  ),
                ),
              ),
            ),
            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
            // Label
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: AppTextStyles.heading(20),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$recipeCount recipes',
                    style: AppTextStyles.body(12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String name;
  final String key;
  final String imageUrl;
  final List<Color> fallbackColors;
  const _Category(this.name, this.key, this.imageUrl, this.fallbackColors);
}
