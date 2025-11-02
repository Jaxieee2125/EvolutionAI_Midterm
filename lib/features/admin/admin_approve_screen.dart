import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../ui/theme/colors.dart';

class AdminApproveScreen extends StatefulWidget {
  const AdminApproveScreen({super.key});

  @override
  State<AdminApproveScreen> createState() => _AdminApproveScreenState();
}

class _AdminApproveScreenState extends State<AdminApproveScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> _allDishes = [];
  List<Map<String, dynamic>> _filteredDishes = [];
  String _selectedStatus = 'all'; // all, approved, pending

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDishes();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadDishes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('🔍 Token: $token');

    try {
      final res = await Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      )).get('/dishes/admin'); // lấy toàn bộ món ăn (đã + chưa duyệt)

      print('✅ /dishes/admin ${res.statusCode}');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      setState(() {
        _allDishes = list;
        _applyFilters();
      });
    } on DioException catch (e) {
      print('❌ API lỗi: ${e.response?.statusCode} ${e.response?.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải món ăn: ${e.response?.statusCode}')),
      );
    }
  }

  void _applyFilters() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredDishes = _allDishes.where((d) {
        final matchStatus = _selectedStatus == 'all'
            ? true
            : (_selectedStatus == 'approved'
            ? (d['isApproved'] == true)
            : (d['isApproved'] == false));

        final matchText =
            d['name'].toString().toLowerCase().contains(q) ||
                (d['description'] ?? '').toString().toLowerCase().contains(q);

        return matchStatus && matchText;
      }).toList();
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _applyFilters);
  }

  Future<void> _approveDish(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Authorization': 'Bearer $token'},
    )).put('/dishes/$id/approve');
    _loadDishes();
  }

  Future<void> _rejectDish(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Authorization': 'Bearer $token'},
    )).put('/dishes/$id/reject');
    _loadDishes();
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
                          'Duyệt món ăn',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(LucideIcons.utensils, color: Colors.white, size: 30),
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
                          hintText: 'Tìm món theo tên hoặc mô tả...',
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

          // 2️⃣ Filter chips (status)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đã duyệt', 'approved'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Chưa duyệt', 'pending'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 3️⃣ Danh sách món
          Expanded(
            child: _filteredDishes.isEmpty
                ? const Center(child: Text('Không có món ăn nào phù hợp'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredDishes.length,
              itemBuilder: (context, i) =>
                  _buildDishCard(_filteredDishes[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _selectedStatus == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedStatus = value);
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
                : AppColors.border,
          ),
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

  Widget _buildDishCard(Map<String, dynamic> d) {
    final approved = d['isApproved'] == true;

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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  d['imageUrl'] ?? '',
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(LucideIcons.imageOff, size: 32),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d['description'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildTag(
                          approved ? 'ĐÃ DUYỆT' : 'CHƯA DUYỆT',
                          approved ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _buildTag('${d['cookingTime']} phút',
                              AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (!approved)
                Column(
                  children: [
                    IconButton(
                      tooltip: 'Phê duyệt',
                      icon: const Icon(LucideIcons.checkCircle,
                          color: Colors.green),
                      onPressed: () => _approveDish(d['id']),
                    ),
                    IconButton(
                      tooltip: 'Từ chối',
                      icon: const Icon(LucideIcons.xCircle,
                          color: Colors.redAccent),
                      onPressed: () => _rejectDish(d['id']),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
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
