import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

// Use 10.0.2.2 for Android emulator, localhost for iOS simulator / web
const String kBaseUrl = 'http://192.168.1.31:8000';

class RecipeService {
  static Future<List<Recipe>> fetchRecipes({int retries = 3}) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final response = await http
            .get(Uri.parse('$kBaseUrl/recipes/'))
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw Exception('Failed to load recipes');
        }
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        if (attempt < retries - 1) {
          await Future.delayed(const Duration(seconds: 2));
        } else {
          rethrow;
        }
      }
    }
    return [];
  }
}
