import 'package:event_ticket_app/core/app_routes.dart';
import 'package:event_ticket_app/features/auth/screens/login_screen.dart';
import 'package:event_ticket_app/features/profile/screen/change_email_screen.dart';
import 'package:event_ticket_app/features/profile/screen/change_password_screen.dart';
import 'package:event_ticket_app/features/profile/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:event_ticket_app/core/theme/app_tokens.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>>? _futureProfile;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final token = box.read('accessToken');
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => const LoginScreen());
      });
    } else {
      setState(() => _futureProfile = ProfileService.getProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_futureProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final user = snapshot.data ?? {};
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D6EFD), Color(0xFF38BDF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage('assets/images/avatar/user.png'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (user['username'] ?? box.read('userName') ?? 'Người dùng').toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (user['email'] ?? 'Không có email').toString(),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _menuCard(
                icon: Icons.person_outline,
                title: 'Thay đổi tên người dùng',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangeEmailScreen()),
                  );
                  _loadProfile();
                },
              ),
              _menuCard(
                icon: Icons.lock_outline,
                title: 'Thay đổi mật khẩu',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                ),
              ),
              _menuCard(
                icon: Icons.confirmation_number_outlined,
                title: 'Sự kiện của tôi',
                onTap: () => Get.toNamed(AppRoutes.myTickets),
              ),
              _menuCard(
                icon: Icons.logout,
                title: 'Đăng xuất',
                danger: true,
                onTap: () {
                  box.remove('accessToken');
                  box.remove('userName');
                  box.remove('role');
                  Get.offAll(() => const LoginScreen());
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuCard({required IconData icon, required String title, required VoidCallback onTap, bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: danger ? Colors.red : AppColors.primary),
          title: Text(title, style: TextStyle(color: danger ? Colors.red : AppColors.textPrimary, fontWeight: FontWeight.w600)),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
