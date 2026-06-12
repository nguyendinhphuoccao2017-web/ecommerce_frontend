import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorite_product.dart';
import '../providers/favorite_provider.dart';

class HorizontalFavoriteProductCard extends ConsumerWidget {
  final FavoriteProduct product;

  const HorizontalFavoriteProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isNew = product.tags.contains('New') || product.tags.contains('new');
    bool hasDiscount = !isNew && product.comparePrice != null && product.comparePrice! > product.salePrice && product.comparePrice! > 0;
    int discountPercent = 0;
    if (hasDiscount) {
      discountPercent = ((product.comparePrice! - product.salePrice) / product.comparePrice! * 100).round();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 104,
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
                Stack(
                  children: [
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
                    if (isNew)
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
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                // Right Side: Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.sku ?? 'Mango',
                              style: const TextStyle(
                                fontFamily: 'Metropolis',
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                                color: Color(0xFF9B9B9B),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                try {
                                  await ref.read(favoriteNotifierProvider.notifier).toggle(product.productId, variantOptionId: product.variantOptionId);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  }
                                }
                              },
                              child: const Icon(Icons.close, color: Colors.grey, size: 20),
                            ),
                          ],
                        ),
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
                        if (product.variantTitle != null)
                          Builder(
                            builder: (context) {
                              final parts = product.variantTitle!.split(', ');
                              String color = parts.isNotEmpty ? parts[0] : '';
                              String size = parts.length > 1 ? parts[1] : '';
                              return RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: Color(0xFF9B9B9B)),
                                  children: [
                                    if (color.isNotEmpty) ...[
                                      const TextSpan(text: 'Color: '),
                                      TextSpan(text: color, style: const TextStyle(color: Color(0xFF222222))),
                                    ],
                                    if (size.isNotEmpty) ...[
                                      const TextSpan(text: '  Size: '),
                                      TextSpan(text: size, style: const TextStyle(color: Color(0xFF222222))),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                if (hasDiscount) ...[
                                  Text(
                                    '${product.comparePrice!.toStringAsFixed(0)}\$',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                if (isNew)
                                  Text(
                                    '${(product.comparePrice != null && product.comparePrice! > 0 ? product.comparePrice! : product.salePrice).toStringAsFixed(0)}\$',
                                    style: const TextStyle(
                                      fontFamily: 'Metropolis',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      height: 20 / 14,
                                      color: Color(0xFF222222),
                                    ),
                                  )
                                else
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
                            Padding(
                              padding: const EdgeInsets.only(right: 36.0),
                              child: Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    bool isFilled = index < product.averageRating.round();
                                    return Icon(
                                      isFilled ? Icons.star : Icons.star_border,
                                      color: isFilled ? const Color(0xFFFFBA49) : const Color(0xFF9B9B9B),
                                      size: 14,
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${product.totalReviews})',
                                    style: const TextStyle(fontFamily: 'Metropolis', color: Color(0xFF9B9B9B), fontSize: 10),
                                  ),
                                ],
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
          ),
          Positioned(
            bottom: -16,
            right: 0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFDB3022),
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
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {
                  // Add to cart logic
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
