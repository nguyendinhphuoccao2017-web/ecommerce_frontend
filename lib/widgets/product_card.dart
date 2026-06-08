import 'package:flutter/material.dart';
import '../models/product_home.dart';

class ProductCard extends StatelessWidget {
  final ProductHome product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    bool hasDiscount = product.comparePrice > product.salePrice && product.comparePrice > 0;
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
              if (hasDiscount)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDB3022),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-$discountPercent%',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (!hasDiscount) // Optional tag for New items
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
                    icon: const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24), // Margin for the overlapping heart
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
          const Text('Brand Name', style: TextStyle(color: Colors.grey, fontSize: 11)),
          Text(
            product.productName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
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
          ),
        ],
      ),
    );
  }
}
