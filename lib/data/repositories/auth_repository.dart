import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class AuthRepository {
  late final Dio _dio;

  AuthRepository() {
    _dio = Dio(BaseOptions(
      baseUrl: '${ApiConfig.baseUrl}/auth',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  // -------------------------
  // Đăng nhập + lưu token
  // -------------------------
  Future<String?> login(String username, String password) async {
    try {
      final res = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      final token = res.data['token'] as String?;
      if (token != null) await saveToken(token);
      return token;
    } catch (e) {
      rethrow;
    }
  }

  // -------------------------
  // Đăng ký
  // -------------------------
  Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  // -------------------------
  // Lưu token cục bộ
  // -------------------------
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // -------------------------
  // Lấy token hiện tại
  // -------------------------
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // -------------------------
  // Xoá token (khi logout)
  // -------------------------
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
