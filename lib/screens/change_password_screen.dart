import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _isOldPasswordCorrect = false;

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 kí tự';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ in hoa';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ thường';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Mật khẩu phải chứa ít nhất 1 kí tự đặc biệt';
    }
    return null;
  }

  Future<void> _checkOldPassword() async {
    final oldPassword = _oldPasswordController.text;
    if (oldPassword.isEmpty) return;

    final isValid = await AuthService.verifyMasterPassword(oldPassword);
    if (!mounted) return;

    if (isValid) {
      setState(() => _isOldPasswordCorrect = true);
    } else {
      setState(() => _isOldPasswordCorrect = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF64B5F6),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: const Text(
            'mật khẩu sai, vui lòng nhập lại!',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
  }

  Future<void> _handleChange() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _newPasswordController.text;

    await StorageService.saveMasterPassword(newPassword);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF64B5F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15.0, // Điều chỉnh độ bo góc tại đây
          ),
        ),
        content: const Text('Mật khẩu đã được thay đổi'),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thay đổi mật khẩu chính')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 60,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu cũ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _checkOldPassword,
                    tooltip: 'Kiểm tra',
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOld ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                onChanged: (value) {
                  if (_isOldPasswordCorrect) {
                    setState(() => _isOldPasswordCorrect = false);
                  }
                },
              ),
              const SizedBox(height: 35),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                enabled: _isOldPasswordCorrect,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  hintText: 'Vui lòng nhập mật khẩu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: _validateNewPassword,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90.0),
                    ),
                  ),
                  onPressed: _isOldPasswordCorrect ? _handleChange : null,
                  child: const Text('Thay đổi', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
