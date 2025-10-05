// lib/widgets/image_display.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageUrlBytes;
  final bool isLoading;

  const ImageDisplay({
    Key? key,
    required this.imageFile,
    required this.imageUrlBytes,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 250,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(strokeWidth: 3, color: Colors.teal));
    }

    Widget imageWidget;
    if (imageFile != null) {
      imageWidget = Image.file(imageFile!, fit: BoxFit.cover);
    } else if (imageUrlBytes != null) {
      imageWidget = Image.memory(imageUrlBytes!, fit: BoxFit.cover);
    } else {
      // Placeholder
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 60, color: Colors.grey.shade400),
            SizedBox(height: 10),
            Text(
              'Chọn ảnh để phân loại',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Áp dụng bo góc cho ảnh
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: imageWidget,
    );
  }
}