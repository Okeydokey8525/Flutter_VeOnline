import 'package:event_ticket_app/features/commerce/services/checkout_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  bool isLoading = true;
  final box = GetStorage();
  bool isLoading = true;
  String? errorMessage;
  List<dynamic> tickets = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => isLoading = false);
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {});

    fetchMyTickets();
  }

  Future<void> fetchMyTickets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = box.read('accessToken') as String?;
      if (token == null || token.isEmpty) {
        setState(() {
          errorMessage = 'Bạn cần đăng nhập để xem vé đã đặt.';
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse('http://10.0.2.2:5054/api/registrations/my-events');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          tickets = data is List ? data : [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Không thể tải danh sách vé (${response.statusCode}).';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Đã có lỗi xảy ra: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tickets = CheckoutService.getTickets();

    return Scaffold(
      appBar: AppBar(title: const Text('Vé của tôi')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tickets.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('Bạn chưa có e-ticket nào.')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ticket.eventTitle,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Mã vé: ${ticket.id}'),
                              Text('Mã đơn: ${ticket.orderId}'),
                              Text('Người giữ vé: ${ticket.holderName}'),
                              Text('Ghế/Khu vực: ${ticket.seatLabel}'),
                              Text('Trạng thái: ${ticket.status}'),
                              const SizedBox(height: 10),
                              Center(
                                child: QrImageView(
                                  data: ticket.qrPayload,
                                  size: 150,
                                  version: QrVersions.auto,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé của tôi'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchMyTickets,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchMyTickets,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  )
                : tickets.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Bạn chưa đặt vé sự kiện nào.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index] as Map<String, dynamic>;
                          final title =
                              ticket['title'] ?? ticket['eventName'] ?? 'Sự kiện';
                          final date = ticket['date'] ?? ticket['eventDate'] ?? 'N/A';
                          final location =
                              ticket['location'] ?? ticket['eventLocation'] ?? 'Chưa xác định';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.confirmation_number),
                              title: Text(title.toString()),
                              subtitle: Text('$date\n$location'),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
