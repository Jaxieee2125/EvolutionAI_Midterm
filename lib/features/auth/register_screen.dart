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
            // Back button
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
                      child:
                      const Icon(LucideIcons.chefHat, size: 48, color: Colors.white),
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

                    // Form
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(AppColors.radius)),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error!)),
                              );
                            } else if (!state.isLoading &&
                                state.isAuthenticated == false) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Đăng ký thành công, hãy đăng nhập.')),
                              );
                              context.go('/login');

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
                                  ElevatedButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : () {
                                      if (_formKey.currentState!
                                          .validate()) {
                                        context.read<AuthBloc>().add(
                                          RegisterRequested(
                                            _fullName.text, // tên đăng nhập
                                            _email.text,    // email
                                            _password.text, // mật khẩu
                                          ),
                                        );

                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppColors.radius),
                                      ),
                                    ),
                                    child: state.isLoading
                                        ? const CircularProgressIndicator(
                                        color: Colors.white)
                                        : const Text(
                                      'Đăng ký',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () =>context.go('/login'),
                                    child: const Text(
                                      'Đã có tài khoản? Đăng nhập',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600),
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
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
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
