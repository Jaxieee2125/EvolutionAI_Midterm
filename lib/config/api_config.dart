class ApiConfig {
  // Đổi thành IP thật của backend ASP.NET Core
  // Nếu chạy local: dùng IP máy thật, không dùng localhost khi build Android
  static const String baseUrl = 'http://192.168.1.133:7288/api';
}
