import 'package:event_ticket_app/features/auth/screens/registerscreen/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);
    final response = await AuthService.login(userCtrl.text.trim(), passCtrl.text.trim());
    if (!mounted) return;
    setState(() => isLoading = false);

    if (response != null) {
      final box = GetStorage();
      await box.write('accessToken', response.accessToken);
      await box.write('role', response.role);
      await box.write('userName', response.userName);
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.snackbar('Đăng nhập thất bại', 'Sai tài khoản hoặc mật khẩu.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
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
                    const Text('Đăng nhập', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Chào mừng quay lại nền tảng vé sự kiện.', style: AppTextStyles.bodySecondary),
                    const SizedBox(height: 24),
                    TextField(
                      controller: userCtrl,
                      decoration: const InputDecoration(labelText: 'Tài khoản', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 14),
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
                        onPressed: isLoading ? null : handleLogin,
                        child: isLoading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Đăng nhập'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => Get.to(() => const RegisterScreen()),
                        child: const Text('Chưa có tài khoản? Đăng ký ngay'),
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
