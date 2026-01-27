class Sale {
  final int? id;
  final String earTagNumber;
  final DateTime saleDate;
  final double weight;
  final double price;
  final String? notes;

  Sale({
    this.id,
    required this.earTagNumber,
    required this.saleDate,
    required this.weight,
    required this.price,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'earTagNumber': earTagNumber,
      'saleDate': saleDate.toIso8601String(),
      'weight': weight,
      'price': price,
      'notes': notes,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      earTagNumber: map['earTagNumber'],
      saleDate: DateTime.parse(map['saleDate']),
      weight: map['weight'],
      price: map['price'],
      notes: map['notes'],
    );
  }
}
