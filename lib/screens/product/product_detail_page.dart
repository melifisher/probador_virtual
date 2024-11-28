import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../shared/shared.dart';
import '../client/product_rental_page.dart';
import '../../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../client/product_order_rental_page.dart';
import '../probador/video_processing_screen.dart';

class ProductDetailView extends StatefulWidget {
  final Product? product;

  const ProductDetailView({super.key, this.product});

  @override
  _ProductDetailViewState createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final ProductController _controller = ProductController();
  final CategoryController _categoryController = CategoryController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _imagenController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _tallaController;
  late TextEditingController _colorController;
  bool _isEditing = false;
  bool _alquilerPorPrendaSeleccionado = false;
  List<Category> _categories = [];
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _imagenController =
        TextEditingController(text: widget.product?.imagen ?? '');
    _nameController = TextEditingController(text: widget.product?.nombre ?? '');
    _priceController =
        TextEditingController(text: widget.product?.precio.toString() ?? '');
    _tallaController =
        TextEditingController(text: widget.product?.talla.join(" "));
    _colorController =
        TextEditingController(text: widget.product?.color.join(" "));
    _isEditing = widget.product == null;
    _loadCategoriesAndProduct();
  }

  Future<void> _loadCategoriesAndProduct() async {
    await _loadCategories();
    await _loadSelectedCategory();
    setState(() {});
  }

  Future<void> _loadCategories() async {
    _categories = await _categoryController.getCategories();
    setState(() {});
  }

  Future<void> _loadSelectedCategory() async {
    if (widget.product != null) {
      _selectedCategory = _categories.firstWhere(
        (category) => category.id == widget.product!.categoriaId,
        orElse: () => _categories.first,
      );
    } else {
      _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.product == null ? 'Add Product' : 'Product Details'),
        actions: [
          if (user?.rol == 'administrator' && widget.product != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveProduct();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _isEditing
                    ? TextFormField(
                        controller: _imagenController,
                        decoration:
                            const InputDecoration(labelText: 'Image URL'),
                      )
                    : widget.product!.imagen == ''
                        ? Image.asset(
                            'assets/placeholder200.png',
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                          )
                        : Image.network(
                            widget.product!.imagen,
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                          ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tallaController,
                decoration: const InputDecoration(labelText: 'Tallas'),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the sizes';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Colors'),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the colors';
                  }
                  return null;
                },
              ),
              if (_isEditing)
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                ),
              if (!_isEditing)
                TextFormField(
                  controller:
                      TextEditingController(text: _selectedCategory?.nombre),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  enabled: false,
                ),
              const Spacer(),
              if (user?.rol == 'client' && user != null)
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Verificar si ya existe una opción de alquiler guardada
                      final prefs = await SharedPreferences.getInstance();
                      final alquilerOption = prefs.getString('alquilerOption');

                      // Mostrar diálogo si no hay opción guardada
                      if (alquilerOption == null) {
                        await _showRentalOptionsDialog();
                      } else if (alquilerOption == 'prenda') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductRentalPage(
                              product: widget.product!,
                              user: user,
                            ),
                          ),
                        );
                      } else if (alquilerOption == 'pedido') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductOrderRentalPage(
                              product: widget.product!,
                              user: user,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Alquilar'),
                  ),
                ),
              if (user?.rol == 'client' && user != null)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoProcessingScreen(
                            garmentUrl: widget.product!.modeloUrl,
                          ),
                        ),
                      );
                    },
                    child: const Text('Probar Producto'),
                  ),
                ),  
              if (user?.rol == 'administrator' &&
                  widget.product != null &&
                  !_isEditing) ...[
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await _controller.deleteProduct(widget.product!.id);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
              if (user?.rol == 'administrator' &&
                  widget.product == null &&
                  _isEditing) ...[
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        Product product = Product(
                          id: widget.product?.id ?? 0,
                          nombre: _nameController.text,
                          precio: double.parse(_priceController.text),
                          talla: _tallaController.text.split(' '),
                          color: _colorController.text.split(' '),
                          imagen: _imagenController.text,
                          disponible: widget.product?.disponible ?? true,
                          modeloUrl: widget.product?.modeloUrl ?? '',
                          categoriaId: _selectedCategory?.id ?? 1,
                        );
                        try {
                          if (widget.product == null) {
                            await _controller.createProduct(product);
                            Navigator.pop(context);
                          } else {
                            await _controller.updateProduct(product);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      Product product = Product(
        id: widget.product?.id ?? 0,
        nombre: _nameController.text,
        precio: double.parse(_priceController.text),
        talla: _tallaController.text.split(' '),
        color: _colorController.text.split(' '),
        imagen: _imagenController.text,
        disponible: widget.product?.disponible ?? true,
        modeloUrl: widget.product?.modeloUrl ?? '',
        categoriaId: _selectedCategory?.id ?? 1,
      );
      try {
        if (widget.product == null) {
          await _controller.createProduct(product);
        } else {
          await _controller.updateProduct(product);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showRentalOptionsDialog() async {
    final selectedOption = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Cómo deseas alquilar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('prenda'),
              child: Text('Alquilar por prenda'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('pedido'),
              child: Text('Alquiler por pedido'),
            ),
          ],
        );
      },
    );

    // Verificar la opción seleccionada
    if (selectedOption != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alquilerOption', selectedOption);

      if (selectedOption == 'prenda') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductRentalPage(
              product: widget.product!,
              user: Provider.of<AuthProvider>(context, listen: false).user!,
            ),
          ),
        );
      } else if (selectedOption == 'pedido') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductOrderRentalPage(
              product: widget.product!,
              user: Provider.of<AuthProvider>(context, listen: false).user!,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _tallaController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}
