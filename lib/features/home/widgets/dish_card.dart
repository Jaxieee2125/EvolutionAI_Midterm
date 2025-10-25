import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../data/models/dish.dart';
import '../../../ui/theme/colors.dart';
import '../../dish_detail/dish_detail_screen.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback? onTap;

  const DishCard({super.key, required this.dish, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final bgColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // khoảng cách giữa các card
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withOpacity(0.15),
          highlightColor: Colors.transparent,
          onTap: onTap ??
                  () {
                print('➡️ Mở chi tiết món: ${dish.name} (${dish.id})');
                GoRouter.of(context).push('/dish/${dish.id}');
              },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Hero(
                    tag: 'dish_${dish.id}',
                    child: SizedBox(width: 100, height: 100, child: _buildDishImage()),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(LucideIcons.star, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              dish.ratingAvg.toStringAsFixed(1),
                              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13),
                            ),
                            const SizedBox(width: 12),
                            const Icon(LucideIcons.timer, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${dish.cookingTime ?? 0} phút',
                              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDishImage() {
    final imageUrl = dish.imageUrl;

    // Nếu rỗng hoặc không bắt đầu bằng http => hiển thị icon mặc định
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        !imageUrl.startsWith('http')) {
      return const Center(
        child: Icon(
          LucideIcons.imageOff,
          size: 40,
          color: AppColors.textMuted,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(LucideIcons.imageOff, size: 40, color: AppColors.textMuted),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        );
      },
    );
  }
}
