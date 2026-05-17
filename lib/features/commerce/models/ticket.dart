class Ticket {
  final String id;
  final String orderId;
  final int eventId;
  final String eventTitle;
  final String holderName;
  final String seatLabel;
  final String qrPayload;
  final String status;

  const Ticket({
    required this.id,
    required this.orderId,
    required this.eventId,
    required this.eventTitle,
    required this.holderName,
    required this.seatLabel,
    required this.qrPayload,
    required this.status,
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
  };

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json['id'].toString(),
    orderId: json['orderId'].toString(),
    eventId: json['eventId'] as int,
    eventTitle: (json['eventTitle'] ?? '').toString(),
    holderName: (json['holderName'] ?? 'Guest').toString(),
    seatLabel: (json['seatLabel'] ?? 'GA').toString(),
    qrPayload: (json['qrPayload'] ?? '').toString(),
    status: (json['status'] ?? 'active').toString(),
  );
}
