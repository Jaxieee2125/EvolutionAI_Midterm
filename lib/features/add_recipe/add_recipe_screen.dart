import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/image_service.dart';
import '../../services/dish_service.dart';
import '../../services/category_service.dart';
import '../../data/models/category.dart';
import '../../ui/theme/colors.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: "30");
  final _linkCtrl = TextEditingController();
  final List<TextEditingController> _ingredients = [TextEditingController()];
  final List<TextEditingController> _steps = [TextEditingController()];

  File? _image;
  Uint8List? _urlBytes;
  bool _loading = false;

  int? _selectedCategoryId;
  String _selectedDifficulty = "Medium";
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryService.fetchCategories();
      if (!mounted) return;
      setState(() => _categories = cats);
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImageService.pickImage(source);
    if (picked == null) return;
    setState(() {
      _image = picked;
      _urlBytes = null;
    });
  }

  Future<void> _loadImageFromUrl() async {
    final url = _linkCtrl.text.trim();
    if (url.isEmpty) return;
    final bytes = await ImageService().getImageFromUrl(url);
    if (bytes == null) return;
    final tmp = await getTemporaryDirectory();
    final file = File('${tmp.path}/recipe_upload.jpg');
    await file.writeAsBytes(bytes);
    setState(() {
      _image = file;
      _urlBytes = bytes;
    });
  }

  void _addIngredient() => setState(() => _ingredients.add(TextEditingController()));
  void _addStep() => setState(() => _steps.add(TextEditingController()));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _image == null ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin và chọn ảnh')),
      );
      return;
    }

    setState(() => _loading = true);

    final ingredients =
    _ingredients.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();
    final steps =
    _steps.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();

    final ok = await DishService.createDish(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      difficulty: _selectedDifficulty,
      cookingTime: int.tryParse(_timeCtrl.text.trim()) ?? 30,
      ingredients: ingredients,
      steps: steps,
      imageFile: _image!,
      categoryId: _selectedCategoryId!,
    );

    setState(() => _loading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm món ăn mới!'), backgroundColor: Colors.green),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (context.canPop()) context.pop(); else context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.header),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thêm công thức món ăn 🍳',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown danh mục
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    dropdownColor: isDark ? AppColors.darkMuted : Colors.white,
                    decoration: _fieldDecoration('Chọn danh mục'),
                    iconEnabledColor: Colors.white,
                    items: _categories
                        .map((c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.name,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black)),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
                  const SizedBox(height: 16),

                  // Độ khó & Thời gian
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDifficulty,
                          dropdownColor: isDark ? AppColors.darkMuted : Colors.white,
                          decoration: _fieldDecoration('Độ khó'),
                          items: const [
                            DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                            DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                          ],
                          onChanged: (v) => setState(() => _selectedDifficulty = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InputField(
                          controller: _timeCtrl,
                          label: 'Thời gian nấu (phút)',
                          validator: (v) =>
                          v!.isEmpty ? 'Nhập thời gian nấu' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tên món
                  _InputField(
                    controller: _nameCtrl,
                    label: 'Tên món ăn',
                    validator: (v) => v!.isEmpty ? 'Nhập tên món' : null,
                  ),
                  const SizedBox(height: 12),

                  // Mô tả
                  _InputField(
                    controller: _descCtrl,
                    label: 'Mô tả món ăn',
                    validator: (_) => null,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Ảnh
                  Center(
                    child: _image != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_image!, height: 180, fit: BoxFit.cover),
                    )
                        : const Text('Chưa chọn ảnh',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionBtn(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          onTap: () => _pickImage(ImageSource.camera)),
                      _ActionBtn(
                          icon: Icons.photo,
                          label: 'Thư viện',
                          onTap: () => _pickImage(ImageSource.gallery)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dán link ảnh
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _linkCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Hoặc dán link ảnh...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.link, color: Colors.white),
                          onPressed: _loadImageFromUrl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nguyên liệu
                  const Text('Nguyên liệu',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  ..._ingredients.map((ctrl) => _InputField(controller: ctrl, label: '')),
                  TextButton.icon(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Thêm nguyên liệu',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),

                  // Các bước
                  const Text('Các bước nấu',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  ..._steps.map((ctrl) => _InputField(controller: ctrl, label: '')),
                  TextButton.icon(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Thêm bước nấu',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 24),

                  // Nút lưu
                  Center(
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                      ),
                      child: const Text('Lưu công thức',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
    );
  }
}

// ---------------------------- COMPONENTS ----------------------------

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;
  const _InputField({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
