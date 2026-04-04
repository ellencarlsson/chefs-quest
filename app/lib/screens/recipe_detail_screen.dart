import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../app_theme.dart';
import '../widgets/recipe_image.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: recipe.imageUrl != null ? 240 : 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.title,
                style: AppTextStyles.heading(16),
              ),
              background: RecipeImage(
                imageUrl: recipe.imageUrl,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _DifficultyBadge(difficulty: recipe.difficulty),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text('⭐ ${recipe.xpReward} XP',
                            style: AppTextStyles.label(12, color: AppColors.gold)),
                      ),
                    ],
                  ),
                  if (recipe.description != null && recipe.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(recipe.description!,
                          style: AppTextStyles.body(14, color: AppColors.muted)),
                    ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Ingredients (${recipe.ingredients.length})'),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((i) => _IngredientRow(ingredient: i)),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Steps (${recipe.steps.length})'),
                  const SizedBox(height: 8),
                  ...recipe.steps.map((s) => _StepRow(step: s)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.headingDark(18));
  }
}

class _IngredientRow extends StatelessWidget {
  final RecipeIngredient ingredient;
  const _IngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final qty = [ingredient.amount, ingredient.unit]
        .whereType<String>()
        .join(' ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6),
          const SizedBox(width: 10),
          Expanded(child: Text(ingredient.name)),
          if (qty.isNotEmpty)
            Text(qty,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final RecipeStep step;
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text('${step.stepNumber}',
                style: const TextStyle(fontSize: 12, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(step.instruction,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'easy': (Colors.green[100]!, Colors.green[800]!),
      'medium': (Colors.yellow[100]!, Colors.orange[800]!),
      'hard': (Colors.red[100]!, Colors.red[800]!),
    };
    final (bg, fg) = colors[difficulty] ?? (Colors.grey[200]!, Colors.grey[800]!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(difficulty.toUpperCase(),
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
