import 'package:flutter/material.dart';
import '../../shared/widgets/recommended_products_widget.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Products'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RecommendedProductsWidget(userId: user!.id),
      ),
    );
  }
}
