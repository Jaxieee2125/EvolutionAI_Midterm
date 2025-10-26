import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../data/repositories/auth_repository.dart';

class UserService {
  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await AuthRepository.getToken();
    if (token == null) throw Exception('Chưa đăng nhập');
    print('🔑 Token: $token');
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Không thể tải thông tin người dùng: ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
