import 'package:flutter/material.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';

class CategoryDetailView extends StatefulWidget {
  final Category? category;
  final String userRole;

  const CategoryDetailView({super.key, this.category, required this.userRole});

  @override
  _CategoryDetailViewState createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView> {
  final CategoryController _controller = CategoryController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category?.nombre ?? '');
    _isEditing = widget.category == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.category == null ? 'Add Category' : 'Category Details'),
        actions: [
          if (widget.userRole == 'administrator' && widget.category != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveCategory();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              if (widget.userRole == 'administrator' &&
                  widget.category != null &&
                  !_isEditing) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _controller.deleteCategory(widget.category!.id);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
              if (widget.userRole == 'administrator' &&
                  widget.category == null &&
                  _isEditing) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Category category = Category(
                        id: widget.category?.id ?? 0,
                        nombre: _nameController.text,
                      );
                      try {
                        if (widget.category == null) {
                          await _controller.createCategory(category);
                        } else {
                          await _controller.updateCategory(category);
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      Category category = Category(
        id: widget.category?.id ?? 0,
        nombre: _nameController.text,
      );
      try {
        if (widget.category == null) {
          await _controller.createCategory(category);
        } else {
          await _controller.updateCategory(category);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}