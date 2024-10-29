class User {
  final int id;
  final String username;
  final String email;
  final String password;
  final String rol;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.rol,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'rol': rol,
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: int.parse(map['id']),
      username: map['username'],
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      rol: map['rol'],
    );
  }
}
