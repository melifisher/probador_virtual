import 'package:flutter/material.dart';
import '../../shared/shared.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RecommendationsPage extends StatelessWidget {
  final int type;
  const RecommendationsPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Products'),
      ),
      drawer: const DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RecommendedProductsWidget(userId: user!.id, type: type),
      ),
    );
  }
}
