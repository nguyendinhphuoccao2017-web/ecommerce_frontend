import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_home.dart';
import '../providers/favorite_provider.dart';
import '../providers/loading_provider.dart';
import '../providers/nav_provider.dart';
import 'size_selection_bottom_sheet.dart';
import '../screens/product_detail_screen.dart';

class HorizontalProductCard extends ConsumerStatefulWidget {
  final ProductHome product;

  const HorizontalProductCard({super.key, required this.product});

  @override
  ConsumerState<HorizontalProductCard> createState() => _HorizontalProductCardState();
}

class _HorizontalProductCardState extends ConsumerState<HorizontalProductCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.product.isFavorite;
  }

  @override
  void didUpdateWidget(covariant HorizontalProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.isFavorite != widget.product.isFavorite) {
      isFavorite = widget.product.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNew = widget.product.tags.contains('New') || widget.product.tags.contains('new');
    bool hasDiscount = !isNew && widget.product.comparePrice > widget.product.salePrice && widget.product.comparePrice > 0;
    int discountPercent = 0;
    if (hasDiscount) {
      discountPercent = ((widget.product.comparePrice - widget.product.salePrice) / widget.product.comparePrice * 100).round();
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
              builder: (context) => ProductDetailScreen(productId: widget.product.id),
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
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        child: Image.network(
                          widget.product.thumbnailUrl ?? 'https://via.placeholder.com/150',
                          height: 104,
                          width: 104,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 104,
                            width: 104,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      if (widget.product.tags.contains('New') || widget.product.tags.contains('new'))
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
                      else if (widget.product.tags.contains('Sale') || widget.product.tags.contains('sale'))
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 8),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.productName,
                                style: const TextStyle(
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  height: 1.0,
                                  color: Color(0xFF222222),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.product.sku ?? 'Mango',
                                style: const TextStyle(
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                  height: 1.0,
                                  color: Color(0xFF9B9B9B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    bool isFilled = index < widget.product.averageRating.round();
                                    return Icon(
                                      isFilled ? Icons.star : Icons.star_border,
                                      color: isFilled ? const Color(0xFFFFBA49) : const Color(0xFF9B9B9B),
                                      size: 14,
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${widget.product.totalReviews})',
                                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  if (isNew)
                                    Text(
                                      '${(widget.product.comparePrice > 0 ? widget.product.comparePrice : widget.product.salePrice).toStringAsFixed(0)}\$',
                                      style: const TextStyle(
                                        fontFamily: 'Metropolis',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        height: 20 / 14,
                                        letterSpacing: 0,
                                        color: Color(0xFF222222),
                                      ),
                                    )
                                  else ...[
                                    if (hasDiscount)
                                      Text(
                                        '${widget.product.comparePrice.toStringAsFixed(0)}\$',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    if (hasDiscount) const SizedBox(width: 4),
                                    Text(
                                      '${widget.product.salePrice.toStringAsFixed(0)}\$',
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -20,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isFavorite ? const Color(0xFFDB3022) : Colors.white,
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
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.white : const Color(0xFF9B9B9B),
                    size: 20,
                  ),
                  onPressed: () async {
                    if (isFavorite) {
                      setState(() {
                        isFavorite = false;
                      });
                      try {
                        await ref.read(favoriteNotifierProvider.notifier).toggle(widget.product.id);
                      } catch (e) {
                        setState(() {
                          isFavorite = true;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    } else {
                      final result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SizeSelectionBottomSheet(productId: widget.product.id),
                      );
                      if (result == true) {
                        setState(() {
                          isFavorite = true;
                        });
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
