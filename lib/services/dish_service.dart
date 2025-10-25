import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../data/models/dish.dart';
import '../config/api_config.dart';
import '../data/repositories/auth_repository.dart';

class DishService {
  static Uri _uri(String path, [Map<String, String>? qp]) =>
      Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: qp);

  // -------------------------------
  // LẤY DANH SÁCH MÓN ĂN
  // -------------------------------
  static Future<List<Dish>> fetchDishes() async {
    final res = await http.get(_uri('/dishes'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load dishes: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body);
    print('🍽️ Dishes response: ${res.body}');
    return data.map((e) => Dish.fromJson(e)).toList();
  }

  // -------------------------------
  // LẤY CHI TIẾT MÓN ĂN THEO ID
  // -------------------------------
  static Future<Dish> fetchDishById(int id) async {
    final token = await AuthRepository.getToken();

    final res = await http.get(
      _uri('/dishes/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('📥 fetchDishById(${id}) → ${res.statusCode}');
    print('Body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load dish detail (${res.statusCode})');
    }

    return Dish.fromJson(jsonDecode(res.body));
  }

  // -------------------------------
  // TÌM KIẾM CÓ PHÂN TRANG
  // -------------------------------
  static Future<List<Dish>> search({
    String q = '',
    int? categoryId,
    int page = 1,
    int size = 10,
    String sort = 'name',
  }) async {
    final qp = <String, String>{
      if (q.isNotEmpty) 'q': q,
      if (categoryId != null) 'categoryId': '$categoryId',
      'page': '$page',
      'size': '$size',
      'sort': sort,
    };
    final res = await http.get(_uri('/dishes/search', qp));

    print('🔍 Search URL: ${_uri('/dishes/search', qp)}');
    print('Status: ${res.statusCode}');
    print('Body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to search dishes: ${res.statusCode}');
    }

    final Map<String, dynamic> body = jsonDecode(res.body);
    final List data = body['data'] as List? ?? const [];
    return data.map((e) => Dish.fromJson(e)).toList();
  }

  // -------------------------------
  // TÌM KIẾM RAW (CÓ META)
  // -------------------------------
  static Future<Map<String, dynamic>> searchRaw({
    String q = '',
    int? categoryId,
    int page = 1,
    int size = 10,
    String sort = 'name',
  }) async {
    final qp = <String, String>{
      if (q.isNotEmpty) 'q': q,
      if (categoryId != null) 'categoryId': '$categoryId',
      'page': '$page',
      'size': '$size',
      'sort': sort,
    };
    final res = await http.get(_uri('/dishes/search', qp));
    if (res.statusCode != 200) {
      throw Exception('Failed to search dishes: ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // -------------------------------
  // TẠO MÓN ĂN MỚI (MULTIPART)
  // -------------------------------
  static Future<bool> createDish({
    required String name,
    required String description,
    required String difficulty,
    required int cookingTime,
    required List<String> ingredients,
    required List<String> steps,
    required File imageFile,
    required int categoryId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/dishes');
    final req = http.MultipartRequest('POST', uri);

    req.fields['Name'] = name;
    req.fields['Description'] = description;
    req.fields['Difficulty'] = difficulty;
    req.fields['CookingTime'] = cookingTime.toString();
    req.fields['Ingredients'] = ingredients.join('|');
    req.fields['Steps'] = steps.join('|');
    req.fields['CategoryId'] = categoryId.toString();
    req.files.add(await http.MultipartFile.fromPath('Image', imageFile.path));

    final res = await req.send();
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // -------------------------------
  // LẤY CHI TIẾT MÓN ĂN (TÊN NGẮN)
  // -------------------------------
  static Future<Dish> getDishById(int id) => fetchDishById(id);

  // -------------------------------
  // YÊU THÍCH / BỎ YÊU THÍCH MÓN ĂN
  // -------------------------------
  static Future<bool> toggleFavorite(int dishId) async {
    final token = await AuthRepository.getToken();
    print('🔑 Token hiện tại: $token');
    if (token == null) throw Exception('Chưa đăng nhập');
    final url = Uri.parse('${ApiConfig.baseUrl}/favorites/$dishId');

    final res = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('❤️ toggleFavorite → ${res.statusCode}');
    print('📩 Response body: ${res.body}');
    return res.statusCode == 200;
  }

  static Future<List<Dish>> fetchFavorites() async {
    final token = await AuthRepository.getToken();
    if (token == null) throw Exception('Chưa đăng nhập');
    final url = Uri.parse('${ApiConfig.baseUrl}/favorites');
    final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    print('📥 fetchFavorites → ${res.statusCode}');
    print('📦 Response body: ${res.body}');
    if (res.statusCode != 200) throw Exception('Không thể tải danh sách yêu thích');
    final List data = jsonDecode(res.body);
    return data.map((e) => Dish.fromJson(e)).toList();
  }
}
