import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:probador_virtual/controllers/category_controller.dart';
import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../shared/shared.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategoryController _controller = CategoryController();
  late Future<List<Category>> _categoriesFuture;
  final String _searchQuery = '';
  String _sortBy = 'nombre';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _controller.getCategories();
  }

  void _updateCategoriesList() {
    setState(() {
      _categoriesFuture = _controller.getCategories();
    });
  }

  Future<String?> _getFirstProductImage(int categoryId) async {
    try {
      final products = await _controller.getProductsByCategory(categoryId);
      if (products.isNotEmpty) {
        for (var product in products) {
          if (product.imagen != '') {
            return product.imagen;
          }
        }
      }
    } catch (e) {
      print('Error fetching first product image: $e');
    }
    return null;
  }

  List<Category> _filterAndSortCategories(List<Category> categories) {
    // Filter categories based on search query
    var filteredCategories = categories
        .where((category) =>
            category.nombre.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Sort categories
    filteredCategories.sort((a, b) {
      if (_sortBy == 'nombre') {
        return _sortAscending
            ? a.nombre.compareTo(b.nombre)
            : b.nombre.compareTo(a.nombre);
      }
      return 0;
    });

    return filteredCategories;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CategorySearch(updateParent: () => setState(() {})),
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
            ],
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories available'));
          } else {
            var categories = _filterAndSortCategories(snapshot.data!);
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                Category category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/products',
                      arguments: category.id,
                    );
                  },
                  child: Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: FutureBuilder<String?>(
                              future: _getFirstProductImage(category.id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError ||
                                    !snapshot.hasData) {
                                  return Image.asset(
                                    'assets/placeholder200.png',
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/placeholder200.png',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (user?.rol == 'administrator')
                                ElevatedButton(
                                  child: const Text('View Details'),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/category',
                                      arguments: category,
                                    ).then((_) => _updateCategoriesList());
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: user?.rol == 'administrator'
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/category',
                  arguments: {'userRole': user?.rol},
                ).then((_) => _updateCategoriesList());
              },
            )
          : null,
    );
  }
}

class CategorySearch extends SearchDelegate<String> {
  final Function updateParent;

  CategorySearch({required this.updateParent});

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
