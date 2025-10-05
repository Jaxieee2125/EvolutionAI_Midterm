// lib/main.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:evolution_ai/services/food_classification_service.dart';
import 'package:evolution_ai/services/image_service.dart';
import 'package:flutter/material.dart';
import 'package:evolution_ai/widgets/action_buttons.dart';
import 'package:evolution_ai/widgets/classification_result_card.dart';
import 'package:evolution_ai/widgets/image_display.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evolution AI',
      debugShowCheckedModeBanner: false, // Tắt banner DEBUG
      theme: ThemeData(
        primarySwatch: Colors.teal, // Chọn một màu chủ đạo bạn thích
        scaffoldBackgroundColor: Color(0xFFF5F5F7), // Màu nền hơi xám cho đỡ chói
        fontFamily: 'Roboto', // Bạn có thể thêm font custom nếu muốn
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // Màu nền nút
            foregroundColor: Colors.white, // Màu chữ nút
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImageService _imageService = ImageService();
  final FoodClassificationService _classificationService = FoodClassificationService();
  final TextEditingController _urlController = TextEditingController();

  File? _imageFile;
  Uint8List? _imageUrlBytes;
  List<ClassificationResult>? _results;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Tải model một cách âm thầm khi khởi động
    _classificationService.loadModel();
  }

  void _classifyImage(dynamic imageInput) async {
    if (imageInput == null) return;
    if (!_classificationService.isModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Model chưa sẵn sàng, vui lòng đợi giây lát."),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
      _results = null;
      if (imageInput is File) {
        _imageFile = imageInput;
        _imageUrlBytes = null;
      } else if (imageInput is Uint8List) {
        _imageUrlBytes = imageInput;
        _imageFile = null;
      }
    });

    final results = await _classificationService.classifyImage(imageInput);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  void _onPickUrl() async {
    if (_urlController.text.isNotEmpty) {
      // Ẩn bàn phím
      FocusScope.of(context).unfocus();
      final imageBytes = await _imageService.getImageFromUrl(_urlController.text);
      if (imageBytes != null) {
        _classifyImage(imageBytes);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Không thể tải ảnh từ URL')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Evolution AI - Phân loại món ăn',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              ImageDisplay(
                imageFile: _imageFile,
                imageUrlBytes: _imageUrlBytes,
                isLoading: _isLoading && _results == null, // Chỉ loading khi đang xử lý, chưa có kết quả
              ),
              if (_results != null && !_isLoading)
              // Dùng ListView.builder hiệu quả hơn
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _results!.length,
                  itemBuilder: (context, index) {
                    return ClassificationResultCard(result: _results![index]);
                  },
                ),
              SizedBox(height: 30),
              ActionButtons(
                urlController: _urlController,
                onPickCamera: () async => _classifyImage(await _imageService.getImageFromCamera()),
                onPickGallery: () async => _classifyImage(await _imageService.getImageFromGallery()),
                onPickUrl: _onPickUrl,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}