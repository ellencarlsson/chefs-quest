import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class MenuScreen extends StatelessWidget {
  final List<Recipe> recipes;
  const MenuScreen({super.key, required this.recipes});

  List<Recipe> get _mastered => recipes.where((r) => !r.isLocked).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECD8),
      body: CustomScrollView(
        slivers: [
          _MenuHeader(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: _mastered.isEmpty ? _EmptyMenu() : _MenuList(recipes: _mastered),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFF2C1A0E),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24, right: 24, bottom: 28,
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFC4914A), size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '— CHEF\'S TABLE —',
              style: TextStyle(fontSize: 10, letterSpacing: 4, color: Color(0xFFC4914A), fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'My Menu',
              style: TextStyle(
                fontSize: 34,
                color: Color(0xFFF5E6C8),
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'A collection of mastered recipes',
              style: TextStyle(fontSize: 12, color: Color(0xFFC4B49A)),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: const Color(0xFFC4914A).withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final List<Recipe> recipes;
  const _MenuList({required this.recipes});

  Map<String, List<Recipe>> get _grouped {
    final map = <String, List<Recipe>>{};
    for (final r in recipes) {
      map.putIfAbsent(r.difficulty, () => []).add(r);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final order = ['easy', 'medium', 'hard'];
    final sections = order.where((d) => grouped.containsKey(d)).toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final difficulty = sections[index];
          final sectionRecipes = grouped[difficulty]!;
          return _MenuSection(difficulty: difficulty, recipes: sectionRecipes);
        },
        childCount: sections.length,
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String difficulty;
  final List<Recipe> recipes;
  const _MenuSection({required this.difficulty, required this.recipes});

  String get _label => switch (difficulty) {
    'easy' => 'Entrées',
    'medium' => 'Main Course',
    'hard' => 'Chef\'s Specials',
    _ => difficulty,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFF2C1A0E), thickness: 0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                _label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.5,
                  color: Color(0xFF8B6340),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFF2C1A0E), thickness: 0.5)),
          ],
        ),
        const SizedBox(height: 16),
        ...recipes.map((r) => _MenuEntry(recipe: r)),
      ],
    );
  }
}

class _MenuEntry extends StatelessWidget {
  final Recipe recipe;
  const _MenuEntry({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1A0E),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (recipe.description != null && recipe.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        recipe.description!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8B7355), height: 1.4),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                Text(
                  '${recipe.xpReward} XP',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFC4914A), fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFFC4B49A)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'Your menu is empty.',
              style: TextStyle(fontSize: 18, color: Color(0xFF2C1A0E), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Master your first recipe to add it.',
              style: TextStyle(fontSize: 13, color: const Color(0xFF8B7355).withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
