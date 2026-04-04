import 'package:flutter/material.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC4914A)),
        useMaterial3: true,
      ),
      home: const _RootNav(),
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
    KitchenScreen(),
    ArchiveScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: const Color(0xFF1C0E06),
        indicatorColor: const Color(0xFFC4914A).withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Text('🍳', style: TextStyle(fontSize: 22)),
            label: 'Kitchen',
          ),
          NavigationDestination(
            icon: Text('📚', style: TextStyle(fontSize: 22)),
            label: 'Archive',
          ),
        ],
      ),
    );
  }
}
