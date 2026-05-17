class Payment {
  final String id;
  final String orderId;
  final String method;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'method': method,
    'amount': amount,
    'currency': currency,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}
