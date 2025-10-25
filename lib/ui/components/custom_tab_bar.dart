import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class CustomTabBarShell extends StatefulWidget {
  final Widget child;
  const CustomTabBarShell({super.key, required this.child});

  @override
  State<CustomTabBarShell> createState() => _CustomTabBarShellState();
}

class _CustomTabBarShellState extends State<CustomTabBarShell> {
  final tabs = ['/home','/search','/ai_predict','/add_recipe','/favorites','/profile'];
  final icons = [Icons.home, Icons.search, Icons.camera_alt, Icons.add_circle, Icons.favorite, Icons.person];

  int _routeToIndex(String loc) {
    for (int i = 0; i < tabs.length; i++) {
      if (loc.startsWith(tabs[i])) return i;
    }
    return 0;
  }

  void _onTap(int i) => context.go(tabs[i]);

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final index = _routeToIndex(loc);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(gradient: AppGradients.header),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: _onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedIconTheme: const IconThemeData(size: 26),
            unselectedIconTheme: const IconThemeData(size: 22),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: List.generate(
              tabs.length,
                  (i) => BottomNavigationBarItem(icon: Icon(icons[i]), label: ''),
            ),
          ),
        ),
      ),
    );
  }
}
