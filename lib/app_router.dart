import 'package:evolution_ai/ui/components/admin_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/admin/admin_approve_screen.dart';
import 'features/admin/home_screen.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/auth/auth_notifier.dart';

import 'features/favorites/favorites_screen.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/ai_predict/ai_predict_screen.dart';
import 'features/add_recipe/add_recipe_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/dish_detail/dish_detail_screen.dart';
import 'ui/components/custom_tab_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  final authNotifier = AuthNotifier(authBloc);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authNotifier, // ✅ GoRouter theo dõi bloc
    initialLocation: '/login',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final role = prefs.getString('role');
      print('🔍 token: $token, role: $role');
      final isLoggedIn = token != null;
      final isAuthRoute = state.uri.path == '/login' || state.uri.path == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';

      if (isLoggedIn && isAuthRoute) {
        // ✅ Kiểm tra role để điều hướng đúng
        if (role == 'admin') return '/admin';
        return '/home';
      }

      // Chặn user thường truy cập trang admin
      if (state.uri.path == '/admin' && role != 'admin') return '/home';

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => AdminTabBarShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/approve',
            builder: (_, __) => const AdminApproveScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/dish/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DishDetailScreen(dishId: id);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => CustomTabBarShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
          GoRoute(path: '/ai_predict', builder: (_, __) => const AiPredictScreen()),
          GoRoute(path: '/add_recipe', builder: (_, __) => const AddRecipeScreen()),
          GoRoute(path: '/favorites', builder: (_, __) => const FavoriteScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
}
