import 'package:flutter/material.dart';
import '../../ui/theme/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.header,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Hồ sơ cá nhân'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Thông tin cá nhân sẽ hiển thị ở đây',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
