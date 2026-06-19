import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_home.dart';
import '../providers/favorite_provider.dart';
import '../providers/loading_provider.dart';
import '../providers/nav_provider.dart';
import 'size_selection_bottom_sheet.dart';

import '../screens/product_detail_screen.dart';

class ProductCard extends ConsumerStatefulWidget {
  final ProductHome product;
  final bool isNewSection;

  const ProductCard({super.key, required this.product, this.isNewSection = false});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.product.isFavorite;
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      isFavorite = widget.product.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNew = widget.product.tags.contains('New') || widget.product.tags.contains('new');
    // If it's a new section, we don't show the discount logic
    bool hasDiscount = !widget.isNewSection && !isNew && widget.product.comparePrice > widget.product.salePrice && widget.product.comparePrice > 0;
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
                  widget.product.thumbnailUrl ?? 'https://via.placeholder.com/150',
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
                        letterSpacing: 0,
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
                        setState(() { isFavorite = false; });
                        try {
                          await ref.read(favoriteNotifierProvider.notifier).toggle(widget.product.id);
                        } catch (e) {
                          setState(() { isFavorite = true; });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      } else {
                        // Optimistically set to true if they pick a size and confirm
                        // But wait, SizeSelectionBottomSheet handles the toggle.
                        // We can just await it, but during the bottom sheet it doesn't show loading overlay.
                        // The loading overlay shows inside SizeSelectionBottomSheet _onSubmit.
                        // To make the heart red DURING the loading overlay in BottomSheet,
                        // we can't easily do it unless we change the state when they hit submit.
                        // Actually, if we pass a callback to SizeSelectionBottomSheet or just let it update global state.
                        final result = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SizeSelectionBottomSheet(productId: widget.product.id),
                        );
                        if (result == true) {
                          setState(() { isFavorite = true; });
                        }
                      }
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
          const SizedBox(height: 4),
          Text(widget.product.sku ?? 'Mango', style: const TextStyle(fontFamily: 'Metropolis', color: Color(0xFF9B9B9B), fontSize: 11)),
          Text(
            widget.product.productName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              if (isNewSection || isNew)
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
    ));
  }
}
