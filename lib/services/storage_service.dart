import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/credential_model.dart';
import '../models/secure_note_model.dart';
import '../models/photo_model.dart';
import 'encryption_service.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _credentialsKey = 'user_credentials';
  static const _masterPasswordKey = 'master_password';
  static const _themeModeKey = 'theme_mode';
  static const _notesKey = 'secure_notes';
  static const _photosKey = 'secure_photos';

  // Theme Mode
  static Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: _themeModeKey, value: mode);
  }

  static Future<String?> getThemeMode() async {
    return await _storage.read(key: _themeModeKey);
  }

  // Master Password
  static Future<void> saveMasterPassword(String password) async {
    await _storage.write(key: _masterPasswordKey, value: password);
  }

  static Future<String?> getMasterPassword() async {
    return await _storage.read(key: _masterPasswordKey);
  }

  // Credentials
  static Future<List<CredentialModel>> getCredentials() async {
    final data = await _storage.read(key: _credentialsKey);
    if (data == null) return [];

    final List<dynamic> decoded = json.decode(data);
    return decoded.map((item) => CredentialModel.fromMap(item)).toList();
  }

  static Future<void> saveCredential(CredentialModel credential) async {
    final credentials = await getCredentials();
    final index = credentials.indexWhere((e) => e.id == credential.id);
    if (index != -1) {
      credentials[index] = credential;
    } else {
      credentials.add(credential);
    }
    await _storage.write(
      key: _credentialsKey,
      value: json.encode(credentials.map((e) => e.toMap()).toList()),
    );
  }

  static Future<void> deleteCredential(String id) async {
    final credentials = await getCredentials();
    credentials.removeWhere((item) => item.id == id);
    await _storage.write(
      key: _credentialsKey,
      value: json.encode(credentials.map((e) => e.toMap()).toList()),
    );
  }

  // Secure Notes
  static Future<List<SecureNoteModel>> getSecureNotes() async {
    final data = await _storage.read(key: _notesKey);
    if (data == null) return [];

    final List<dynamic> decoded = json.decode(data);
    return decoded.map((item) => SecureNoteModel.fromMap(item)).toList();
  }

  static Future<void> saveSecureNote(SecureNoteModel note) async {
    final notes = await getSecureNotes();
    final index = notes.indexWhere((e) => e.id == note.id);
    if (index != -1) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    await _storage.write(
      key: _notesKey,
      value: json.encode(notes.map((e) => e.toMap()).toList()),
    );
  }

  static Future<void> deleteSecureNote(String id) async {
    final notes = await getSecureNotes();
    notes.removeWhere((item) => item.id == id);
    await _storage.write(
      key: _notesKey,
      value: json.encode(notes.map((e) => e.toMap()).toList()),
    );
  }

  // Secure Photos
  static Future<String> get _photoDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'secure_photos');
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  static Future<List<PhotoModel>> getPhotos() async {
    final data = await _storage.read(key: _photosKey);
    if (data == null) return [];
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((item) => PhotoModel.fromMap(item)).toList();
  }

  static Future<void> savePhoto(File file, String? label) async {
    final masterPassword = await getMasterPassword();
    if (masterPassword == null) return;

    final key = await EncryptionService.deriveKey(masterPassword);
    final bytes = await file.readAsBytes();
    final encryptedBytes = await EncryptionService.encryptData(bytes, key);

    final photoDir = await _photoDirectory;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.enc';
    final encryptedFile = File(p.join(photoDir, fileName));
    await encryptedFile.writeAsBytes(encryptedBytes);

    final photos = await getPhotos();
    final newPhoto = PhotoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      label: label,
      createdAt: DateTime.now(),
    );
    photos.add(newPhoto);

    await _storage.write(
      key: _photosKey,
      value: json.encode(photos.map((e) => e.toMap()).toList()),
    );
  }

  static Future<Uint8List?> getDecryptedPhoto(String fileName) async {
    final masterPassword = await getMasterPassword();
    if (masterPassword == null) return null;

    final photoDir = await _photoDirectory;
    final encryptedFile = File(p.join(photoDir, fileName));
    if (!await encryptedFile.exists()) return null;

    final encryptedBytes = await encryptedFile.readAsBytes();
    final key = await EncryptionService.deriveKey(masterPassword);
    return await EncryptionService.decryptData(encryptedBytes, key);
  }

  static Future<void> deletePhoto(PhotoModel photo) async {
    final photoDir = await _photoDirectory;
    final encryptedFile = File(p.join(photoDir, photo.fileName));
    if (await encryptedFile.exists()) {
      await encryptedFile.delete();
    }

    final photos = await getPhotos();
    photos.removeWhere((p) => p.id == photo.id);
    await _storage.write(
      key: _photosKey,
      value: json.encode(photos.map((e) => e.toMap()).toList()),
    );
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    final photoDir = await _photoDirectory;
    final dir = Directory(photoDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
