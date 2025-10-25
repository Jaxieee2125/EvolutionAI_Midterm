import 'package:evolution_ai/data/models/recipe.dart';
import 'category.dart';
import 'ingredient.dart'; // nơi chứa Ingredient & RecipeStep

class Dish {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final Category? category;
  final String? difficulty;
  final int? cookingTime;
  final double ratingAvg;
  final List<Ingredient>? ingredients;
  final List<RecipeStep>? steps;
  final bool isFavorite;

  Dish({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.category,
    this.difficulty,
    this.cookingTime,
    required this.ratingAvg,
    this.ingredients,
    this.steps,
    this.isFavorite = false,
  });

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    description: json['description'],
    imageUrl: json['imageUrl'],
    category: json['category'] != null
        ? Category.fromJson(json['category'])
        : null,
    difficulty: json['difficulty'],
    cookingTime: json['cookingTime'],
    ratingAvg: (json['ratingAvg'] ?? 0).toDouble(),
    ingredients: (json['ingredients'] as List?)
        ?.map((i) => Ingredient.fromJson(i))
        .toList(),
    steps: (json['steps'] as List?)
        ?.map((s) => RecipeStep.fromJson(s))
        .toList(),
    isFavorite: json['isFavorite'] ?? false,
  );
}
