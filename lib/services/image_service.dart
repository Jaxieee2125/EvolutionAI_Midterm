import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Lấy ảnh từ camera hoặc thư viện (tự chọn theo source)
  static Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }

  /// Lấy ảnh từ thư viện
  Future<File?> getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }

  /// Lấy ảnh từ camera
  Future<File?> getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }

  /// Tải ảnh từ URL
  Future<Uint8List?> getImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (e) {
      print("Error fetching image from URL: $e");
    }
    return null;
  }
}
