import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/credential_model.dart';
import '../services/storage_service.dart';

class AddCredentialScreen extends StatefulWidget {
  final CredentialModel? credential;

  const AddCredentialScreen({super.key, this.credential});

  @override
  State<AddCredentialScreen> createState() => _AddCredentialScreenState();
}

class _AddCredentialScreenState extends State<AddCredentialScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serviceController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _notesController;
  bool _obscurePassword = true;
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
    _serviceController = TextEditingController(
      text: widget.credential?.serviceName,
    );
    _usernameController = TextEditingController(
      text: widget.credential?.username,
    );
    _passwordController = TextEditingController(
      text: widget.credential?.password,
    );
    _notesController = TextEditingController(text: widget.credential?.notes);

    if (widget.credential?.colorValue != null) {
      _selectedColor = Color(widget.credential!.colorValue!);
    }

    _serviceController.addListener(() => setState(() {}));
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _notesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    return null;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final credential = CredentialModel(
        id: widget.credential?.id ?? const Uuid().v4(),
        serviceName: _serviceController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        notes: _notesController.text,
        createdAt: widget.credential?.createdAt ?? DateTime.now(),
        colorValue: _selectedColor?.toARGB32(),
      );

      await StorageService.saveCredential(credential);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF64B5F6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            content: Text(
              widget.credential != null
                  ? 'Đã cập nhật thay đổi thành công'
                  : 'Đã lưu tài khoản mới thành công',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.credential != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorsToUse = isDark ? _availableColorsDark : _availableColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa tài khoản' : 'Thêm tài khoản mới'),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _serviceController,
                  decoration: InputDecoration(
                    labelText: 'Tên dịch vụ (Gmail, Facebook...)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(90.0),
                    ),
                    prefixIcon: _serviceController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _serviceController.clear(),
                          )
                        : null,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập tên dịch vụ' : null,
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(90.0),
                    ),
                    prefixIcon: _usernameController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _usernameController.clear(),
                          )
                        : null,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(90.0),
                    ),
                    prefixIcon: _passwordController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _passwordController.clear(),
                          )
                        : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    prefixIcon: _notesController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _notesController.clear(),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Chọn màu sắc đành dấu:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
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
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 35),
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
                      isEditing ? 'Cập nhật thay đổi' : 'Lưu bảo mật',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
