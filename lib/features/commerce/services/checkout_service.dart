import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../models/order.dart';
import '../models/payment.dart';
import '../models/ticket.dart';

class CheckoutService {
  static const _ordersKey = 'orders';
  static const _ticketsKey = 'tickets';

  static final _box = GetStorage();

  static Future<(Order, Payment, List<Ticket>)> checkout({
    required int eventId,
    required String eventTitle,
    required String holderName,
    required int quantity,
    required double unitPrice,
    required String paymentMethod,
  }) async {
    final now = DateTime.now();
    final orderId = 'ORD-${now.microsecondsSinceEpoch}';
    final paymentId = 'PAY-${now.microsecondsSinceEpoch}';

    final order = Order(
      id: orderId,
      eventId: eventId,
      eventTitle: eventTitle,
      quantity: quantity,
      unitPrice: unitPrice,
      currency: 'VND',
      status: 'paid',
      createdAt: now,
    );

    final payment = Payment(
      id: paymentId,
      orderId: orderId,
      method: paymentMethod,
      amount: order.totalAmount,
      currency: 'VND',
      status: 'paid',
      createdAt: now,
    );

    final issuedTickets = List<Ticket>.generate(quantity, (index) {
      final ticketId = 'TKT-${now.microsecondsSinceEpoch}-${index + 1}';
      return Ticket(
        id: ticketId,
        orderId: orderId,
        eventId: eventId,
        eventTitle: eventTitle,
        holderName: holderName,
        seatLabel: 'GA-${index + 1}',
        qrPayload: jsonEncode({
          'ticketId': ticketId,
          'eventId': eventId,
          'orderId': orderId,
          'holder': holderName,
          'seat': 'GA-${index + 1}',
          'issuedAt': now.toIso8601String(),
        }),
        status: 'active',
        issuedAt: now,
      );
    });

    final orders = getOrders();
    orders.insert(0, order);
    await _box.write(_ordersKey, orders.map((e) => e.toJson()).toList());

    final tickets = getTickets();
    tickets.insertAll(0, issuedTickets);
    await _box.write(_ticketsKey, tickets.map((e) => e.toJson()).toList());

    return (order, payment, issuedTickets);
  }

  static List<Order> getOrders() {
    final raw = _box.read(_ordersKey);
    if (raw is! List) return [];
    return raw
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static List<Ticket> getTickets() {
    final raw = _box.read(_ticketsKey);
    if (raw is! List) return [];
    return raw
        .map((e) => Ticket.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
