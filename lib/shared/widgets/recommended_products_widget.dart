import 'package:flutter/material.dart';
import '../../services/recommendation_service.dart';
import '../../models/product.dart';
import '../../shared/widgets/product_card.dart';

class RecommendedProductsWidget extends StatefulWidget {
  final int userId;
  final int type;

  const RecommendedProductsWidget({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  State<RecommendedProductsWidget> createState() =>
      _RecommendedProductsWidgetState();
}

class _RecommendedProductsWidgetState extends State<RecommendedProductsWidget> {
  late final RecommendationService _recommendationService;
  List<Product>? _recommendations;

  @override
  void initState() {
    super.initState();
    _recommendationService = RecommendationService(type: widget.type);
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations =
          await _recommendationService.getRecommendations(widget.userId);
      setState(() {
        _recommendations = recommendations;
      });
    } catch (e) {
      print('Error al cargar recomendaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recommendations == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Recomendados para ti',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cardWidth = 180.0; // Ancho deseado para cada tarjeta
              final crossAxisCount = (width / cardWidth).floor();

              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _recommendations!.length,
                itemBuilder: (context, index) {
                  final product = _recommendations![index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/product',
                        arguments: product,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
