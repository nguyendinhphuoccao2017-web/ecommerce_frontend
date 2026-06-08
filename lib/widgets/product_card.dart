import 'package:flutter/material.dart';
import '../models/product_home.dart';

class ProductCard extends StatelessWidget {
  final ProductHome product;
  final bool isNewSection;

  const ProductCard({super.key, required this.product, this.isNewSection = false});

  @override
  Widget build(BuildContext context) {
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
              if (isNewSection)
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
                        color: Colors.white, // background: #FFFFFF as described in CSS typically means text color when overlaid on dark button
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
              else if (hasDiscount)
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
