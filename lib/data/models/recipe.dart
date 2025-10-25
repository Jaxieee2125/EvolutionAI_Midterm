

class RecipeStep {
  final int id;
  final int order;
  final String instruction;

  RecipeStep({
    required this.id,
    required this.order,
    required this.instruction,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) => RecipeStep(
    id: json['id'],
    order: json['order'],
    instruction: json['instruction'],
  );
}

