import 'package:flutter/material.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';

class ProductDetailView extends StatefulWidget {
  final Product? product;

  ProductDetailView({this.product});

  @override
  _ProductDetailViewState createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final ProductController _controller = ProductController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.nombre ?? '');
    _priceController =
        TextEditingController(text: widget.product?.precio.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.descripcion ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Product product = Product(
                      id: widget.product?.id ?? 0,
                      nombre: _nameController.text,
                      precio: double.parse(_priceController.text),
                      descripcion: _descriptionController.text,
                      talla: widget.product?.talla ?? '',
                      imagen: widget.product?.imagen ?? '',
                      disponible: widget.product?.disponible ?? true,
                      modeloUrl: widget.product?.modeloUrl ?? '',
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
                },
                child: Text(widget.product == null ? 'Add' : 'Update'),
              ),
              if (widget.product != null) ...[
                SizedBox(height: 20),
                ElevatedButton(
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
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
