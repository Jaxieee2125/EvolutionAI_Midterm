import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/food_classification_service.dart';
import '../services/image_service.dart';
import '../widgets/action_buttons.dart';
import '../widgets/classification_result_card.dart';
import '../widgets/image_display.dart';

class ClassificationPage extends StatefulWidget {
  const ClassificationPage({super.key});
  @override
  State<ClassificationPage> createState() => _ClassificationPageState();
}

class _ClassificationPageState extends State<ClassificationPage> {
  final _imageService = ImageService();
  final _classificationService = FoodClassificationService();
  final _urlController = TextEditingController();

  File? _imageFile;
  Uint8List? _imageUrlBytes;
  List<ClassificationResult>? _results;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classificationService.loadModel();
  }

  Future<void> _classifyImage(dynamic input) async {
    if (input == null) return;
    if (!_classificationService.isModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Model chưa sẵn sàng')));
      return;
    }
    setState(() {
      _isLoading = true;
      _results = null;
      if (input is File) { _imageFile = input; _imageUrlBytes = null; }
      else if (input is Uint8List) { _imageUrlBytes = input; _imageFile = null; }
    });
    final results = await _classificationService.classifyImage(input);
    setState(() { _results = results; _isLoading = false; });
  }

  Future<void> _onPickUrl() async {
    if (_urlController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    final bytes = await _imageService.getImageFromUrl(_urlController.text);
    if (bytes != null) { await _classifyImage(bytes); }
    else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tải ảnh từ URL'))); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Evolution AI - Phân loại món ăn', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageDisplay(imageFile: _imageFile, imageUrlBytes: _imageUrlBytes, isLoading: _isLoading && _results == null),
            if (_results != null && !_isLoading)
              ListView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                itemCount: _results!.length,
                itemBuilder: (_, i) => ClassificationResultCard(result: _results![i]),
              ),
            const SizedBox(height: 30),
            ActionButtons(
              urlController: _urlController,
              onPickCamera: () async => _classifyImage(await _imageService.getImageFromCamera()),
              onPickGallery: () async => _classifyImage(await _imageService.getImageFromGallery()),
              onPickUrl: _onPickUrl,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
