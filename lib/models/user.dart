//import 'dart:convert';

class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String telefono;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      email: map['email'],
      telefono: map['telefono'],
    );
  }
}
