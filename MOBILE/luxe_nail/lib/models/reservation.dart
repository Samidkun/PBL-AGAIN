class Reservation {
  final int id;
  final String name;
  final String treatmentType;
  final String reservationDate;
  final String reservationTime;
  final String queueNumber;
  final String status;

  Reservation({
    required this.id,
    required this.name,
    required this.treatmentType,
    required this.reservationDate,
    required this.reservationTime,
    required this.queueNumber,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      name: json['name'],
      treatmentType: json['treatment_type'],
      reservationDate: json['reservation_date'],
      reservationTime: json['reservation_time'],
      queueNumber: json['queue_number'],
      status: json['status'],
    );
  }
}
