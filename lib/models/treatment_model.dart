class Treatment {
  final int? id;
  final String earTagNumber;
  final DateTime date;
  final String type;
  final String? doctor;
  final String? notes;

  Treatment({
    this.id,
    required this.earTagNumber,
    required this.date,
    required this.type,
    this.doctor,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'earTagNumber': earTagNumber,
      'date': date.toIso8601String(),
      'type': type,
      'doctor': doctor,
      'notes': notes,
    };
  }

  factory Treatment.fromMap(Map<String, dynamic> map) {
    return Treatment(
      id: map['id'],
      earTagNumber: map['earTagNumber'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      doctor: map['doctor'],
      notes: map['notes'],
    );
  }
}
