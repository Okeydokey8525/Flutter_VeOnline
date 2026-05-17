import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:event_ticket_app/core/theme/app_tokens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  bool isLoading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> handleRegister() async {
    final username = userCtrl.text.trim();
    final password = passCtrl.text.trim();
    final email = emailCtrl.text.trim();
    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      Get.snackbar('Thông tin không hợp lệ', 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5054/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userName': username, 'password': password, 'email': email}),
    );
    if (!mounted) return;
    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar('Thành công', 'Đăng ký thành công, hãy đăng nhập.');
      Get.back();
    } else {
      Get.snackbar('Đăng ký thất bại', response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tạo tài khoản mới', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Trải nghiệm hệ thống bán vé theo phong cách SaaS hiện đại.', style: AppTextStyles.bodySecondary),
                    const SizedBox(height: 24),
                    TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Tài khoản', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passCtrl,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => hidePassword = !hidePassword),
                          icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleRegister,
                        child: isLoading ? const CircularProgressIndicator() : const Text('Đăng ký'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
