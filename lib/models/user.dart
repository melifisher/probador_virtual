class User {
  final int id;
  final String username;
  final String email;
  final String telefono;
  final String rol;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.telefono,
    required this.rol,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'telefono': telefono,
      'rol': rol,
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: int.parse(map['id']),
      username: map['username'],
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      rol: map['rol'],
    );
  }
}
