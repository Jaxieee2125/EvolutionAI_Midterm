import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_event.dart';
import '../../logic/blocs/auth/auth_state.dart';
import '../../ui/theme/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

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
        child: Stack(
          children: [
            // Nút quay lại
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
                onPressed: () => context.go('/login'),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
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
                      "Tạo tài khoản của bạn",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // Form đăng ký
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppColors.radius)),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) async {
                            // ✅ Khi có lỗi thật
                            if (state.error != null && state.error!.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error!)),
                              );
                            }

                            // ✅ Khi đăng ký thành công (hết loading, không lỗi, và có form hợp lệ)
                            if (!state.isLoading && (state.error == null || state.error!.isEmpty)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đăng ký thành công! Hãy đăng nhập.'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // ⏳ đợi 1 chút để hiển thị SnackBar trước khi chuyển trang
                              await Future.delayed(const Duration(milliseconds: 1500));

                              if (context.mounted) context.go('/login');
                            }
                          },
                          builder: (context, state) {
                            return Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Đăng ký',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.foreground,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),

                                  // Tên đăng nhập
                                  TextFormField(
                                    controller: _fullName,
                                    decoration: const InputDecoration(
                                      labelText: 'Tên đăng nhập',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Nhập tên đăng nhập'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  TextFormField(
                                    controller: _email,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Nhập email'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Mật khẩu
                                  TextFormField(
                                    controller: _password,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Mật khẩu',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Nhập mật khẩu'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Xác nhận mật khẩu
                                  TextFormField(
                                    controller: _confirmPassword,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Xác nhận mật khẩu',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => v != _password.text
                                        ? 'Mật khẩu không khớp'
                                        : null,
                                  ),

                                  const SizedBox(height: 24),

                                  // Nút đăng ký
                                  ElevatedButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                          RegisterRequested(
                                            _fullName.text,
                                            _email.text,
                                            _password.text,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(AppColors.radius),
                                      ),
                                    ),
                                    child: state.isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                      'Đăng ký',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Chuyển sang đăng nhập
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    child: const Text(
                                      'Đã có tài khoản? Đăng nhập',
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
                    const Text(
                      "Nhập thông tin để tạo tài khoản mới",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
