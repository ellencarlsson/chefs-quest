import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'category_screen.dart';

const _kCategories = [
  _CategoryInfo('Frukost', '🍳', 'breakfast'),
  _CategoryInfo('Lunch', '🥗', 'lunch'),
  _CategoryInfo('Middag', '🍽️', 'dinner'),
  _CategoryInfo('Mellanmål', '🍎', 'snack'),
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

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 10) return 'God morgon, Ellen';
    if (h < 17) return 'God dag, Ellen';
    return 'God kväll, Ellen';
  }

  int get _totalXp => _recipes.where((r) => !r.isLocked).fold(0, (s, r) => s + r.xpReward);

  List<Recipe> get _recentUnlocked =>
      _recipes.where((r) => !r.isLocked).take(8).toList();

  List<Recipe> _recipesForCategory(String cat) =>
      _recipes.where((r) => r.category == cat).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  _buildHeader(),
                  SliverToBoxAdapter(child: _buildCategoryGrid()),
                  if (_recentUnlocked.isNotEmpty)
                    SliverToBoxAdapter(child: _buildRecentSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Chefs Quest', style: AppTextStyles.body(12, color: AppColors.muted)),
                    _XpBadge(xp: _totalXp),
                  ],
                ),
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

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategorier', style: AppTextStyles.headingDark(20)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: _kCategories.map((cat) {
              final recipes = _recipesForCategory(cat.key);
              return _CategoryCard(
                category: cat,
                recipeCount: recipes.length,
                unlockedCount: recipes.where((r) => !r.isLocked).length,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryScreen(
                      category: cat,
                      recipes: recipes,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Senast lagat', style: AppTextStyles.headingDark(20)),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recentUnlocked.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _RecentCard(recipe: _recentUnlocked[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _XpBadge extends StatelessWidget {
  final int xp;
  const _XpBadge({required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text('$xp XP', style: AppTextStyles.label(12, color: Colors.white)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryInfo category;
  final int recipeCount;
  final int unlockedCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.recipeCount,
    required this.unlockedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 28)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: AppTextStyles.label(14)),
                  const SizedBox(height: 2),
                  Text(
                    '$unlockedCount / $recipeCount recept',
                    style: AppTextStyles.body(11, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final Recipe recipe;
  const _RecentCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            recipe.title,
            style: AppTextStyles.label(12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 3),
              Text('${recipe.xpReward} XP', style: AppTextStyles.body(10, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryInfo {
  final String name;
  final String emoji;
  final String key;

  const _CategoryInfo(this.name, this.emoji, this.key);
}
