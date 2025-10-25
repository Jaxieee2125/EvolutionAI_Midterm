class Ingredient {
  final int id;
  final String name;
  final String unit;
  final double quantity;

  Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: json['id'],
    name: json['name'],
    unit: json['unit'],
    quantity: (json['quantity'] as num).toDouble(),
  );
}