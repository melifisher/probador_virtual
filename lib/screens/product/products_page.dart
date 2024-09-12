import 'package:flutter/material.dart';
import 'package:probador_virtual/controllers/product_controller.dart';
import '../../models/product.dart';
import '../../models/user.dart';

class ProductsPage extends StatefulWidget {
  final User user;
  const ProductsPage({super.key, required this.user});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductController _controller = ProductController();
  late Future<List<Product>> _productsFuture;
  String _searchQuery = '';
  String _sortBy = 'nombre';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _productsFuture = _controller.getProducts();
  }

  void _updateProductsList() {
    setState(() {
      _productsFuture = _controller.getProducts();
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
        title: Text('Product Catalog'),
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
              PopupMenuItem<String>(
                value: 'nombre',
                child: Text('Sort by Name'),
              ),
              PopupMenuItem<String>(
                value: 'precio',
                child: Text('Sort by Price'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Welcome, ${widget.user.nombre}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Cart'),
              onTap: () {
                // TODO: Implement cart functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Order History'),
              onTap: () {
                // TODO: Implement order history functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                // TODO: Implement logout functionality
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
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
            var products = _filterAndSortProducts(snapshot.data!);
            return GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        child: Container(
                          width: double.infinity,
                          child: Image.network(
                            'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.nombre,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$${product.precio.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.green),
                            ),
                            SizedBox(height: 4),
                            ElevatedButton(
                              child: Text('View Details'),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/product',
                                  arguments: {
                                    'product': product,
                                    'userRole': widget.user.rol,
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
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/product',
                  arguments: {'userRole': widget.user.rol},
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
        icon: Icon(Icons.clear),
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
      icon: Icon(Icons.arrow_back),
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
