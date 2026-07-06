import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../main.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFirstRun = false;
  bool _isLoading = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final firstRun = await AuthService.isFirstRun();
    if (mounted) {
      setState(() {
        _isFirstRun = firstRun;
        _isLoading = false;
      });
    }

    if (!firstRun) {
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final authenticated = await AuthService.authenticate();
    if (authenticated) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (_isFirstRun) {
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
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text;

    if (_isFirstRun) {
      await StorageService.saveMasterPassword(password);
      if (mounted) _navigateToHome();
    } else {
      final isValid = await AuthService.verifyMasterPassword(password);
      if (!mounted) return;
      if (isValid) {
        _navigateToHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF64B5F6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                15.0, // Điều chỉnh độ bo góc tại đây
              ),
            ),
            content: const Text(
              '⚠️ Mật khẩu không chính xác !'
              ' Vui lòng nhập lại',
              style: TextStyle(fontSize: 18),
            ),
            //backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảo mật tài liệu'),
        actions: [
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 20),
              Switch(
                value: isDark,
                onChanged: (value) async {
                  final newMode = value ? ThemeMode.dark : ThemeMode.light;
                  themeNotifier.value = newMode;
                  await StorageService.saveThemeMode(value ? 'dark' : 'light');
                },
                activeThumbColor: Colors.blue,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Icon(
                _isFirstRun ? Icons.security : Icons.lock,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                _isFirstRun
                    ? 'Thiết lập mật khẩu chính'
                    : 'Nhập mật khẩu để truy cập',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: _isFirstRun
                      ? 'Thiết lập mật ban đầu'
                      : 'Nhập mật khẩu để truy cập',
                  //hintText: 'Thiết lập mật khẩu ban đầu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(90.0),
                  ),
                  prefixIcon: const Icon(Icons.key),
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
              const SizedBox(height: 24),
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
                  onPressed: _handleLogin,
                  child: Text(
                    _isFirstRun ? 'Bắt đầu' : 'Đăng nhập',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              if (!_isFirstRun) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint, size: 25),
                  label: const Text('Sử dụng vân tay/khuôn mặt'),
                ),
              ],
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
