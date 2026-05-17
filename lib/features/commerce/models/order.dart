class Order {
  final String id;
  final int eventId;
  final String eventTitle;
  final int quantity;
  final double unitPrice;
  final String currency;
  final String status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  double get totalAmount => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'eventTitle': eventTitle,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'currency': currency,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'].toString(),
    eventId: json['eventId'] as int,
    eventTitle: (json['eventTitle'] ?? '').toString(),
    quantity: (json['quantity'] ?? 1) as int,
    unitPrice: (json['unitPrice'] as num).toDouble(),
    currency: (json['currency'] ?? 'VND').toString(),
    status: (json['status'] ?? 'pending').toString(),
    createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
  );
}
