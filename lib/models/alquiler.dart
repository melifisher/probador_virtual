class Alquiler {
  final int id;
  final int usuarioId;
  final DateTime fechaReserva;
  final DateTime fechaDevolucion;
  final double precio;
  final String estado; // 'pendiente', 'activo', 'completado', 'cancelado'

  Alquiler({
    required this.id,
    required this.usuarioId,
    required this.fechaReserva,
    required this.fechaDevolucion,
    required this.precio,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': usuarioId,
      'fecha_reserva': fechaReserva.toIso8601String(),
      'fecha_devolucion': fechaDevolucion.toIso8601String(),
      'precio': precio,
      'estado': estado,
    };
  }

  factory Alquiler.fromMap(Map<String, dynamic> map) {
    return Alquiler(
      id: map['id'] is String ? int.parse(map['id']) : map['id'],
      usuarioId:
          map['user_id'] is String ? int.parse(map['user_id']) : map['user_id'],
      fechaReserva: DateTime.parse(map['fecha_reserva']),
      fechaDevolucion: DateTime.parse(map['fecha_devolucion']),
      precio: map['precio'] is String
          ? double.parse(map['precio'])
          : (map['precio'] as num).toDouble(),
      estado: map['estado'],
    );
  }
}
