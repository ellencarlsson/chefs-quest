import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_image.dart';
import 'recipe_detail_screen.dart';

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

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 10) return 'God morgon 👋';
    if (h < 17) return 'God dag 👋';
    return 'God kväll 👋';
  }

  // Unlocked recipes = "popular" (show first)
  List<Recipe> get _popular => _recipes.where((r) => !r.isLocked).toList();

  // Locked recipes = "new this week"
  List<Recipe> get _newThisWeek => _recipes.where((r) => r.isLocked).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (_popular.isNotEmpty)
                SliverToBoxAdapter(
                  child: _RecipeRow(
                    title: 'Populära recept',
                    recipes: _popular,
                  ),
                ),
              if (_newThisWeek.isNotEmpty)
                SliverToBoxAdapter(
                  child: _RecipeRow(
                    title: 'Nytt den här veckan',
                    recipes: _newThisWeek,
                  ),
                ),
              if (_recipes.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('Inga recept hittades'),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chefs Quest', style: AppTextStyles.body(12, color: AppColors.muted)),
                const SizedBox(height: 8),
                Text(_greeting, style: AppTextStyles.heading(26)),
                const SizedBox(height: 4),
                Text(
                  'Vad ska vi laga idag?',
                  style: AppTextStyles.body(14, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeRow extends StatelessWidget {
  final String title;
  final List<Recipe> recipes;

  const _RecipeRow({required this.title, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(title, style: AppTextStyles.headingDark(20)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recipes.length,
              itemBuilder: (context, i) => _RecipeCard(recipe: recipes[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: recipe),
        ),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: RecipeImage(
                imageUrl: recipe.imageUrl,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: AppTextStyles.label(13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _DifficultyDot(difficulty: recipe.difficulty),
                      const SizedBox(width: 6),
                      Text(
                        '${recipe.xpReward} XP',
                        style: AppTextStyles.body(11, color: AppColors.muted),
                      ),
                      if (recipe.isLocked) ...[
                        const Spacer(),
                        const Icon(Icons.lock, size: 13, color: AppColors.muted),
                      ],
                    ],
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

class _DifficultyDot extends StatelessWidget {
  final String difficulty;
  const _DifficultyDot({required this.difficulty});

  Color get _color {
    switch (difficulty.toLowerCase()) {
      case 'easy': return Colors.green;
      case 'medium': return Colors.orange;
      case 'hard': return Colors.red;
      default: return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}
