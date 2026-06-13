import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_home.dart';
import '../providers/favorite_provider.dart';
import '../providers/loading_provider.dart';
import '../providers/nav_provider.dart';
import 'size_selection_bottom_sheet.dart';
import '../screens/product_detail_screen.dart';

class HorizontalProductCard extends ConsumerWidget {
  final ProductHome product;
  final bool isNewSection;

  const HorizontalProductCard({super.key, required this.product, this.isNewSection = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isNew = product.tags.contains('New') || product.tags.contains('new');
    bool hasDiscount = !isNewSection && !isNew && product.comparePrice > product.salePrice && product.comparePrice > 0;
    int discountPercent = 0;
    if (hasDiscount) {
      discountPercent = ((product.comparePrice - product.salePrice) / product.comparePrice * 100).round();
    }

    return GestureDetector(
      onTap: () async {
        ref.read(loadingProvider.notifier).state = true;
        await Future.delayed(const Duration(seconds: 3));
        ref.read(loadingProvider.notifier).state = false;
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        }
      },
      child: Container(
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
                          if (isNew)
                            Text(
                              '${(product.comparePrice > 0 ? product.comparePrice : product.salePrice).toStringAsFixed(0)}\$',
                              style: const TextStyle(
                                fontFamily: 'Metropolis',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                height: 20 / 14,
                                letterSpacing: 0,
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
        width: 36,
        height: 36,
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
          padding: EdgeInsets.zero,
          icon: Icon(
            product.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: product.isFavorite ? const Color(0xFFDB3022) : const Color(0xFF9B9B9B),
            size: 20,
          ),
          onPressed: () async {
            if (product.isFavorite) {
              try {
                await ref.read(favoriteNotifierProvider.notifier).toggle(product.id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            } else {
              final result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SizeSelectionBottomSheet(productId: product.id),
              );
              if (result == true) {
                // Navigate to favorites tab
                ref.read(navIndexProvider.notifier).state = 3;
              }
            }
          },
        ),
      ),
    ),
  ],
      ),
    ),
    );
  }
}
