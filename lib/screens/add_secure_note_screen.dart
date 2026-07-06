import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/secure_note_model.dart';
import '../services/storage_service.dart';

class AddSecureNoteScreen extends StatefulWidget {
  final SecureNoteModel? note;

  const AddSecureNoteScreen({super.key, this.note});

  @override
  State<AddSecureNoteScreen> createState() => _AddSecureNoteScreenState();
}

class _AddSecureNoteScreenState extends State<AddSecureNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Color? _selectedColor;

  final List<Color> _availableColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.red.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
    Colors.amber.shade100,
    Colors.pink.shade100,
  ];

  final List<Color> _availableColorsDark = [
    Colors.blue.shade900.withValues(alpha: 0.5),
    Colors.green.shade900.withValues(alpha: 0.5),
    Colors.red.shade900.withValues(alpha: 0.5),
    Colors.orange.shade900.withValues(alpha: 0.5),
    Colors.purple.shade900.withValues(alpha: 0.5),
    Colors.teal.shade900.withValues(alpha: 0.5),
    Colors.amber.shade900.withValues(alpha: 0.5),
    Colors.pink.shade900.withValues(alpha: 0.5),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);

    if (widget.note?.colorValue != null) {
      _selectedColor = Color(widget.note!.colorValue!);
    }

    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final note = SecureNoteModel(
        id: widget.note?.id ?? const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        colorValue: _selectedColor?.toARGB32(),
      );

      await StorageService.saveSecureNote(note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF64B5F6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            content: Text(
              widget.note != null
                  ? 'Đã cập nhật ghi chú thành công'
                  : 'Đã lưu ghi chú mới thành công',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorsToUse = isDark ? _availableColorsDark : _availableColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú bảo mật'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 50,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề ghi chú',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                  ),
                  prefixIcon: _titleController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _titleController.clear(),
                        )
                      : null,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Chọn màu sắc đành dấu:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: colorsToUse.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isNoColor = _selectedColor == null;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = null),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isNoColor
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                              width: isNoColor ? 3 : 1,
                            ),
                          ),
                          child: Icon(
                            Icons.block,
                            size: 20,
                            color: isNoColor ? Colors.blue : Colors.grey,
                          ),
                        ),
                      );
                    }

                    final color = colorsToUse[index - 1];
                    final isSelected =
                        _selectedColor?.toARGB32() == color.toARGB32();
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.blue,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: 'Nội dung ghi chú',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập nội dung' : null,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90.0),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Cập nhật thay đổi' : 'Lưu ghi chú',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
