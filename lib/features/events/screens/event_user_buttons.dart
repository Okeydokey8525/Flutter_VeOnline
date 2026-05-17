import 'dart:convert';

import 'package:event_ticket_app/features/commerce/screens/checkout_screen.dart';
import 'package:event_ticket_app/features/commerce/services/checkout_service.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

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

  Future<void> checkRegistration() async {
    setState(() => isLoading = true);
    try {
      final localRegistered = CheckoutService.hasActiveTicketForEvent(widget.eventId);
      final box = GetStorage();
      final token = box.read('accessToken') as String?;

      if (token == null || token.isEmpty) {
        setState(() {
          isRegistered = localRegistered;
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse('http://10.0.2.2:5054/api/registrations/check/${widget.eventId}');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isRegistered = (data['isRegistered'] ?? false) || localRegistered;
        });
      } else {
        setState(() => isRegistered = localRegistered);
      }
    } catch (_) {
      setState(() => isRegistered = CheckoutService.hasActiveTicketForEvent(widget.eventId));
    } finally {
      setState(() => isLoading = false);
    }
  }

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
        const SnackBar(content: Text('✅ Mua vé thành công')),
      );
    }
  }

  Future<void> cancelRegistration() async {
    setState(() => isLoading = true);
    try {
      final box = GetStorage();
      final token = box.read('accessToken') as String?;
      var cancelled = false;

      if (token != null && token.isNotEmpty) {
        final url = Uri.parse('http://10.0.2.2:5054/api/registrations/cancel-registration/${widget.eventId}');
        final response = await http.delete(url, headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });
        cancelled = response.statusCode >= 200 && response.statusCode < 300;
      }

      await CheckoutService.cancelTicketsForEvent(widget.eventId);
      setState(() => isRegistered = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cancelled
              ? '✅ Hủy tham gia thành công'
              : '✅ Đã hủy vé cục bộ (backend có thể chưa hỗ trợ endpoint hủy)'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi hủy tham gia: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (isRegistered) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: cancelRegistration,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
          icon: const Icon(Icons.cancel),
          label: const Text('Hủy tham gia'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: registerEvent,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
        icon: const Icon(Icons.shopping_cart_checkout),
        label: const Text('Tham gia sự kiện'),
      ),
    );
  }
}
