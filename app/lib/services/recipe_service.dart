import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

// Use 10.0.2.2 for Android emulator, localhost for iOS simulator / web
const String _baseUrl = 'http://10.0.2.2:8000';

class RecipeService {
  static Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse('$_baseUrl/recipes/'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load recipes');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
