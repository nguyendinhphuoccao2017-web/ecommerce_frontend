import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_home.dart';
import '../providers/favorite_provider.dart';

class ProductCard extends ConsumerWidget {
  final ProductHome product;
  final bool isNewSection;

  const ProductCard({super.key, required this.product, this.isNewSection = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If it's a new section, we don't show the discount logic
    bool hasDiscount = !isNewSection && product.comparePrice > product.salePrice && product.comparePrice > 0;
    int discountPercent = 0;
    if (hasDiscount) {
      discountPercent = ((product.comparePrice - product.salePrice) / product.comparePrice * 100).round();
    }

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.thumbnailUrl ?? 'https://via.placeholder.com/150',
                  height: 184,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 184,
                    width: 150,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              if (product.tags.contains('New') || product.tags.contains('new'))
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 40,
                    height: 24,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/button/new_tag.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Metropolis',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (product.tags.contains('Sale') || product.tags.contains('sale'))
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 40,
                    height: 24,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/button/sale_tag.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '-$discountPercent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Metropolis',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              Positioned(
                bottom: -16,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      product.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: product.isFavorite ? const Color(0xFFDB3022) : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      ref.read(favoriteNotifierProvider.notifier).toggle(product.id);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Margin for the stars to sit directly below the image
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
          const SizedBox(height: 4),
          Text(product.sku ?? 'Unknown Brand', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(
            product.productName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              if (isNewSection)
                Text(
                  '${(product.comparePrice > 0 ? product.comparePrice : product.salePrice).toStringAsFixed(0)}\$',
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else ...[
                if (hasDiscount)
                  Text(
                    '${product.comparePrice.toStringAsFixed(0)}\$',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                if (hasDiscount) const SizedBox(width: 4),
                Text(
                  '${product.salePrice.toStringAsFixed(0)}\$',
                  style: const TextStyle(
                    color: Color(0xFFDB3022),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
