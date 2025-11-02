// lib/ui/components/admin_tab_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class AdminTabBarShell extends StatefulWidget {
  final Widget child;
  const AdminTabBarShell({super.key, required this.child});

  @override
  State<AdminTabBarShell> createState() => _AdminTabBarShellState();
}

class _AdminTabBarShellState extends State<AdminTabBarShell> {
  final tabs = ['/admin', '/admin/approve'];
  final icons = [Icons.dashboard_rounded, Icons.check_circle_rounded];

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
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Bảng điều khiển',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_rounded),
                label: 'Duyệt món',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
