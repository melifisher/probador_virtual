import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Para el formato de fechas
import '../../models/product.dart';
import '../../models/user.dart';
import 'package:probador_virtual/screens/rent/cart_page.dart';
import 'package:probador_virtual/controllers/cart_controller.dart';
import 'package:probador_virtual/models/cart.dart';

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
  int _selectedCantidad = 1;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final CartController _cartController =
      CartController(); // Instancia del controlador

  // Fechas reservadas (esto vendría del backend)
  List<DateTime> reservedDates = [
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 5)),
  ];
  List<Cart> _cartItems = [];
  String? _selectedTalla;
  String? _selectedColor;
  bool _isReserved(DateTime day) {
    return reservedDates.contains(day);
  }

  void _calculatePrice() {
    if (_startDate != null && _endDate != null) {
      int rentalDays = _endDate!.difference(_startDate!).inDays + 1;
      setState(() {
        _totalPrice = rentalDays * widget.product.precio * _selectedCantidad;
      });
    }
  }
  // Función para cargar el carrito desde SharedPreferences
  Future<void> _loadCartItems() async {
    List<Cart> loadedCartItems = await _cartController.loadCartItems();
    setState(() {
      _cartItems = loadedCartItems;
    });
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

              // Dropdowns para seleccionar talla
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seleccione la talla',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedTalla,
                          hint: const Text('Seleccione una talla'),
                          items: widget.product.talla
                              .join(',')
                              .split(',')
                              .map((String talla) {
                            return DropdownMenuItem<String>(
                              value: talla.trim(),
                              child: Text(talla.trim()),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTalla = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      width:
                          16), // Espacio entre los dos dropdowns y selecciona el color
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seleccione el color',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedColor,
                          hint: const Text('Seleccione un color'),
                          items: widget.product.color
                              .join(',')
                              .split(',')
                              .map((String color) {
                            return DropdownMenuItem<String>(
                              value: color.trim(),
                              child: Text(color.trim()),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedColor = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Dropdown para seleccionar cantidad
              const Text(
                'Seleccione la cantidad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<int>(
                value: _selectedCantidad,
                hint: const Text('Cantidad'),
                items: List.generate(10,
                        (index) => index + 1) // Se puede modificar el limite
                    .map((int cantidad) {
                  return DropdownMenuItem<int>(
                    value: cantidad,
                    child: Text(cantidad.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedCantidad = newValue!;
                    _calculatePrice(); // Recalcular el precio cuando cambie la cantidad
                  });
                },
              ),

              // Calendario para seleccionar las fechas de alquiler
              const Text(
                'Seleccione las fechas de alquiler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (_isReserved(selectedDay)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Esta fecha está reservada.')),
                    );
                    return;
                  }
                  setState(() {
                    // Lógica para seleccionar y cambiar fechas dinámicamente
                    if (_startDate == null || _endDate != null) {
                      // Si no hay fecha de inicio o ambas fechas están seleccionadas
                      _startDate = selectedDay;
                      _endDate = null; // Resetear la fecha de fin
                    } else if (selectedDay.isAfter(_startDate!)) {
                      // Si la nueva fecha es después de la fecha de inicio, se establece como fecha de fin
                      _endDate = selectedDay;
                    } else {
                      // Si se intenta seleccionar una fecha anterior a la fecha de inicio
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'La fecha seleccionada debe ser posterior a la fecha de inicio.'),
                        ),
                      );
                      // Si se intenta seleccionar una fecha anterior a la fecha de inicio
                      _startDate = selectedDay;
                      _endDate =
                          null; // Resetear la fecha de fin para permitir una nueva selección
                    }

                    _calculatePrice();
                  });
                },
                selectedDayPredicate: (day) {
                  if (_startDate != null && _endDate != null) {
                    return day.isAfter(
                            _startDate!.subtract(const Duration(days: 1))) &&
                        day.isBefore(_endDate!.add(const Duration(days: 1)));
                  }
                  return _startDate != null && day.isSameDate(_startDate!) ||
                      _endDate != null && day.isSameDate(_endDate!);
                },
                calendarStyle: const CalendarStyle(
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
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                'Fecha de fin: ${_endDate != null ? _dateFormat.format(_endDate!) : 'No seleccionada'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Mostrar el precio total
              if (_startDate != null && _endDate != null)
                Text(
                  'Precio total: \$${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              // Botón para añadir al carrito

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _startDate != null &&
                            _endDate != null &&
                            _selectedTalla != null &&
                            _selectedColor != null
                        ? () async {
                            int rentalDays =
                                _endDate!.difference(_startDate!).inDays + 1;
                            // Crear el Cart
                            Cart cart = Cart(
                              id: 0, // Se generará en el backend
                              userId: widget.user.id,
                              productId: widget.product.id,
                              cantidad: _selectedCantidad,
                              talla: _selectedTalla!,
                              color: _selectedColor!,
                              rentalDays: rentalDays,
                              nombre: widget.product.nombre,
                              precio: widget.product.precio,
                              imagen: widget.product.imagen,
                            );
                            // Añadir el producto a la lista de carrito
                            setState(() {
                              _cartItems.add(cart);
                            });
                            // Depurar los datos antes de enviarlos
                            print(
                                "Datos enviados al servidor: ${cart.toMap()}");
                            // Añadir el producto al carrito
                            await _cartController.addToCart(cart);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Producto añadido al carrito')),
                            );
                          }
                        : null,
                    child: const Text('Añadir al carrito'),
                  ),
                  ElevatedButton(
                    onPressed: _cartItems.isNotEmpty
                        ? () {
                            int rentalDays =
                                _endDate!.difference(_startDate!).inDays + 1;
                            double totalPrice = _cartItems.fold(
                                0,
                                (total, item) =>
                                    total + (item.precio * rentalDays));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartPage(
                                  cartItems: _cartItems,
                                  rentalDays:
                                      rentalDays, // Pasar la duración del alquiler
                                  totalPrice:
                                      totalPrice, // Pasar el precio total calculado
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Ver Carrito'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper extension para comparar fechas
extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
