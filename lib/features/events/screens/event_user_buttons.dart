import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';
import 'package:event_ticket_app/features/commerce/screens/checkout_screen.dart';

class EventUserButtons extends StatefulWidget {
  final int eventId;
  final String eventTitle;
  const EventUserButtons({super.key, required this.eventId, required this.eventTitle});

  @override
  State<EventUserButtons> createState() => _EventUserButtonsState();
}

class _EventUserButtonsState extends State<EventUserButtons> {
  bool isRegistered = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkRegistration();
  }

  // Kiểm tra trạng thái đăng ký từ backend
  Future<void> checkRegistration() async {
    setState(() => isLoading = true);
    try {
      final box = GetStorage();
      final token = box.read("accessToken") as String?;

      if (token == null || token.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Vui lòng đăng nhập để thực hiện hành động này'),
          ),
        );
        return;
      }

      // API check đăng ký
      final url = Uri.parse(
        "http://10.0.2.2:5054/api/registrations/check/${widget.eventId}",
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Giả sử API trả về { "isRegistered": true/false }
        setState(() {
          isRegistered = data["isRegistered"] ?? false;
        });
      } else {
        setState(() => isRegistered = false);
      }
    } catch (e) {
      setState(() => isRegistered = false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 👈 Tham gia sự kiện
  Future<void> registerEvent() async {
    final bought = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(eventId: widget.eventId, eventTitle: widget.eventTitle),
      ),
    );

    if (bought == true) {
      setState(() => isRegistered = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Mua vé thành công")),
      );
    }
  }

  // 👈 Hủy tham gia sự kiện
  Future<void> cancelRegistration() async {
    setState(() => isLoading = true);
    try {
      final box = GetStorage();
      final token = box.read("accessToken") as String?;

      if (token == null || token.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Vui lòng đăng nhập để hủy vé')),
        );
        return;
      }

      final url = Uri.parse(
        "http://10.0.2.2:5054/api/registrations/cancel-registration/${widget.eventId}",
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: jsonEncode({"eventId": widget.eventId}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() => isRegistered = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Hủy đăng ký thành công")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Lỗi: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isRegistered ? null : registerEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Tham gia sự kiện"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: isRegistered ? cancelRegistration : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Hủy tham gia"),
          ),
        ),
      ],
    );
  }
}
