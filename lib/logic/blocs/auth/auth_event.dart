import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  LoginRequested(this.username, this.password);
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  RegisterRequested(this.username, this.email, this.password);
}


class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}