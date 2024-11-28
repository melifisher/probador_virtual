import 'package:flutter/material.dart';
import '../../shared/shared.dart';

class ChooseRecommendationsPage extends StatelessWidget {
  const ChooseRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Products'),
      ),
      drawer: const DrawerWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/recommended_products',
                  arguments: 0,
                );
              },
              child:
                  const Text('Recomendaciones basadas en productos similares'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/recommended_products',
                  arguments: 1,
                );
              },
              child:
                  const Text('Recomendaciones basadas en usuarios similares'),
            ),
          ],
        ),
      ),
    );
  }
}
