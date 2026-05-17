import 'package:event_ticket_app/features/commerce/services/checkout_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  @override
  Widget build(BuildContext context) {
    final tickets = CheckoutService.getTickets();

    return Scaffold(
      appBar: AppBar(title: const Text('Vé của tôi')),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: tickets.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Bạn chưa có e-ticket nào. Hãy mua vé ngay!')),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ticket.eventTitle,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Mã vé: ${ticket.id}'),
                          Text('Mã đơn: ${ticket.orderId}'),
                          Text('Người giữ vé: ${ticket.holderName}'),
                          Text('Ghế/Khu vực: ${ticket.seatLabel}'),
                          Text('Trạng thái: ${ticket.status}'),
                          Text('Ngày phát hành: ${ticket.issuedAt.toString().substring(0, 16)}'),
                          const SizedBox(height: 10),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: QrImageView(
                                data: ticket.qrPayload,
                                size: 150,
                                version: QrVersions.auto,
                              ),
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
