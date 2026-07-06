import 'dart:typed_data';
import 'package:cryptography/cryptography.dart' as crypto_lib;
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final _algorithm = crypto_lib.AesGcm.with256bits();

  // Generate a derived key from the master password
  static Future<crypto_lib.SecretKey> deriveKey(String password) async {
    final salt = Uint8List.fromList(sha256.convert(password.codeUnits).bytes);
    final pbkdf2 = crypto_lib.Pbkdf2(
      macAlgorithm: crypto_lib.Hmac.sha256(),
      iterations: 10000,
      bits: 256,
    );
    return await pbkdf2.deriveKey(
      secretKey: crypto_lib.SecretKey(password.codeUnits),
      nonce: salt,
    );
  }

  static Future<Uint8List> encryptData(
    Uint8List data,
    crypto_lib.SecretKey key,
  ) async {
    final secretBox = await _algorithm.encrypt(data, secretKey: key);
    return secretBox.concatenation();
  }

  static Future<Uint8List> decryptData(
    Uint8List encryptedData,
    crypto_lib.SecretKey key,
  ) async {
    final secretBox = crypto_lib.SecretBox.fromConcatenation(
      encryptedData,
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    final decryptedData = await _algorithm.decrypt(secretBox, secretKey: key);
    return Uint8List.fromList(decryptedData);
  }
}
