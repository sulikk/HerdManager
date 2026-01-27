class Animal {
  final String earTagNumber;
  final DateTime birthDate;
  final String breed;
  final double? weight;
  final String? origin;
  final String? notes;
  final String? imagePath;

  Animal({
    required this.earTagNumber,
    required this.birthDate,
    required this.breed,
    this.weight,
    this.origin,
    this.notes,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'earTagNumber': earTagNumber,
      'birthDate': birthDate.toIso8601String(),
      'breed': breed,
      'weight': weight,
      'origin': origin,
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      earTagNumber: map['earTagNumber'],
      birthDate: DateTime.parse(map['birthDate']),
      breed: map['breed'],
      weight: map['weight'],
      origin: map['origin'],
      notes: map['notes'],
      imagePath: map['imagePath'],
    );
  }

  String get age {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final days = difference.inDays;

    if (days < 30) {
      return '$days dni';
    } else if (days < 365) {
      return '${(days / 30).floor()} mies.';
    } else {
      final years = (days / 365).floor();
      final months = ((days % 365) / 30).floor();
      return '$years lat $months mies.';
    }
  }
}