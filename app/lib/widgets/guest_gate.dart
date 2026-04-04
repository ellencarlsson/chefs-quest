import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Shows a bottom sheet prompting guest users to create an account.
/// Call this before allowing access to features that require auth.
class GuestGate {
  static void show(BuildContext context, {String? feature}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GuestGateSheet(feature: feature),
    );
  }
}

class _GuestGateSheet extends StatelessWidget {
  final String? feature;
  const _GuestGateSheet({this.feature});

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
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.muted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text('🔐', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Skapa ett konto',
            style: AppTextStyles.headingDark(22),
          ),
          const SizedBox(height: 8),
          Text(
            feature != null
                ? 'Skapa ett konto för att låsa upp $feature.'
                : 'Skapa ett konto för att låsa upp det här.',
            style: AppTextStyles.body(14, color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('Skapa konto', style: AppTextStyles.label(15, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Inte nu', style: AppTextStyles.body(14, color: AppColors.muted)),
          ),
        ],
      ),
    );
  }
}
