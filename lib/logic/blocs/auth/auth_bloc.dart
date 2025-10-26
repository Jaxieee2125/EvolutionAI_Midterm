import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

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
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        emit(state.copyWith(
          isAuthenticated: true,
          token: token,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Không nhận được token'));
      }
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
    if (token != null && token.isNotEmpty) {
      emit(state.copyWith(isAuthenticated: true, token: token));
    } else {
      emit(const AuthState(isAuthenticated: false));
    }
  }
}
