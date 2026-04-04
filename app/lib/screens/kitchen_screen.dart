import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'menu_screen.dart';

const _kBench = Color(0xFF2A1508);
const _kWood = Color(0xFF3D2010);
const _kGold = Color(0xFFC4914A);
const _kCream = Color(0xFFF5E6C8);

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  late Future<List<Recipe>> _future;

  @override
  void initState() {
    super.initState();
    _future = RecipeService.fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120A04),
      body: FutureBuilder<List<Recipe>>(
        future: _future,
        builder: (context, snap) {
          final unlocked = snap.data?.where((r) => !r.isLocked).length ?? 0;
          return Stack(
            children: [
              _Background(),
              _Shelves(unlocked: unlocked),
              _Counter(unlocked: unlocked),
              _TopBar(unlocked: unlocked, total: snap.data?.length ?? 0),
              Positioned(
                bottom: 32,
                left: 24,
                right: 24,
                child: _MenuButton(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MenuScreen(recipes: snap.data ?? [])),
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

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0804), Color(0xFF1E0F06), Color(0xFF2A1508)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int unlocked;
  final int total;
  const _TopBar({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CHEFS QUEST',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 3,
                    color: _kGold.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'My Kitchen',
                  style: TextStyle(
                    fontSize: 22,
                    color: _kCream,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.15),
                border: Border.all(color: _kGold.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$unlocked recipes mastered',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFF5C842),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shelves extends StatelessWidget {
  final int unlocked;
  const _Shelves({required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      top: size.height * 0.22,
      left: 0,
      right: 0,
      height: size.height * 0.28,
      child: Stack(
        children: [
          // Shelf board
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            height: 6,
            child: Container(
              decoration: BoxDecoration(
                color: _kWood,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
              ),
            ),
          ),
          // Items on shelf
          if (unlocked >= 3) _ShelfItem(emoji: '🧂', left: 0.1, delay: 200),
          if (unlocked >= 4) _ShelfItem(emoji: '🫙', left: 0.25, delay: 300),
          if (unlocked >= 5) _ShelfItem(emoji: '🌿', left: 0.4, delay: 400),
          if (unlocked >= 7) _ShelfItem(emoji: '🫒', left: 0.55, delay: 200),
          if (unlocked >= 9) _ShelfItem(emoji: '🍷', left: 0.72, delay: 300),
        ],
      ),
    );
  }
}

class _ShelfItem extends StatefulWidget {
  final String emoji;
  final double left;
  final int delay;
  const _ShelfItem({required this.emoji, required this.left, required this.delay});

  @override
  State<_ShelfItem> createState() => _ShelfItemState();
}

class _ShelfItemState extends State<_ShelfItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Positioned(
      left: width * widget.left,
      top: 20,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final int unlocked;
  const _Counter({required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      height: size.height * 0.32,
      child: Stack(
        children: [
          // Counter top
          Positioned(
            top: 0, left: 0, right: 0, height: 12,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5C3018), Color(0xFF7A4020), Color(0xFF5C3018)],
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, -4))],
              ),
            ),
          ),
          // Counter body (wood)
          Positioned(
            top: 12, left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3D2010), Color(0xFF2A1508)],
                ),
              ),
            ),
          ),
          // Items on counter
          if (unlocked >= 1) _CounterItem(emoji: '🍳', left: 0.08, size: 52, delay: 100),
          if (unlocked >= 2) _CounterItem(emoji: '🪴', left: 0.75, size: 44, delay: 150),
          if (unlocked >= 6) _CounterItem(emoji: '🤖', left: 0.55, size: 56, delay: 200, label: 'KitchenAid'),
          if (unlocked >= 8) _CounterItem(emoji: '🔪', left: 0.35, size: 40, delay: 250),
          if (unlocked == 0)
            Positioned(
              top: 30,
              left: 0, right: 0,
              child: Text(
                'Your kitchen is empty.\nMaster your first recipe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kCream.withOpacity(0.3),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CounterItem extends StatefulWidget {
  final String emoji;
  final double left;
  final double size;
  final int delay;
  final String? label;
  const _CounterItem({required this.emoji, required this.left, required this.size, required this.delay, this.label});

  @override
  State<_CounterItem> createState() => _CounterItemState();
}

class _CounterItemState extends State<_CounterItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Positioned(
      left: width * widget.left,
      top: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFC4914A), Color(0xFFD4A85A)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFFC4914A).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📋', style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            Text(
              'Show My Menu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C0E04), letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
