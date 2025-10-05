// lib/services/food_classification_service.dart
import 'dart:io';
import 'dart:math'; // Cần import thư viện math để dùng hàm exp()
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class ClassificationResult {
  final String label;
  final double confidence;

  ClassificationResult(this.label, this.confidence);

  @override
  String toString() {
    return 'ClassificationResult(label: $label, confidence: $confidence)';
  }
}

class FoodClassificationService {
  ClassificationModel? _model;
  List<String>? _labels;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  Future<String> loadModel() async {
    try {
      _model = await PytorchLite.loadClassificationModel(
          "assets/models/efficientnet_mobile.ptl", 300, 300, 30,
          labelPath: "assets/labels.txt");

      final labelData = await rootBundle.loadString("assets/labels.txt");
      _labels = labelData.split('\n').map((label) => label.trim()).where((label) => label.isNotEmpty).toList();

      _isModelLoaded = true;
      print("Model and labels loaded successfully.");
      return "Model loaded successfully";
    } catch (e) {
      print("FATAL: Error loading model or labels: $e");
      _isModelLoaded = false;
      return "Error loading model: $e";
    }
  }

  // === HÀM MỚI ĐỂ ÁP DỤNG SOFTMAX ===
  List<double> _applySoftmax(List<dynamic> scores) {
    final doubleScores = scores.cast<double>();

    // Tìm giá trị lớn nhất để ổn định tính toán (tránh tràn số)
    final maxScore = doubleScores.reduce(max);

    // Tính e^x cho mỗi điểm và tính tổng
    var sum = 0.0;
    final expScores = doubleScores.map((score) {
      final expScore = exp(score - maxScore);
      sum += expScore;
      return expScore;
    }).toList();

    // Chuẩn hóa để có được xác suất
    return expScores.map((score) => score / sum).toList();
  }

  Future<List<ClassificationResult>> classifyImage(dynamic imageInput) async {
    if (!_isModelLoaded || _model == null || _labels == null) {
      print("Model or labels are not loaded yet.");
      return [];
    }

    try {
      Uint8List imageBytes;

      if (imageInput is File) {
        imageBytes = await imageInput.readAsBytes();
      } else if (imageInput is Uint8List) {
        imageBytes = imageInput;
      } else {
        throw ArgumentError("Input must be a File or Uint8List");
      }

      List? scores = await _model?.getImagePredictionList(imageBytes);

      if (scores == null) {
        print("Model returned null scores.");
        return [];
      }

      // === BƯỚC THAY ĐỔI QUAN TRỌNG ===
      // Áp dụng softmax để chuyển đổi scores thành probabilities
      final probabilities = _applySoftmax(scores);

      if (probabilities.length != _labels!.length) {
        print("Error: Number of probabilities (${probabilities.length}) does not match number of labels (${_labels!.length}).");
        return [];
      }

      List<ClassificationResult> results = [];
      for (int i = 0; i < _labels!.length; i++) {
        // Sử dụng giá trị probabilities đã được chuẩn hóa
        results.add(ClassificationResult(_labels![i], probabilities[i]));
      }

      results.sort((a, b) => b.confidence.compareTo(a.confidence));

      return results.take(5).toList();

    } catch (e) {
      print("An error occurred during classification: $e");
      return [];
    }
  }
}