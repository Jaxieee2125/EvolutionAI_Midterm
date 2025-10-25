import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/dish.dart';
import '../../services/dish_service.dart';
import '../../ui/theme/colors.dart';

class DishDetailScreen extends StatefulWidget {
  final int dishId;

  const DishDetailScreen({super.key, required this.dishId});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  late Future<Dish> _futureDish;
  bool _isFavorite = false;
  bool _isLoaded = false; // để tránh gán lại _isFavorite mỗi lần build

  @override
  void initState() {
    super.initState();
    _futureDish = DishService.getDishById(widget.dishId).then((dish) {
      // ✅ chỉ gán một lần sau khi tải dữ liệu
      _isFavorite = dish.isFavorite ?? false;
      _isLoaded = true;
      return dish;
    });
  }

  Future<void> _toggleFavorite() async {
    try {
      final ok = await DishService.toggleFavorite(widget.dishId);
      if (!mounted) return;
      if (ok) {
        setState(() => _isFavorite = !_isFavorite);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể thay đổi yêu thích')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.header),
        child: SafeArea(
          child: FutureBuilder<Dish>(
            future: _futureDish,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                    child: Text('Không thể tải chi tiết món ăn',
                        style: TextStyle(color: Colors.white70)));
              }

              final dish = snapshot.data!;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header: Back + Favorite ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                            IconButton(
                              onPressed: _toggleFavorite,
                              icon: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // --- Ảnh món ăn ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            dish.imageUrl ?? '',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 220,
                              color: Colors.black26,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.white70, size: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Tên + thông tin ---
                        Text(
                          dish.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(LucideIcons.timer,
                                size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text('${dish.cookingTime ?? 0} phút',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(width: 16),
                            const Icon(LucideIcons.gauge,
                                size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(dish.difficulty ?? 'Không rõ',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // --- Nguyên liệu ---
                        Card(
                          color: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nguyên liệu 🥕',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (dish.ingredients == null ||
                                    dish.ingredients!.isEmpty)
                                  const Text('Không có dữ liệu',
                                      style:
                                      TextStyle(color: Colors.white70))
                                else
                                  ...dish.ingredients!.map((ing) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16)),
                                        Expanded(
                                          child: Text(
                                            '${ing.name} ${ing.quantity > 0 ? '(${ing.quantity}${ing.unit})' : ''}',
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Các bước nấu ---
                        Card(
                          color: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Các bước nấu 🍳',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (dish.steps == null || dish.steps!.isEmpty)
                                  const Text('Không có dữ liệu',
                                      style:
                                      TextStyle(color: Colors.white70))
                                else
                                  ...dish.steps!.map((s) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text('${s.order}. ',
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontWeight:
                                                FontWeight.bold)),
                                        Expanded(
                                          child: Text(
                                            s.instruction,
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
