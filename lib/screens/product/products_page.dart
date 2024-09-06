import 'package:flutter/material.dart';
import 'package:probador_virtual/controllers/product_controller.dart';
import '../../models/product.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductController _controller = ProductController();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _controller
        .getProducts(); // Assuming you have a method to fetch products
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Product product = snapshot.data![index];
                return ListTile(
                  title: Text(product.nombre),
                  subtitle: Text('\$${product.precio.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailView(product: product),
                      ),
                    ).then((_) => setState(() {
                          _productsFuture = _controller.getProducts();
                        }));
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailView(),
            ),
          ).then((_) => setState(() {
                _productsFuture = _controller.getProducts();
              }));
        },
      ),
    );
  }
}
