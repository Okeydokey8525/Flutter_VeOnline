import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newUserNameController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newUserNameController.addListener(_validateForm);
  }

  void _validateForm() {
    final isFormValid = _newUserNameController.text.trim().length >= 3;
    if (_isButtonEnabled != isFormValid) {
      setState(() => _isButtonEnabled = isFormValid);
    }
  }

  Future<void> _confirmAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thay đổi'),
        content: const Text('Bạn có chắc chắn muốn thay đổi tên người dùng không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Đồng ý')),
        ],
      ),
    );

    if (confirm == true) {
      _submitChangeUserName();
    }
  }

  Future<void> _submitChangeUserName() async {
    setState(() => _isLoading = true);

    try {
      final box = GetStorage();
      final token = box.read('accessToken');
      if (token == null) throw Exception('Token không tồn tại, vui lòng đăng nhập lại.');

      final newName = _newUserNameController.text.trim();

      final response = await http.put(
        Uri.parse('http://10.0.2.2:5054/api/profile/username'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'username': newName}),
      );

      await box.write('userName', newName);

      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cập nhật tên người dùng thành công'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Đã cập nhật tên cục bộ, backend chưa nhận thay đổi'), backgroundColor: Colors.orange),
        );
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _newUserNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thay đổi tên người dùng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cập nhật tên hiển thị', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Tên mới sẽ hiển thị trong thông tin cá nhân của bạn.'),
              const SizedBox(height: 28),
              TextFormField(
                controller: _newUserNameController,
                decoration: const InputDecoration(labelText: 'Tên người dùng mới', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập tên người dùng';
                  if (value.trim().length < 3) return 'Tên người dùng tối thiểu 3 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled && !_isLoading ? _confirmAndSubmit : null,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Cập nhật tên'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
