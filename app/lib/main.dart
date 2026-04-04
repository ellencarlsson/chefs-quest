import 'package:flutter/material.dart';
import 'screens/recipe_library_screen.dart';

void main() {
  runApp(const ChefsQuestApp());
}

class ChefsQuestApp extends StatelessWidget {
  const ChefsQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chefs Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const RecipeLibraryScreen(),
    );
  }
}
