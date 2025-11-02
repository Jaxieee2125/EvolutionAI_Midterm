import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/api_config.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:dio/dio.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(const AuthState()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  // ===== LOGIN =====
  Future<void> _onLogin(LoginRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final token = await _repo.login(e.username, e.password);
      final decoded = JwtDecoder.decode(token!);
      final role = decoded['role'] ?? decoded['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      await SharedPreferences.getInstance()
        ..setString('token', token)
        ..setString('role', role);

      emit(state.copyWith(isAuthenticated: true, token: token));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      emit(state.copyWith(
        isAuthenticated: true,
        token: token,
        isLoading: false,
      ));
        } catch (err) {
      emit(state.copyWith(isLoading: false, error: err.toString()));
    }
  }

// ===== REGISTER =====
  Future<void> _onRegister(RegisterRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      // ✅ Gửi cả 3 trường: username, email, password
      await _repo.register(e.username, e.email, e.password);
      emit(state.copyWith(isLoading: false));
    } catch (err) {
      emit(state.copyWith(isLoading: false, error: err.toString()));
    }
  }

  // ===== LOGOUT =====
  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    emit(const AuthState(isAuthenticated: false));
  }

  // ===== CHECK TOKEN LÚC KHỞI ĐỘNG =====
  Future<void> _onCheckAuthStatus(
      CheckAuthStatus e, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      emit(const AuthState(isAuthenticated: false));
      return;
    }

    try {
      // ✅ Gọi API /auth/me để xác thực lại
      final res = await Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 10),
      )).get('/auth/me');

      if (res.statusCode == 200) {
        final data = res.data;
        final role = data['role'] ?? 'user';
        await prefs.setString('role', role);
        emit(state.copyWith(isAuthenticated: true, token: token));
      } else {
        // Token sai hoặc hết hạn
        await AuthRepository.clearToken();
        emit(const AuthState(isAuthenticated: false));
      }
    } catch (err) {
      // Nếu lỗi mạng hoặc token không hợp lệ
      await AuthRepository.clearToken();
      emit(const AuthState(isAuthenticated: false));
    }
  }

}
