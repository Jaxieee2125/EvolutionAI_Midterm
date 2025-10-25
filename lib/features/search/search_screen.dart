// lib/features/search/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/dish.dart';
import '../../data/models/category.dart';
import '../../services/dish_service.dart';
import '../../services/category_service.dart';
import '../../ui/theme/colors.dart';
import '../home/widgets/dish_card.dart';

class SearchScreen extends StatefulWidget {
  final int? initialCategoryId;

  const SearchScreen({super.key, this.initialCategoryId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

// THÊM: AutomaticKeepAliveClientMixin để giữ trạng thái
class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Category> _cats = [];
  int? _selectedCatId;
  Future<List<Dish>>? _future;

  @override
  void initState() {
    super.initState();
    _selectedCatId = widget.initialCategoryId;
    _loadCats();
    _triggerSearch();
    _controller.addListener(_onChanged);
  }

  // THÊM: Bắt buộc phải có khi dùng mixin
  @override
  bool get wantKeepAlive => true;

  void _loadCats() async {
    final cats = await CategoryService.fetchCategories();
    if (!mounted) return;
    setState(() => _cats = cats);
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _triggerSearch);
  }

  void _triggerSearch() {
    setState(() {
      _future = DishService.search(
        q: _controller.text.trim(),
        categoryId: _selectedCatId,
        page: 1,
        size: 30,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // THÊM: Gọi super.build(context) khi dùng mixin
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPop = Navigator.canPop(context);

    final chipBg = isDark ? AppColors.darkMuted : AppColors.muted;
    final chipBorder = isDark ? AppColors.darkBorder : AppColors.border;
    final chipText = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    final chipSelBg = AppColors.primary.withOpacity(0.15);
    final chipSelBd = AppColors.primary.withOpacity(0.35);
    final chipSelText = isDark ? AppColors.darkForeground : AppColors.foreground;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
        children: [
          // 1. Header + Search box (Cố định)
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.header),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (canPop)
                          BackButton(color: Colors.white, onPressed: () => Navigator.pop(context))
                        else
                          const SizedBox(width: 8),
                        const Text(
                          'Tìm món ăn',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Nhập tên món, nguyên liệu...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Chips danh mục (Cố định)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _Chip(
                    label: 'Tất cả',
                    selected: _selectedCatId == null,
                    colors: _ChipColors(
                      bg: chipBg, bd: chipBorder, text: chipText,
                      selBg: chipSelBg, selBd: chipSelBd, selText: chipSelText,
                    ),
                    onTap: () {
                      setState(() => _selectedCatId = null);
                      _triggerSearch();
                    },
                  ),
                  const SizedBox(width: 8),
                  ..._cats.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Chip(
                      label: c.name,
                      emoji: c.icon,
                      selected: _selectedCatId == c.id,
                      colors: _ChipColors(
                        bg: chipBg, bd: chipBorder, text: chipText,
                        selBg: chipSelBg, selBd: chipSelBd, selText: chipSelText,
                      ),
                      onTap: () {
                        setState(() => _selectedCatId = c.id);
                        _triggerSearch();
                      },
                    ),
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. Kết quả (Cuộn được)
          Expanded(
            child: FutureBuilder<List<Dish>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Lỗi tìm kiếm'));
                }
                final dishes = snapshot.data ?? [];
                if (dishes.isEmpty) {
                  return const Center(child: Text('Không tìm thấy món phù hợp'));
                }
                return ListView.builder(
                  // THÊM: PageStorageKey để lưu vị trí cuộn
                  key: const PageStorageKey<String>('searchScreenScroll'),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dishes.length,
                  itemBuilder: (context, i) => DishCard(dish: dishes[i], onTap: () {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipColors {
  final Color bg, bd, text, selBg, selBd, selText;
  _ChipColors(
      {required this.bg,
        required this.bd,
        required this.text,
        required this.selBg,
        required this.selBd,
        required this.selText});
}

class _Chip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool selected;
  final _ChipColors colors;
  final VoidCallback onTap;
  const _Chip(
      {super.key,
        required this.label,
        this.emoji,
        required this.selected,
        required this.colors,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? colors.selBg : colors.bg;
    final bd = selected ? colors.selBd : colors.bd;
    final tx = selected ? colors.selText : colors.text;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: bd),
        ),
        child: Row(
          children: [
            if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 14)),
            if (emoji != null) const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tx)),
          ],
        ),
      ),
    );
  }
}