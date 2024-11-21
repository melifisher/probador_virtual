import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/address_controller.dart';
import '../../models/address.dart';
import '../../models/cart.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final List<Cart> cartItems; // Lista de productos en el carrito
  final double totalAmount;

  const PaymentConfirmationPage({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  int selectedTip = 5; // Propina seleccionada
  final String deliveryTime = "40-60 min"; // Tiempo estimado de entrega
  final double deliveryCost = 10.0; // Costo fijo de delivery
  int selectedPaymentMethod = 0; // Índice del método de pago seleccionado

  @override
  Widget build(BuildContext context) {
    final addressController = Provider.of<AddressController>(context);
    final Address? selectedAddress = addressController.addresses.isNotEmpty
        ? addressController.addresses.firstWhere(
            (address) => address.isSelected,
            orElse: () => addressController.addresses.first,
          )
        : null;

    final double totalWithTip = widget.totalAmount + selectedTip;

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
                "¿Cómo quieres pagar?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildPaymentMethodSelector(),
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Resumen del pedido",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildOrderSummary(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Total: Bs. ${totalWithTip.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Acción para confirmar el pedido
                },
                child: const Text("Confirmar Pedido"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedPaymentMethod = 0;
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
                selectedPaymentMethod = 1;
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
      width: 150,
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
          Icon(icon, size: 40, color: selected ? Colors.white : Colors.black),
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
                "Delivery: $deliveryTime",
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
                onPressed: () {
                  // Acción para cambiar la dirección
                  Navigator.pushNamed(context, '/listAddress');
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Costo de delivery:",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "Bs.${deliveryCost.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Propina:",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "Bs.${selectedTip.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
