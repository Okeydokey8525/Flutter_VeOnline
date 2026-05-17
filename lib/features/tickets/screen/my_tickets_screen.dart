import 'package:event_ticket_app/features/commerce/services/checkout_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  bool isLoading = true;

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
      ),
    );
  }
}
