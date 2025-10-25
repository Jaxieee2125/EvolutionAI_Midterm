import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/category.dart';
import '../config/api_config.dart';

class CategoryService {
  static Future<List<Category>> fetchCategories() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/category'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Failed to load categories');
  }
}
