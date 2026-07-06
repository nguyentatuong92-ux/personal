import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/credential_model.dart';
import '../models/secure_note_model.dart';
import '../services/storage_service.dart';
import 'add_credential_screen.dart';
import 'add_secure_note_screen.dart';
import 'photo_vault_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CredentialModel> _credentials = [];
  List<SecureNoteModel> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final credentialsData = await StorageService.getCredentials();
    final notesData = await StorageService.getSecureNotes();
    setState(() {
      _credentials = credentialsData;
      _notes = notesData;
      _isLoading = false;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF64B5F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: Text('Đã sao chép $label'),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showCredentialDetails(CredentialModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Tài khoản', item.username),
                const SizedBox(height: 12),
                _detailRow('Mật khẩu', item.password),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _detailRow('Ghi chú', item.notes),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showNoteDetails(SecureNoteModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_detailRow('Nội dung', item.content)],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 22, color: Colors.blue),
            onPressed: () => _copyToClipboard(value, label.toLowerCase()),
            tooltip: 'Sao chép $label',
          ),
        ],
      ),
    );
  }

  void _showActionMenu(dynamic item) {
    final isNote = item is SecureNoteModel;
    final title = isNote ? item.title : (item as CredentialModel).serviceName;

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
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            if (!isNote)
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.blue),
                title: const Text('Sao chép mật khẩu'),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(item.password, 'mật khẩu');
                },
              ),
            if (isNote)
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.blue),
                title: const Text('Sao chép nội dung'),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(item.content, 'nội dung');
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Chỉnh sửa'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => isNote
                        ? AddSecureNoteScreen(note: item)
                        : AddCredentialScreen(credential: item),
                  ),
                );
                if (result == true) {
                  _loadAllData();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa thẻ'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(item);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(dynamic item) {
    final isNote = item is SecureNoteModel;
    final title = isNote ? item.title : (item as CredentialModel).serviceName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (isNote) {
                await StorageService.deleteSecureNote(item.id);
              } else {
                await StorageService.deleteCredential(item.id);
              }
              _loadAllData();
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
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
                'Tạo mới',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.vpn_key, color: Colors.blue),
              title: const Text('Thêm tài khoản mật khẩu'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddCredentialScreen(),
                  ),
                );
                if (result == true) _loadAllData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add, color: Colors.green),
              title: const Text('Thêm ghi chú bảo mật'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddSecureNoteScreen(),
                  ),
                );
                if (result == true) _loadAllData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.purple),
              title: const Text('Mở kho ảnh bảo mật'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhotoVaultScreen()),
                ).then((_) => _loadAllData());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kho bảo mật'),
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              tooltip: 'Cài đặt',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await _loadAllData();
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
                        'Đã làm mới danh sách',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                }
              },
              tooltip: 'Làm mới',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.lock), text: 'Mật khẩu'),
              Tab(icon: Icon(Icons.description), text: 'Ghi chú'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildCredentialsList(isDark),
                  _buildNotesList(isDark),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddMenu,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCredentialsList(bool isDark) {
    if (_credentials.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có mật khẩu nào được lưu',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _credentials.length,
      itemBuilder: (context, index) {
        final item = _credentials[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          color: item.colorValue != null
              ? Color(item.colorValue!)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFF0F7FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            title: Text(
              item.serviceName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                item.username,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ),
            onTap: () => _showCredentialDetails(item),
            onLongPress: () => _showActionMenu(item),
          ),
        );
      },
    );
  }

  Widget _buildNotesList(bool isDark) {
    if (_notes.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có ghi chú nào được lưu',
          style: TextStyle(fontSize: 20),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final item = _notes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          color: item.colorValue != null
              ? Color(item.colorValue!)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE8F5E9)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                item.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ),
            onTap: () => _showNoteDetails(item),
            onLongPress: () => _showActionMenu(item),
          ),
        );
      },
    );
  }
}
