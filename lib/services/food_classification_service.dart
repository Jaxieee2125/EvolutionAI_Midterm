import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class ClassificationResult {
  final String label;
  final double confidence;

  ClassificationResult(this.label, this.confidence);

  @override
  String toString() => 'ClassificationResult(label: $label, confidence: $confidence)';
}

class FoodClassificationService {
  ClassificationModel? _model;
  List<String>? _labels;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  /// Tải mô hình EfficientNet / MobileNet và nhãn
  Future<String> loadModel() async {
    try {
      _model = await PytorchLite.loadClassificationModel(
        "assets/models/efficientnet_mobile.ptl",
        300, 300, 30,
        labelPath: "assets/labels.txt",
      );

      final labelData = await rootBundle.loadString("assets/labels.txt");
      _labels = labelData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();

      _isModelLoaded = true;
      print("Model and labels loaded successfully.");
      return "Model loaded successfully";
    } catch (e) {
      print("FATAL: Error loading model or labels: $e");
      _isModelLoaded = false;
      return "Error loading model: $e";
    }
  }

  /// Softmax chuyển đổi scores thành xác suất
  List<double> _applySoftmax(List<dynamic> scores) {
    final doubleScores = scores.cast<double>();
    final maxScore = doubleScores.reduce(max);
    var sum = 0.0;
    final expScores = doubleScores.map((score) {
      final expScore = exp(score - maxScore);
      sum += expScore;
      return expScore;
    }).toList();
    return expScores.map((score) => score / sum).toList();
  }

  /// Phân loại ảnh, trả về top 5 kết quả
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

      final probabilities = _applySoftmax(scores);
      if (probabilities.length != _labels!.length) {
        print("Error: label count mismatch.");
        return [];
      }

      final results = [
        for (int i = 0; i < _labels!.length; i++)
          ClassificationResult(_labels![i], probabilities[i])
      ];

      results.sort((a, b) => b.confidence.compareTo(a.confidence));
      return results.take(5).toList();
    } catch (e) {
      print("An error occurred during classification: $e");
      return [];
    }
  }

  /// ✅ Hàm tiện ích rút gọn, dùng trực tiếp trong UI
  Future<String> predict(File image) async {
    if (!isModelLoaded) await loadModel();
    final results = await classifyImage(image);
    if (results.isEmpty) return "Không nhận diện được món ăn";
    final top = results.first;
    return "${top.label} (${(top.confidence * 100).toStringAsFixed(1)}%)";
  }
}
