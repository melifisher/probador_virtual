class User {
  final int id;
  final String nombre;
  final String email;
  final String telefono;
  final String rol;

  User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'rol': rol,
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: int.parse(map['id']),
      nombre: map['nombre'],
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      rol: map['rol'],
    );
  }
}
