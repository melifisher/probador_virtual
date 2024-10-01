import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Para el formato de fechas
import '../../models/product.dart';
import '../../models/user.dart';

class ProductRentalPage extends StatefulWidget {
  final Product product;
  final User user;

  const ProductRentalPage({
    super.key,
    required this.product,
    required this.user,
  });

  @override
  _ProductRentalPageState createState() => _ProductRentalPageState();
}

class _ProductRentalPageState extends State<ProductRentalPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalPrice = 0;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Fechas reservadas (esto vendría del backend)
  List<DateTime> reservedDates = [
    DateTime.now().add(Duration(days: 2)),
    DateTime.now().add(Duration(days: 5)),
  ];

  bool _isReserved(DateTime day) {
    return reservedDates.contains(day);
  }

  void _calculatePrice() {
    if (_startDate != null && _endDate != null) {
      int rentalDays = _endDate!.difference(_startDate!).inDays + 1;
      setState(() {
        _totalPrice = rentalDays * widget.product.precio;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alquilar ${widget.product.nombre}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la prenda
              Center(
                child: Image.network(
                  widget.product.imagen,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              // Calendario para seleccionar las fechas de alquiler
              Text(
                'Seleccione las fechas de alquiler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text('Seleccionar Inicio'),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text('Seleccionar Fin'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(Duration(days: 365)),
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (_isReserved(selectedDay)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Esta fecha está reservada.')),
                    );
                  }
                },
                selectedDayPredicate: (day) {
                  if (_startDate != null && _endDate != null) {
                    return day
                            .isAfter(_startDate!.subtract(Duration(days: 1))) &&
                        day.isBefore(_endDate!.add(Duration(days: 1)));
                  }
                  return _startDate != null && day.isSameDate(_startDate!) ||
                      _endDate != null && day.isSameDate(_endDate!);
                },
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.black),
                  todayTextStyle: TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                  disabledTextStyle: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 20),
              // Mostrar fechas seleccionadas
              Text(
                'Fecha de inicio: ${_startDate != null ? _dateFormat.format(_startDate!) : 'No seleccionada'}',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                'Fecha de fin: ${_endDate != null ? _dateFormat.format(_endDate!) : 'No seleccionada'}',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Mostrar el precio total
              if (_startDate != null && _endDate != null)
                Text(
                  'Precio total: \$$_totalPrice',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              // Botón para añadir al carrito
              ElevatedButton(
                onPressed: _startDate != null && _endDate != null
                    ? () {
                        // Lógica para añadir el producto al carrito
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Producto añadido al carrito')),
                        );
                      }
                    : null,
                child: const Text('Añadir al carrito'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      selectableDayPredicate: (DateTime day) {
        return !_isReserved(day);
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          if (_startDate != null && picked.isAfter(_startDate!)) {
            _endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'La fecha de fin debe ser posterior a la fecha de inicio.')),
            );
          }
        }
        _calculatePrice();
      });
    }
  }
}

// Helper extension para comparar fechas
extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
