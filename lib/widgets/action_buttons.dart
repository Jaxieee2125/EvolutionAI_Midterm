// lib/widgets/action_buttons.dart
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onPickUrl;
  final TextEditingController urlController;

  const ActionButtons({
    Key? key,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onPickUrl,
    required this.urlController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.photo_library),
                  onPressed: onPickGallery,
                  label: Text('Thư viện'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  onPressed: onPickCamera,
                  label: Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    side: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            controller: urlController,
            decoration: InputDecoration(
              labelText: 'Hoặc dán URL hình ảnh vào đây',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: Colors.teal),
                onPressed: onPickUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}