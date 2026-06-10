import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_home.dart';
import '../providers/favorite_provider.dart';

class HorizontalProductCard extends ConsumerWidget {
  final ProductHome product;

  const HorizontalProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool hasDiscount = product.comparePrice > product.salePrice && product.comparePrice > 0;

    return Container(
      width: double.infinity,
      height: 104,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Side: Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Image.network(
              product.thumbnailUrl ?? 'https://via.placeholder.com/150',
              width: 104,
              height: 104,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 104,
                height: 104,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          // Right Side: Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontFamily: 'Metropolis',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFF222222),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.sku ?? 'Brand',
                        style: const TextStyle(
                          fontFamily: 'Metropolis',
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < product.averageRating.round() ? Icons.star : Icons.star_border,
                              color: const Color(0xFFFFBA49),
                              size: 14,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.totalReviews})',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (hasDiscount) ...[
                            Text(
                              '${product.comparePrice.toStringAsFixed(0)}\$',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '${product.salePrice.toStringAsFixed(0)}\$',
                            style: const TextStyle(
                              color: Color(0xFFDB3022),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(favoriteNotifierProvider.notifier).toggle(product.id);
                        },
                        child: Icon(
                          product.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: product.isFavorite ? const Color(0xFFDB3022) : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
