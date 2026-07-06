import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _handleFactoryReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận khôi phục'),
        content: const Text(
          'Hành động này sẽ xóa toàn bộ dữ liệu (mật khẩu, ghi chú, ảnh) và không thể hoàn tác. Bạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tiếp tục', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        return const _PasswordVerificationDialog();
      },
    );

    if (password == null || password.isEmpty || !context.mounted) return;

    final isValid = await AuthService.verifyMasterPassword(password);
    if (!context.mounted) return;

    if (isValid) {
      await StorageService.clearAll();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF64B5F6),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: const Text(
            'Đã khôi phục cài đặt gốc thành công',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF64B5F6),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: const Text(
            'Mật khẩu không chính xác!',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 50),
        children: [
          ListTile(
            leading: const Icon(Icons.password, color: Colors.blue),
            title: const Text('Thay đổi mật khẩu chính'),
            subtitle: Text(
              'Cập nhật mật khẩu truy cập ứng dụng',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.red),
            title: const Text('Khôi phục cài đặt gốc'),
            subtitle: Text(
              'Xóa toàn bộ dữ liệu ứng dụng',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _handleFactoryReset(context),
          ),
        ],
      ),
    );
  }
}

class _PasswordVerificationDialog extends StatefulWidget {
  const _PasswordVerificationDialog();

  @override
  State<_PasswordVerificationDialog> createState() =>
      __PasswordVerificationDialogState();
}

class __PasswordVerificationDialogState
    extends State<_PasswordVerificationDialog> {
  final _controller = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác thực mật khẩu'),
      content: TextField(
        controller: _controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          labelText: 'Nhập mật khẩu chính',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          prefixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _controller.clear(),
            tooltip: 'Xóa',
          ),
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
