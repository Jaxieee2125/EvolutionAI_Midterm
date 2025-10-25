class Category {
  final int id;
  final String name;
  final String icon;
  final String color;

  Category({required this.id, required this.name, required this.icon, required this.color});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    color: json['color'],
  );
}
