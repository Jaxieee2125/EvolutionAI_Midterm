import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_event.dart';
import '../../logic/blocs/auth/auth_state.dart';
import '../../ui/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.header,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(LucideIcons.chefHat, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Evolution AI",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Khám phá và chia sẻ món ăn tuyệt vời",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Card form
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppColors.radius)),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (state.isAuthenticated) {

                        } else if (state.error != null && state.error!.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error!)),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.foreground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _email,
                                decoration: const InputDecoration(
                                  labelText: 'Tên đăng nhập', // thay vì 'Email'
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Nhập tên đăng nhập' : null,
                              ),

                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _password,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Mật khẩu',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                v == null || v.isEmpty ? 'Nhập mật khẩu' : null,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      LoginRequested(
                                        _email.text,
                                        _password.text,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(AppColors.radius),
                                  ),
                                ),
                                child: state.isLoading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => context.go('/register'),
                                child: const Text(
                                  'Chưa có tài khoản? Đăng ký ngay',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
