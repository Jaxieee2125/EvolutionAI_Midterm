import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_event.dart';
import '../../services/user_service.dart';
import '../../ui/theme/colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<Map<String, dynamic>> _futureProfile;
  @override
  void initState() {
    super.initState();
    _futureProfile = UserService.fetchProfile();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        key: const PageStorageKey<String>('profileScroll'),
        slivers: [
          // Header ngắn lại
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: AppGradients.header),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Hồ sơ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(LucideIcons.user, color: Colors.white, size: 26),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _futureProfile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                        CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Không thể tải thông tin người dùng',
                            style: TextStyle(color: AppColors.textMuted)));
                  }

                  final user = snapshot.data!;
                  return Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor:
                                AppColors.primary.withOpacity(0.2),
                                child:
                                const Icon(LucideIcons.user, size: 44),
                              ),
                              const SizedBox(height: 10),
                              Text(user['username'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(user['email'] ?? 'Chưa có email',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 16),

                              // Hai thống kê
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatCard('Bài đăng', user['postCount'].toString()),
                                  _buildStatCard('Đã thích', user['likesGiven'].toString()),
                                  _buildStatCard('Được thích', user['likesReceived'].toString()),
                                ],
                              ),

                              const SizedBox(height: 24),
                              ListTile(
                                leading: const Icon(LucideIcons.userCog,
                                    color: AppColors.primary),
                                title: const Text('Vai trò'),
                                trailing: Text(user['role']),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<AuthBloc>().add(LogoutRequested());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size.fromHeight(45),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(LucideIcons.logOut),
                                label: const Text('Đăng xuất'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(value,
            style:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title,
            style:
            const TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }
}
