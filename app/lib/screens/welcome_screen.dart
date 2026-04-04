import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _continueAsGuest() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _showComingSoon(BuildContext context, String action) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComingSoonSheet(action: action),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.dark, Color(0xFF1A3024)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _Logo(),
                    const SizedBox(height: 16),
                    Text(
                      'Chefs Quest',
                      style: AppTextStyles.heading(36),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Laga mat. Lås upp recept. Bli kock.',
                      style: AppTextStyles.body(15, color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 3),
                    _PrimaryButton(
                      label: 'Skapa konto',
                      onTap: () => _showComingSoon(context, 'Skapa konto'),
                    ),
                    const SizedBox(height: 12),
                    _SecondaryButton(
                      label: 'Logga in',
                      onTap: () => _showComingSoon(context, 'Logga in'),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: _continueAsGuest,
                      child: Text(
                        'Fortsätt som gäst',
                        style: AppTextStyles.body(14, color: AppColors.muted),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatefulWidget {
  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bob,
      builder: (_, __) {
        final dy = math.sin(_bob.value * 2 * math.pi) * 6;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.25),
              border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 2),
            ),
            child: const Center(
              child: Text('👨‍🍳', style: TextStyle(fontSize: 52)),
            ),
          ),
        );
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label, style: AppTextStyles.label(16, color: Colors.white)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label, style: AppTextStyles.label(16, color: Colors.white)),
      ),
    );
  }
}

class _ComingSoonSheet extends StatelessWidget {
  final String action;
  const _ComingSoonSheet({required this.action});

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
          const Text('🚧', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('$action kommer snart', style: AppTextStyles.headingDark(22)),
          const SizedBox(height: 8),
          Text(
            'Konton och inloggning är på väg. Fortsätt som gäst tills vidare.',
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
              child: Text('Okej', style: AppTextStyles.label(15, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
