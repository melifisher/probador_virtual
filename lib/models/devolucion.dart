class Devolucion {
  final int id;
  final int alquilerId;
  final int usuarioId;
  final DateTime fechaDevuelto;
  final int diasRetraso;
  final String estado; // 'pendiente', 'devuelto', 'retraso'

  Devolucion({
    required this.id,
    required this.usuarioId,
    required this.alquilerId,
    required this.fechaDevuelto,
    required this.diasRetraso,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': usuarioId,
      'alquiler_id': alquilerId,
      'fecha_devuelto': fechaDevuelto.toIso8601String(),
      'dias_retraso': diasRetraso,
      'estado': estado,
    };
  }

  factory Devolucion.fromMap(Map<String, dynamic> map) {
    return Devolucion(
      id: map['id'] is String ? int.parse(map['id']) : map['id'],
      usuarioId:
          map['user_id'] is String ? int.parse(map['user_id']) : map['user_id'],
      alquilerId: map['alquiler_id'] is String
          ? int.parse(map['alquiler_id'])
          : map['alquiler_id'],
      fechaDevuelto: DateTime.parse(map['fecha_devuelto']),
      diasRetraso: map['dias_retraso'] is String
          ? int.parse(map['dias_retraso'])
          : map['dias_retraso'],
      estado: map['estado'],
    );
  }
}
