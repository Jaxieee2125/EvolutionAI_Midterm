import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../services/image_service.dart';
import '../../../services/food_classification_service.dart';
import '../../../ui/theme/colors.dart';

class AiPredictScreen extends StatefulWidget {
  const AiPredictScreen({super.key});

  @override
  State<AiPredictScreen> createState() => _AiPredictScreenState();
}

class _AiPredictScreenState extends State<AiPredictScreen> {
  File? _image;
  Uint8List? _urlBytes;
  List<ClassificationResult> _results = [];
  bool _loading = false;
  final _urlController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImageService.pickImage(source);
    if (picked == null) return;
    setState(() {
      _image = picked;
      _urlBytes = null;
    });
    await _predict(picked);
  }

  Future<void> _predict(dynamic imageInput) async {
    setState(() {
      _loading = true;
      _results = [];
    });

    final classifier = FoodClassificationService();
    if (!classifier.isModelLoaded) await classifier.loadModel();

    final results = await classifier.classifyImage(imageInput);
    if (!mounted) return;

    setState(() {
      _results = results.take(10).toList();
      _loading = false;
    });
  }

  Future<void> _predictFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _image = null;
      _urlBytes = null;
      _loading = true;
      _results = [];
    });

    final imgBytes = await ImageService().getImageFromUrl(url);
    if (imgBytes == null) {
      setState(() => _loading = false);
      return;
    }

    // 🔧 Lưu ảnh tải về thành file tạm (fix lỗi treo)
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/predict_temp.jpg');
    await file.writeAsBytes(imgBytes);

    setState(() => _urlBytes = imgBytes);
    await _predict(file);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.header),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nhận diện món ăn 🍽️',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // --- Ô nhập link ảnh ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.link, color: Colors.white70),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Dán link ảnh tại đây...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _predictFromUrl,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- Ảnh hiển thị ---
                Expanded(
                  child: Center(
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : _image != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    )
                        : _urlBytes != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(_urlBytes!, fit: BoxFit.cover),
                    )
                        : const Text('Chọn hoặc dán link ảnh để bắt đầu',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ),

                // --- Danh sách kết quả ---
                if (_results.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top 5 dự đoán:',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 8),
                        ..._results.map((r) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(r.label,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14)),
                              Text(
                                '${(r.confidence * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // --- Nút chọn ảnh ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    _ActionButton(
                      icon: Icons.photo,
                      label: 'Thư viện',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
