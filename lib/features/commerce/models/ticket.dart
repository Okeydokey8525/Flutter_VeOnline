class Ticket {
  final String id;
  final String orderId;
  final int eventId;
  final String eventTitle;
  final String holderName;
  final String seatLabel;
  final String qrPayload;
  final String status;
  final DateTime issuedAt;


  const Ticket({
    required this.id,
    required this.orderId,
    required this.eventId,
    required this.eventTitle,
    required this.holderName,
    required this.seatLabel,
    required this.qrPayload,
    required this.status,
    required this.issuedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'eventId': eventId,
    'eventTitle': eventTitle,
    'holderName': holderName,
    'seatLabel': seatLabel,
    'qrPayload': qrPayload,
    'status': status,
    'issuedAt': issuedAt.toIso8601String(),
  };

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json['id'].toString(),
    orderId: json['orderId'].toString(),
    eventId: (json['eventId'] ?? 0) as int,
    eventTitle: (json['eventTitle'] ?? '').toString(),
    holderName: (json['holderName'] ?? 'Guest').toString(),
    seatLabel: (json['seatLabel'] ?? 'GA').toString(),
    qrPayload: (json['qrPayload'] ?? '').toString(),
    status: (json['status'] ?? 'active').toString(),
    issuedAt: DateTime.tryParse((json['issuedAt'] ?? '').toString()) ?? DateTime.now(),
  );
}
