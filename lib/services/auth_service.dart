import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

class AuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      if (!await canCheckBiometrics()) return false;

      return await _auth.authenticate(
        localizedReason: 'Vui lòng xác thực để truy cập mật khẩu của bạn',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  static Future<bool> verifyMasterPassword(String password) async {
    final storedPassword = await StorageService.getMasterPassword();
    return storedPassword == password;
  }

  static Future<bool> isFirstRun() async {
    final storedPassword = await StorageService.getMasterPassword();
    return storedPassword == null;
  }
}
