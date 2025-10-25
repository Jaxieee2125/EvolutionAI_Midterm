import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageUrlBytes;
  final bool isLoading;
  const ImageDisplay({super.key, this.imageFile, this.imageUrlBytes, this.isLoading=false});

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isLoading) {
      child = const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
    } else if (imageFile != null) {
      child = Image.file(imageFile!, height: 220, fit: BoxFit.cover);
    } else if (imageUrlBytes != null) {
      child = Image.memory(imageUrlBytes!, height: 220, fit: BoxFit.cover);
    } else {
      child = Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
        ),
        child: const Text('Chọn ảnh từ Camera / Gallery / URL'),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
    );
  }
}
