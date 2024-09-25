import 'package:flutter/material.dart';
import 'package:probador_virtual/controllers/product_controller.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

class ProductsPage extends StatefulWidget {
  final User user;
  final int? categoryId;
  const ProductsPage({
    super.key,
    required this.user,
    this.categoryId,
  });

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductController _controller = ProductController();
  late Future<List<Product>> _productsFuture;
  final String _searchQuery = '';
  String _sortBy = 'nombre';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _productsFuture = _controller.getProducts(widget.categoryId);
  }

  void _updateProductsList() {
    setState(() {
      _productsFuture = _controller.getProducts(widget.categoryId);
    });
  }

  List<Product> _filterAndSortProducts(List<Product> products) {
    // Filter products based on search query
    var filteredProducts = products
        .where((product) =>
            product.nombre.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Sort products
    filteredProducts.sort((a, b) {
      if (_sortBy == 'nombre') {
        return _sortAscending
            ? a.nombre.compareTo(b.nombre)
            : b.nombre.compareTo(a.nombre);
      } else if (_sortBy == 'precio') {
        return _sortAscending
            ? a.precio.compareTo(b.precio)
            : b.precio.compareTo(a.precio);
      }
      return 0;
    });

    return filteredProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearch(updateParent: () => setState(() {})),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                if (_sortBy == value) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = true;
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'nombre',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<String>(
                value: 'precio',
                child: Text('Sort by Price'),
              ),
            ],
          ),
        ],
      ),
      drawer: DrawerWidget(user: widget.user),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          } else {
            var products = _filterAndSortProducts(snapshot.data!);
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
                return Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.network(
                            product.imagen == ''
                                ? 'https://via.placeholder.com/150'
                                : product.imagen,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.nombre,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${product.precio.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green),
                            ),
                            const SizedBox(height: 4),
                            ElevatedButton(
                              child: const Text('View Details'),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/product',
                                  arguments: {
                                    'product': product,
                                    'user': widget.user,
                                  },
                                ).then((_) => _updateProductsList());
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: widget.user.rol == 'administrator'
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/product',
                  arguments: {'user': widget.user},
                ).then((_) => _updateProductsList());
              },
            )
          : null,
    );
  }
}

class ProductSearch extends SearchDelegate<String> {
  final Function updateParent;

  ProductSearch({required this.updateParent});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          updateParent();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Schedule the update for the next frame
    Future.microtask(() => updateParent());
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
