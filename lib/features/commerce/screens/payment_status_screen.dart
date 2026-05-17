import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/order.dart';
import '../models/payment.dart';
import '../models/ticket.dart';

class PaymentStatusScreen extends StatelessWidget {
  final Order order;
  final Payment payment;
  final Ticket ticket;

  const PaymentStatusScreen({
    super.key,
    required this.order,
    required this.payment,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final success = payment.status == 'paid';
    return Scaffold(
      appBar: AppBar(title: const Text('Trạng thái thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              size: 80,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              success ? 'Thanh toán thành công' : 'Thanh toán thất bại',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Mã đơn: ${order.id}'),
            Text('Mã thanh toán: ${payment.id}'),
            Text('Mã vé: ${ticket.id}'),
            Text('Sự kiện: ${order.eventTitle}'),
            Text('Tổng tiền: ${order.totalAmount.toStringAsFixed(0)} ${order.currency}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.back(result: success),
              child: const Text('Hoàn tất'),
            ),
          ],
        ),
      ),
    );
  }
}
