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

    final (order, payment, tickets) = await CheckoutService.checkout(
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
        builder: (_) => PaymentStatusScreen(
          order: order,
          payment: payment,
          tickets: tickets,
        ),
      ),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final total = unitPrice * quantity;
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán vé')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F0FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.eventTitle,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Hạng vé: General Admission'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Số lượng vé'),
                        DropdownButton<int>(
                          value: quantity,
                          items: List.generate(6, (i) => i + 1)
                              .map((e) => DropdownMenuItem(value: e, child: Text('$e vé')))
                              .toList(),
                          onChanged: (v) => setState(() => quantity = v ?? 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Phương thức thanh toán',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['VNPAY', 'MOMO', 'CARD']
                          .map(
                            (method) => ChoiceChip(
                              label: Text(method),
                              selected: paymentMethod == method,
                              onSelected: (_) => setState(() => paymentMethod = method),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Đơn giá', '${unitPrice.toStringAsFixed(0)} VND'),
                    _row('Số lượng', '$quantity'),
                    const Divider(),
                    _row('Tổng thanh toán', '${total.toStringAsFixed(0)} VND', true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: isLoading ? null : _pay,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.lock),
                label: Text(isLoading ? 'Đang xử lý...' : 'Thanh toán ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, [bool bold = false]) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
