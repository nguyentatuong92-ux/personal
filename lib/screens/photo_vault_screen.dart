import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/photo_model.dart';
import '../services/storage_service.dart';

class PhotoVaultScreen extends StatefulWidget {
  const PhotoVaultScreen({super.key});

  @override
  State<PhotoVaultScreen> createState() => _PhotoVaultScreenState();
}

class _PhotoVaultScreenState extends State<PhotoVaultScreen> {
  List<PhotoModel> _photos = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    final data = await StorageService.getPhotos();
    setState(() {
      _photos = data;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Chọn nguồn ảnh',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Chụp ảnh từ Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Chọn từ Bộ sưu tập'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    final String? label = await _showLabelDialog();

    setState(() => _isLoading = true);
    await StorageService.savePhoto(File(image.path), label);
    await _loadPhotos();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF64B5F6),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: const Text(
            'Đã lưu ảnh vào kho bảo mật',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
  }

  Future<String?> _showLabelDialog() async {
    String label = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm nhãn cho ảnh'),
        content: TextField(
          autofocus: true,
          onChanged: (value) => label = value,
          decoration: const InputDecoration(
            hintText: 'Đặt tên cho ảnh của bạn',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bỏ qua'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, label),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _viewPhoto(PhotoModel photo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final Uint8List? bytes = await StorageService.getDecryptedPhoto(
      photo.fileName,
    );

    if (mounted) Navigator.pop(context); // Close loading

    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF64B5F6),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            content: const Text(
              'Không thể tải ảnh',
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(child: Image.memory(bytes)),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              if (photo.label != null && photo.label!.isNotEmpty)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      color: Colors.black54,
                      child: Text(
                        photo.label!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _sharePhoto(PhotoModel photo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final Uint8List? bytes = await StorageService.getDecryptedPhoto(
      photo.fileName,
    );

    if (mounted) Navigator.pop(context); // Close loading

    if (bytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/${photo.fileName}.jpg';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(tempPath)], text: photo.label);

    // Small delay to ensure sharing process started before cleanup
    Future.delayed(const Duration(minutes: 1), () {
      if (tempFile.existsSync()) tempFile.deleteSync();
    });
  }

  void _showActionMenu(PhotoModel photo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                photo.label ?? 'Ảnh bảo mật',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Chia sẻ ảnh'),
              onTap: () {
                Navigator.pop(context);
                _sharePhoto(photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa ảnh'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(photo);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(PhotoModel photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa ảnh này khỏi kho bảo mật?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.deletePhoto(photo);
              await _loadPhotos();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF64B5F6),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    content: const Text(
                      'Đã xóa ảnh khỏi kho bảo mật',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Kho ảnh bảo mật')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
          ? const Center(child: Text('Chưa có ảnh nào trong kho'))
          : GridView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 80,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return GestureDetector(
                  onTap: () => _viewPhoto(photo),
                  onLongPress: () => _showActionMenu(photo),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image, size: 50, color: Colors.blue),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            photo.label ?? 'Ảnh bảo mật',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
