import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/order.dart';
import '../models/payment.dart';
import '../models/ticket.dart';

class PaymentStatusScreen extends StatelessWidget {
  final Order order;
  final Payment payment;
  final List<Ticket> tickets;

  const PaymentStatusScreen({
    super.key,
    required this.order,
    required this.payment,
    required this.tickets,
  });

  @override
  Widget build(BuildContext context) {
    final success = payment.status == 'paid';
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: success ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(success ? Icons.check_circle : Icons.cancel,
                      color: success ? Colors.green : Colors.red, size: 72),
                  const SizedBox(height: 8),
                  Text(success ? 'Thanh toán thành công' : 'Thanh toán thất bại',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Bạn đã nhận ${tickets.length} e-ticket.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _line('Mã đơn hàng', order.id),
                    _line('Mã giao dịch', payment.id),
                    _line('Phương thức', payment.method),
                    _line('Sự kiện', order.eventTitle),
                    _line('Tổng tiền', '${order.totalAmount.toStringAsFixed(0)} ${order.currency}', bold: true),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(result: success),
                child: const Text('Về trang trước'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String k, String v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k),
        Expanded(
          child: Text(v,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        ),
      ],
    ),
  );
}
