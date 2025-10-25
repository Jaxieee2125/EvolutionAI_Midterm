import 'package:flutter/material.dart';
import '../../data/models/dish.dart';
import '../../services/dish_service.dart';
import '../../ui/theme/colors.dart';
import '../home/widgets/dish_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<Dish>> _futureFavorites;

  @override
  void initState() {
    super.initState();
    _futureFavorites = DishService.fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.header),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Text(
                  'Món ăn yêu thích ❤️',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // --- Danh sách món yêu thích ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkMuted.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: FutureBuilder<List<Dish>>(
                    future: _futureFavorites,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child:
                          CircularProgressIndicator(color: AppColors.primary),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Không thể tải danh sách yêu thích',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      final dishes = snapshot.data ?? [];

                      if (dishes.isEmpty) {
                        return const Center(
                          child: Text(
                            'Chưa có món yêu thích nào',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: dishes.length,
                        itemBuilder: (context, index) =>
                            DishCard(dish: dishes[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}