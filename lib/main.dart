import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; //  thêm import
import 'core/app_routes.dart';
import 'core/theme/app_tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await GetStorage.init(); // Bắt buộc khởi tạo trước khi runApp
  runApp(const EventTicketApp());
}

class EventTicketApp extends StatelessWidget {
  const EventTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Event Ticket App',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, secondary: AppColors.secondary, surface: AppColors.surface),
        scaffoldBackgroundColor: AppColors.surface,
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.surface, foregroundColor: AppColors.textPrimary, elevation: 0),
        cardTheme: CardThemeData(color: AppColors.surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg), side: const BorderSide(color: AppColors.border))),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white)),
        useMaterial3: true,
      ),
    );
  }
}
