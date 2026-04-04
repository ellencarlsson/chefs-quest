import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/recipe.dart';
import '../widgets/unlock_bottom_sheet.dart';
import 'recipe_detail_screen.dart';

class CategoryInfo {
  final String name;
  final String emoji;
  final String key;
  const CategoryInfo(this.name, this.emoji, this.key);
}

class CategoryScreen extends StatelessWidget {
  final dynamic category;
  final List<Recipe> recipes;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.recipes,
  });

  String get _emoji => category.emoji as String;
  String get _name => category.name as String;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _RecipeNode(
                  recipe: recipes[i],
                  index: i,
                  isLast: i == recipes.length - 1,
                  onTap: () => _handleTap(context, recipes[i]),
                ),
                childCount: recipes.length,
              ),
            ),
          ),
          if (recipes.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'Inga recept här ännu.',
                  style: AppTextStyles.body(16, color: AppColors.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, Recipe recipe) {
    if (recipe.isLocked) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => UnlockBottomSheet(recipe: recipe),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                Text(_emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                Text(_name, style: AppTextStyles.heading(28)),
                const SizedBox(height: 4),
                Text(
                  '${recipes.where((r) => !r.isLocked).length} / ${recipes.length} upplåsta',
                  style: AppTextStyles.body(13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeNode extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final bool isLast;
  final VoidCallback onTap;

  const _RecipeNode({
    required this.recipe,
    required this.index,
    required this.isLast,
    required this.onTap,
  });

  bool get _isLeft => index.isEven;

  NodeState get _state {
    if (!recipe.isLocked) return NodeState.done;
    // The first locked after done ones is "current"
    return NodeState.locked;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: _isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onTap,
              child: _NodeBubble(recipe: recipe, state: _state),
            ),
          ],
        ),
        if (!isLast) _DashedLine(isLeft: _isLeft),
      ],
    );
  }
}

enum NodeState { done, current, locked }

class _NodeBubble extends StatelessWidget {
  final Recipe recipe;
  final NodeState state;

  const _NodeBubble({required this.recipe, required this.state});

  Color get _bg {
    switch (state) {
      case NodeState.done:
        return AppColors.primary;
      case NodeState.current:
        return AppColors.gold;
      case NodeState.locked:
        return AppColors.locked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = state == NodeState.done;
    final isLocked = state == NodeState.locked;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLocked ? Colors.white : _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? AppColors.locked : _bg,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLocked
                  ? AppColors.locked.withOpacity(0.3)
                  : Colors.white.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                isDone ? '✓' : isLocked ? '🔒' : '▶',
                style: TextStyle(
                  fontSize: 16,
                  color: isLocked ? AppColors.muted : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: AppTextStyles.label(
                    13,
                    color: isLocked ? AppColors.muted : Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${recipe.xpReward} XP',
                  style: AppTextStyles.body(
                    10,
                    color: isLocked
                        ? AppColors.locked
                        : Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final bool isLeft;
  const _DashedLine({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: CustomPaint(
        painter: _DashedPainter(isLeft: isLeft),
        size: const Size(double.infinity, 32),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final bool isLeft;
  const _DashedPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.muted.withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const dashSpace = 4.0;
    final x = isLeft ? 110.0 : size.width - 110.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashHeight), paint);
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
