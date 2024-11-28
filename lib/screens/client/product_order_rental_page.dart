import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Para el formato de fechas
import '../../models/product.dart';
import '../../models/user.dart';
import 'package:probador_virtual/screens/rent/cart_page.dart';
import 'package:probador_virtual/controllers/cart_controller.dart';
import 'package:probador_virtual/models/cart.dart';
import 'dart:convert'; // Para manejar JSON
import 'package:shared_preferences/shared_preferences.dart';

class ProductOrderRentalPage extends StatefulWidget {
  final Product product;
  final User user;

  const ProductOrderRentalPage({
    super.key,
    required this.product,
    required this.user,
  });

  @override
  _ProductOrderRentalPageState createState() => _ProductOrderRentalPageState();
}

class _ProductOrderRentalPageState extends State<ProductOrderRentalPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalPrice = 0;
  int _selectedCantidad = 1;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final CartController _cartController =
      CartController(); // Instancia del controlador
  List<Cart> _cartItems = [];
  String? _selectedTalla;
  String? _selectedColor;
  bool _isFirstTimeSelection = true;
  @override
  void initState() {
    super.initState();
    _loadCartItems(); // Cargar productos del carrito desde SharedPreferences
    _loadRentalDates();
  }

  // Método para verificar si ya hay fechas seleccionadas en "Alquiler por pedido"
  Future<void> _loadRentalDates() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateString = prefs.getString('startDate');
    final endDateString = prefs.getString('endDate');

    if (startDateString != null && endDateString != null) {
      setState(() {
        _startDate = DateTime.parse(startDateString);
        _endDate = DateTime.parse(endDateString);
        _isFirstTimeSelection =
            false; // Si ya hay fechas guardadas, no es la primera vez
      });
      _calculatePrice(); // Calcula el precio usando las fechas cargadas
    }
  }

  Future<void> _saveRentalDates() async {
    final prefs = await SharedPreferences.getInstance();
    if (_startDate != null && _endDate != null) {
      await prefs.setString('startDate', _startDate!.toIso8601String());
      await prefs.setString('endDate', _endDate!.toIso8601String());
    }
  }

  void _calculatePrice() {
    if (_startDate != null && _endDate != null) {
      int rentalDays = _endDate!.difference(_startDate!).inDays + 1;
      setState(() {
        _totalPrice = rentalDays * widget.product.precio * _selectedCantidad;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_isFirstTimeSelection) {
      setState(() {
        if (_startDate == null || _endDate != null) {
          _startDate = selectedDay;
          _endDate = null;
        } else if (selectedDay.isAfter(_startDate!)) {
          _endDate = selectedDay;
          _isFirstTimeSelection = false; // Marcar como seleccionado
          _saveRentalDates(); // Guardar fechas una vez seleccionadas ambas
        }
        _calculatePrice();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Las fechas ya están seleccionadas para este pedido.')),
      );
    }
  }

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsJson =
        prefs.getStringList('cartItems_${widget.user.id}');
    if (cartItemsJson != null) {
      setState(() {
        _cartItems = cartItemsJson
            .map((jsonItem) => Cart.fromMap(jsonDecode(jsonItem)))
            .toList();
      });
    }
  }

  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson =
        _cartItems.map((cart) => jsonEncode(cart.toMap())).toList();
    await prefs.setStringList('cartItems_${widget.user.id}', cartItemsJson);
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
              Center(
                child: Image.network(
                  widget.product.imagen,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
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
                  const SizedBox(width: 16),
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
              const Text(
                'Seleccione la cantidad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<int>(
                value: _selectedCantidad,
                hint: const Text('Cantidad'),
                items:
                    List.generate(10, (index) => index + 1).map((int cantidad) {
                  return DropdownMenuItem<int>(
                    value: cantidad,
                    child: Text(cantidad.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedCantidad = newValue!;
                    _calculatePrice();
                  });
                },
              ),
              if (_startDate == null || _endDate == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seleccione las fechas de alquiler',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
                        setState(() {
                          if (_startDate == null || _endDate != null) {
                            _startDate = selectedDay;
                            _endDate = null;
                          } else if (selectedDay.isAfter(_startDate!)) {
                            _endDate = selectedDay;
                          }
                          _calculatePrice();
                          _saveRentalDates();
                        });
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Text(
                'Fecha de inicio: ${_startDate != null ? _dateFormat.format(_startDate!) : 'No seleccionada'}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Fecha de fin: ${_endDate != null ? _dateFormat.format(_endDate!) : 'No seleccionada'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (_startDate != null && _endDate != null)
                Text(
                  'Precio total: \$${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
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
                            Cart cart = Cart(
                              id: 0,
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
                            setState(() {
                              _cartItems.add(cart);
                            });
                            // Guardar los cambios en SharedPreferences
                            await _saveCartItems();

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
                                  rentalDays: rentalDays,
                                  totalPrice: totalPrice,
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
