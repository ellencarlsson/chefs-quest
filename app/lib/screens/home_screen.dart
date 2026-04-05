import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../app_theme.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/level_xp_widget.dart';
import 'category_screen.dart';

final _googleSignIn = GoogleSignIn(
  clientId: '746454650697-6f2vv7n7teb3j15a8o0plt26vrn5rh7a.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);

const _kCategories = [
  _Category('Breakfast', 'breakfast', 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600&q=80', [Color(0xFFFF9A3C), Color(0xFFFF6B35)]),
  _Category('Lunch', 'lunch', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80', [Color(0xFF56AB2F), Color(0xFF2E7D32)]),
  _Category('Dinner', 'dinner', 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=600&q=80', [Color(0xFF3D6B4F), Color(0xFF1A3024)]),
  _Category('Snack', 'snack', 'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?w=600&q=80', [Color(0xFFC8933A), Color(0xFF8B5E1A)]),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _recipes = [];
  bool _loading = true;
  final _rng = Random();

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

  String get _firstName {
    final name = _googleSignIn.currentUser?.displayName;
    if (name == null || name.isEmpty) return '';
    return name.split(' ').first;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    final name = _firstName.isNotEmpty ? ', $_firstName' : '';
    if (h < 10) return 'Good morning$name!';
    if (h < 14) return "Let's cook$name!";
    if (h < 18) return 'Keep cooking$name!';
    return 'Good evening$name!';
  }

  int get _totalXp => _recipes.where((r) => !r.isLocked).fold(0, (s, r) => s + r.xpReward);
  int get _level => (_totalXp / 500).floor() + 1;
  int get _currentLevelXp => _totalXp % 500;
  static const int _xpPerLevel = 500;

  List<Recipe> _forCategory(String cat) =>
      _recipes.where((r) => r.category == cat).toList();

  Recipe? _randomRecipe(List<Recipe> recipes) {
    if (recipes.isEmpty) return null;
    return recipes[_rng.nextInt(recipes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(child: _buildCategories()),
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
            children: [
              Expanded(
                child: Text(
                  _greeting,
                  style: AppTextStyles.heading(20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              LevelXpWidget(
                level: _level,
                currentXp: _currentLevelXp,
                maxXp: _xpPerLevel,
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
          padding: const EdgeInsets.all(outerPadding),
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
                    featuredRecipe: _randomRecipe(_forCategory(cat.key)),
                    totalRecipes: _forCategory(cat.key).length,
                    doneRecipes: _forCategory(cat.key).where((r) => !r.isLocked).length,
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

class _CategoryCard extends StatelessWidget {
  final _Category category;
  final Recipe? featuredRecipe;
  final int totalRecipes;
  final int doneRecipes;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.featuredRecipe,
    required this.totalRecipes,
    required this.doneRecipes,
    required this.onTap,
  });

  String get _imageUrl {
    final url = featuredRecipe?.imageUrl;
    if (url == null || url.isEmpty) return category.imageUrl;
    if (url.startsWith('http')) return url;
    return 'http://192.168.1.31:8000$url';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.network(
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
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: AppTextStyles.heading(22)),
                  Text(
                    '$doneRecipes / $totalRecipes recipes done',
                    style: AppTextStyles.body(13, color: Colors.white70),
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
