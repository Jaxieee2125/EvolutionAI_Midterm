import 'dart:typed_data';
import 'dart:io';

class ClassificationResult {
  final String label;
  final double score;
  ClassificationResult(this.label, this.score);
}

class FoodClassificationService {
  bool _loaded = false;
  bool get isModelLoaded => _loaded;

  Future<void> loadModel() async {
    // TODO: load model thực tế
    _loaded = true;
  }

  Future<List<ClassificationResult>> classifyImage(dynamic input) async {
    // input: File hoặc Uint8List
    // TODO: thay bằng suy luận thực tế
    return [
      ClassificationResult('pho_bo', 0.83),
      ClassificationResult('bun_cha', 0.11),
      ClassificationResult('banh_mi', 0.06),
    ];
  }
}
