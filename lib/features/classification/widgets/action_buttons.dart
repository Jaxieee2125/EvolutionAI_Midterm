import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final TextEditingController urlController;
  final Future<void> Function() onPickCamera;
  final Future<void> Function() onPickGallery;
  final VoidCallback onPickUrl;

  const ActionButtons({
    super.key,
    required this.urlController,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onPickUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: onPickCamera, icon: const Icon(Icons.photo_camera), label: const Text('Camera'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: onPickGallery, icon: const Icon(Icons.photo_library), label: const Text('Gallery'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: urlController, decoration: const InputDecoration(hintText: 'Dán URL ảnh', border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: onPickUrl, child: const Text('Tải')),
            ],
          ),
        ],
      ),
    );
  }
}
