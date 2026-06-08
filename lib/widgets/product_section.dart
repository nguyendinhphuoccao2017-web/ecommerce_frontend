import 'package:flutter/material.dart';
import '../models/product_home.dart';
import 'product_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ProductHome> products;
  final bool isNewSection;

  const ProductSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.products,
    this.isNewSection = false,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Metropolis',
                      color: Color(0xFF222222),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Metropolis',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Text(
                'View all',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Metropolis',
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemBuilder: (context, index) {
              return ProductCard(product: products[index], isNewSection: isNewSection);
            },
          ),
        ),
      ],
    );
  }
}
