import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'recipe_detail_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late Future<List<Recipe>> _future;

  @override
  void initState() {
    super.initState();
    _future = RecipeService.fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECD8),
      body: FutureBuilder<List<Recipe>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Could not connect to backend.'));
          }
          final recipes = snap.data!;
          return CustomScrollView(
            slivers: [
              _ArchiveHeader(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _RecipeRow(recipe: recipes[i]),
                    childCount: recipes.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArchiveHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFF2C1A0E),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 24, right: 24, bottom: 20,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHEFS QUEST',
              style: TextStyle(fontSize: 10, letterSpacing: 3, color: Color(0xFFC4914A), fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'Recipe Archive',
              style: TextStyle(fontSize: 26, color: Color(0xFFF5E6C8), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Choose what to learn next',
              style: TextStyle(fontSize: 12, color: Color(0xFFC4B49A)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeRow extends StatelessWidget {
  final Recipe recipe;
  const _RecipeRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return recipe.isLocked ? _LockedRow(recipe: recipe) : _UnlockedRow(recipe: recipe);
  }
}

class _UnlockedRow extends StatelessWidget {
  final Recipe recipe;
  const _UnlockedRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: _diffColor(recipe.difficulty), width: 4)),
          boxShadow: [BoxShadow(color: const Color(0xFF2C1A0E).withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C1A0E)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _DiffBadge(difficulty: recipe.difficulty),
                      const SizedBox(width: 8),
                      Text('+${recipe.xpReward} XP', style: const TextStyle(fontSize: 11, color: Color(0xFFC4914A), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFC4B49A)),
          ],
        ),
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  final Recipe recipe;
  const _LockedRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E8D8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCBEA8).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sketchy title — partially legible
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9C8C7C),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _DiffBadge(difficulty: recipe.difficulty, faded: true),
                    const SizedBox(width: 8),
                    Text('${recipe.xpReward} XP to unlock', style: const TextStyle(fontSize: 11, color: Color(0xFF9C8C7C))),
                  ],
                ),
              ],
            ),
          ),
          // Sketch lines to suggest "unfinished"
          const _SketchIcon(),
        ],
      ),
    );
  }
}

class _SketchIcon extends StatelessWidget {
  const _SketchIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFCCBEA8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCCBEA8).withOpacity(0.5), width: 1.5),
      ),
      child: const Center(
        child: Text('✏️', style: TextStyle(fontSize: 14)),
      ),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  final String difficulty;
  final bool faded;
  const _DiffBadge({required this.difficulty, this.faded = false});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'easy': (const Color(0xFFDCFCE7), const Color(0xFF166534)),
      'medium': (const Color(0xFFFEF9C3), const Color(0xFF854D0E)),
      'hard': (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
    };
    final (bg, fg) = colors[difficulty] ?? (const Color(0xFFF3F4F6), const Color(0xFF6B7280));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: faded ? bg.withOpacity(0.5) : bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: faded ? fg.withOpacity(0.5) : fg, letterSpacing: 0.5),
      ),
    );
  }
}

Color _diffColor(String difficulty) => switch (difficulty) {
  'easy' => const Color(0xFF4CAF50),
  'medium' => const Color(0xFFF5C842),
  'hard' => const Color(0xFFE53935),
  _ => const Color(0xFFC4914A),
};
