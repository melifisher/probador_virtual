import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/address_controller.dart';
import '../../models/address.dart';
import '../../models/cart.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final List<Cart> cartItems; // Lista de productos en el carrito
  final double totalAmount;
  final String deliveryOption; // Opción de entrega seleccionada

  const PaymentConfirmationPage({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
    required this.deliveryOption, // Recibe la opción de entrega
  }) : super(key: key);

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  final String deliveryTime = "40-60 min"; // Tiempo estimado de entrega
  final double deliveryCost = 10.0; // Costo fijo de delivery
  int selectedPaymentMethod = 0; // Índice del método de pago seleccionado
  Address? selectedAddress; // Dirección seleccionada para la entrega

  @override
  void initState() {
    super.initState();
    _loadSelectedAddress(); // Cargar la dirección seleccionada al inicio
  }

  Future<void> _loadSelectedAddress() async {
    // Obtiene la dirección seleccionada desde el AddressController
    final addressController =
        Provider.of<AddressController>(context, listen: false);

    setState(() {
      selectedAddress = addressController.addresses.firstWhere(
        (address) =>
            address.isSelected, // Busca la dirección marcada como seleccionada
        orElse: () => addressController
            .addresses.first, // Si no hay seleccionada, toma la primera
      );
    });
  }

  void _changeSelectedAddress(Address newAddress) {
    setState(() {
      selectedAddress = newAddress; // Actualiza la dirección seleccionada
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressController = Provider.of<AddressController>(context);
    final Address? selectedAddress = addressController.addresses.isNotEmpty
        ? addressController.addresses.firstWhere(
            (address) => address.isSelected,
            orElse: () => addressController.addresses.first,
          )
        : null;

    // Ajustar el total en función de la opción seleccionada
    final double adjustedTotal = widget.totalAmount +
        (widget.deliveryOption == "delivery" ? deliveryCost : 0.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirma tu pedido"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "¿Cómo desea pagar?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildPaymentMethodCarousel(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Resumen del pedido",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildOrderSummary(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Datos de entrega",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildDeliveryDetails(selectedAddress),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Total: Bs. ${adjustedTotal.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Acción para confirmar el pedido
                  final paymentMethod = selectedPaymentMethod == 0
                      ? "Tarjeta"
                      : "QR"; // Determina el método de pago
                  print("Método de pago seleccionado: $paymentMethod");
                },
                child: const Text("Confirmar Pedido"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCarousel() {
    return SizedBox(
      height: 120, // Altura del carrusel
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedPaymentMethod = 0; // Selecciona "Tarjeta"
              });
            },
            child: _buildPaymentOption(
              selected: selectedPaymentMethod == 0,
              title: "Tarjeta",
              icon: Icons.credit_card,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedPaymentMethod = 1; // Selecciona "QR"
              });
            },
            child: _buildPaymentOption(
              selected: selectedPaymentMethod == 1,
              title: "QR",
              icon: Icons.qr_code,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required bool selected,
    required String title,
    required IconData icon,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: selected ? Colors.blueAccent : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? Colors.blue : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: selected ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails(Address? selectedAddress) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.delivery_dining, size: 40, color: Colors.blue),
              const SizedBox(width: 10),
              Text(
                widget.deliveryOption == "delivery"
                    ? "Delivery: $deliveryTime"
                    : "Retiro en tienda",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 40, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedAddress != null
                      ? selectedAddress.street
                      : "No se ha seleccionado una dirección.",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Simulación de cambiar dirección (navegación a una pantalla de selección)
                  Address newAddress = await Navigator.pushNamed(
                    context,
                    '/listAddress',
                  ) as Address;

                  // Actualiza la dirección seleccionada
                  _changeSelectedAddress(newAddress);
                },
                child: const Text("Cambiar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      children: [
        // Mostrar productos del carrito
        ...widget.cartItems.map((cartItem) {
          double totalItem = cartItem.cantidad *
              cartItem.rentalDays *
              cartItem.precio; // Calcula el total por ítem
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${cartItem.cantidad}x ${cartItem.nombre} (${cartItem.rentalDays} días a Bs.${cartItem.precio.toStringAsFixed(2)}/día)",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Bs.${totalItem.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
        // Mostrar el costo de delivery si aplica
        if (widget.deliveryOption == "delivery")
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Costo de delivery:",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Bs.${deliveryCost.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
