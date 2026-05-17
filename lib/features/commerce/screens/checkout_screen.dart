import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../services/checkout_service.dart';
import 'payment_status_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const CheckoutScreen({super.key, required this.eventId, required this.eventTitle});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int quantity = 1;
  String paymentMethod = 'VNPAY';
  bool isLoading = false;
  final unitPrice = 199000.0;

  Future<void> _pay() async {
    setState(() => isLoading = true);
    final userName = (GetStorage().read('userName') ?? 'Guest').toString();

    final (order, payment, ticket) = await CheckoutService.checkout(
      eventId: widget.eventId,
      eventTitle: widget.eventTitle,
      holderName: userName,
      quantity: quantity,
      unitPrice: unitPrice,
      paymentMethod: paymentMethod,
    );

    if (!mounted) return;
    setState(() => isLoading = false);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusScreen(order: order, payment: payment, ticket: ticket),
      ),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final total = unitPrice * quantity;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.eventTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Số lượng vé:'),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: quantity,
                  items: List.generate(6, (i) => i + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (v) => setState(() => quantity = v ?? 1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Phương thức thanh toán'),
            DropdownButton<String>(
              value: paymentMethod,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'VNPAY', child: Text('VNPAY')),
                DropdownMenuItem(value: 'MOMO', child: Text('MoMo')),
                DropdownMenuItem(value: 'CARD', child: Text('Thẻ ngân hàng')),
              ],
              onChanged: (v) => setState(() => paymentMethod = v ?? 'VNPAY'),
            ),
            const SizedBox(height: 12),
            Text('Đơn giá: ${unitPrice.toStringAsFixed(0)} VND'),
            Text('Tổng tiền: ${total.toStringAsFixed(0)} VND', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: isLoading ? null : _pay,
              child: isLoading ? const CircularProgressIndicator() : const Text('Thanh toán'),
            ),
          ],
        ),
      ),
    );
  }
}
