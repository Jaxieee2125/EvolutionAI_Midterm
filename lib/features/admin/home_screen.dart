import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../ui/theme/colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('🔑 Token gửi đi: $token');

    try {
      final res = await Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      )).get('/user?excludeSelf=true');

      print('✅ API trả về: ${res.statusCode}');
      final users = (res.data as List).cast<Map<String, dynamic>>();
      setState(() {
        _allUsers = users;
        _applyFilters();
      });
    } on DioException catch (e) {
      print('❌ Lỗi khi gọi API /user: ${e.response?.statusCode} ${e.response?.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải user: ${e.response?.statusCode}')),
      );
    }
  }

  void _applyFilters() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final matchRole = _selectedRole == 'all' || u['role'] == _selectedRole;
        final matchText = u['username'].toString().toLowerCase().contains(q) ||
            u['email'].toString().toLowerCase().contains(q);
        return matchRole && matchText;
      }).toList();
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _applyFilters);
  }

  Future<void> _toggleRole(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Authorization': 'Bearer $token'},
    )).put('/user/$id/role');
    _loadUsers();
  }

  Future<void> _deleteUser(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Authorization': 'Bearer $token'},
    )).delete('/user/$id');
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // 1️⃣ Header gradient + search box
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.header),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quản lý người dùng',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(LucideIcons.users, color: Colors.white, size: 30),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Tìm theo tên hoặc email...',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2️⃣ Filter chips (role)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Admin', 'admin'),
                  const SizedBox(width: 8),
                  _buildFilterChip('User', 'user'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 3️⃣ Danh sách user
          Expanded(
            child: _filteredUsers.isEmpty
                ? const Center(child: Text('Không tìm thấy người dùng nào'))
                : ListView.builder(
              key: const PageStorageKey<String>('adminUserScroll'),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, i) =>
                  _buildUserCard(_filteredUsers[i]),
            ),
          ),
        ],
      ),

      // 4️⃣ Logout FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          if (context.mounted) context.go('/login');
        },
        icon: const Icon(LucideIcons.logOut),
        label: const Text('Đăng xuất'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _selectedRole == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedRole = value);
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.muted.withOpacity(0.3),
          border: Border.all(
              color: selected
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> u) {
    final role = u['role']?.toString() ?? 'user';
    final color = role == 'admin' ? AppColors.primary : AppColors.textMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleRole(u['id']),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar nổi bật hơn
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: role == 'admin'
                            ? AppColors.primary.withOpacity(0.4)
                            : AppColors.muted.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: role == 'admin'
                          ? [AppColors.primary, AppColors.accent]
                          : [AppColors.muted, AppColors.muted.withOpacity(0.7)],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      role == 'admin' ? LucideIcons.shield : LucideIcons.user,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u['username'] ?? '',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        u['email'] ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: role == 'admin'
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.muted.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Column(
                  children: [
                    IconButton(
                      tooltip: 'Đổi quyền',
                      icon: const Icon(LucideIcons.refreshCcw,
                          color: AppColors.primary),
                      onPressed: () => _toggleRole(u['id']),
                    ),
                    IconButton(
                      tooltip: 'Xoá người dùng',
                      icon: const Icon(LucideIcons.trash2,
                          color: Colors.redAccent),
                      onPressed: () => _deleteUser(u['id']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
