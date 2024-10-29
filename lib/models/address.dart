// models/address.dart
class Address {
  final String id;
  final String userId; // Referencia al ID del usuario
  final String street;
  final String number;
  final String city;
  final bool isSelected; // Asegúrate de definir esta propiedad

  Address({
    required this.id,
    required this.userId,
    required this.street,
    required this.number,
    required this.city,
      this.isSelected = false, // Valor predeterminado

  });

  // Conversión de Address a Map para guardar en SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'street': street,
      'number': number,
      'city': city,
      'isSelected': isSelected,
    };
  }

  // Conversión de Map a Address
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'],
      userId: map['userId'],
      street: map['street'],
      number: map['number'],
      city: map['city'],
       isSelected: map['isSelected'] ?? false,
    );
  }
}
