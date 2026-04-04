import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/kitchen_screen.dart';
import 'screens/archive_screen.dart';

void main() {
  runApp(const ChefsQuestApp());
}

class ChefsQuestApp extends StatelessWidget {
  const ChefsQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chefs Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/home': (_) => const _RootNav(),
      },
    );
  }
}

class _RootNav extends StatefulWidget {
  const _RootNav();

  @override
  State<_RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<_RootNav> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    KitchenScreen(),
    ArchiveScreen(),
    _PlaceholderScreen(emoji: '👤', label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.dark,
        indicatorColor: AppColors.gold.withOpacity(0.25),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Text('🏠', style: TextStyle(fontSize: 22)),
            selectedIcon: Text('🏠', style: TextStyle(fontSize: 24)),
            label: 'Hem',
          ),
          NavigationDestination(
            icon: Text('🍳', style: TextStyle(fontSize: 22)),
            selectedIcon: Text('🍳', style: TextStyle(fontSize: 24)),
            label: 'Utforska',
          ),
          NavigationDestination(
            icon: Text('📚', style: TextStyle(fontSize: 22)),
            selectedIcon: Text('📚', style: TextStyle(fontSize: 24)),
            label: 'Vänner',
          ),
          NavigationDestination(
            icon: Text('👤', style: TextStyle(fontSize: 22)),
            selectedIcon: Text('👤', style: TextStyle(fontSize: 24)),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String emoji;
  final String label;

  const _PlaceholderScreen({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.headingDark(24)),
          ],
        ),
      ),
    );
  }
}
