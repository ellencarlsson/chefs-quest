import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/recipe.dart';

class UnlockBottomSheet extends StatelessWidget {
  final Recipe recipe;

  const UnlockBottomSheet({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.muted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('🔒', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(recipe.title, style: AppTextStyles.headingDark(22), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Laga detta recept IRL för att låsa upp det.',
            style: AppTextStyles.body(14, color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _XpPill(xp: recipe.xpReward),
          const SizedBox(height: 24),
          _UnlockButton(recipe: recipe),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Inte nu',
              style: AppTextStyles.body(14, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _XpPill extends StatelessWidget {
  final int xp;
  const _XpPill({required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '$xp XP',
            style: AppTextStyles.label(14, color: AppColors.gold),
          ),
          const SizedBox(width: 4),
          Text(
            '· Belöning',
            style: AppTextStyles.body(13, color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}

class _UnlockButton extends StatelessWidget {
  final Recipe recipe;
  const _UnlockButton({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          // TODO: trigger cook flow / mark as cooked
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text('Jag lagade detta! 🍳', style: AppTextStyles.label(16, color: Colors.white)),
      ),
    );
  }
}
