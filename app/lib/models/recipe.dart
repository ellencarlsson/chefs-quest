class RecipeIngredient {
  final int id;
  final String name;
  final String? amount;
  final String? unit;

  const RecipeIngredient({
    required this.id,
    required this.name,
    this.amount,
    this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: json['amount'] as String?,
      unit: json['unit'] as String?,
    );
  }
}

class RecipeStep {
  final int id;
  final int stepNumber;
  final String instruction;

  const RecipeStep({
    required this.id,
    required this.stepNumber,
    required this.instruction,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'] as int,
      stepNumber: json['step_number'] as int,
      instruction: json['instruction'] as String,
    );
  }
}

class Recipe {
  final int id;
  final String title;
  final String? description;
  final String difficulty;
  final int xpReward;
  final bool isLocked;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  const Recipe({
    required this.id,
    required this.title,
    this.description,
    required this.difficulty,
    required this.xpReward,
    required this.isLocked,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String,
      xpReward: json['xp_reward'] as int,
      isLocked: json['is_locked'] as bool,
      ingredients: (json['ingredients'] as List)
          .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber)),
    );
  }
}
