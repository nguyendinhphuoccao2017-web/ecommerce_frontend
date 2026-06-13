import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/product_detail_provider.dart';
import '../models/product_detail.dart';
import '../models/variant_option.dart';
import '../widgets/product_card.dart';
import 'login_screen.dart';

import '../widgets/size_selection_bottom_sheet.dart';
import '../providers/loading_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final PageController _pageController = PageController();
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _isLoggedIn() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token != null;
  }

  void _openSizeSelectionBottomSheet(BuildContext context, {required String buttonText, required List<VariantOption> variants}) async {
    ref.read(loadingProvider.notifier).state = true;
    await Future.delayed(const Duration(seconds: 3));
    ref.read(loadingProvider.notifier).state = false;

    if (!mounted) return;

    final variantId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizeSelectionBottomSheet(
        productId: widget.productId,
        buttonText: buttonText,
        isFavoriteMode: false,
      ),
    );

    if (variantId != null && mounted) {
      final selectedVariant = variants.firstWhere((v) => v.id == variantId);
      ref.read(selectedVariantNotifierProvider(widget.productId).notifier).selectVariant(selectedVariant);
      if (buttonText == 'ADD TO CART') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
      }
    }
  }

  void _handleAddToCart(ProductDetail product, List<VariantOption> variants) async {
    bool loggedIn = await _isLoggedIn();
    if (!loggedIn && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }
    
    final selectedVariant = ref.read(selectedVariantNotifierProvider(widget.productId));
    if (selectedVariant == null) {
      _openSizeSelectionBottomSheet(context, buttonText: 'ADD TO CART', variants: variants);
      return;
    }

    // TODO: Call Add to Cart API
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  void _handleFavorite(ProductDetail product) async {
    bool loggedIn = await _isLoggedIn();
    if (!loggedIn && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }
    // TODO: Call Toggle Favorite API and invalidate provider to refresh
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favorite toggled')));
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(productDetailProvider(widget.productId));
    final variantsAsync = ref.watch(productVariantsProvider(widget.productId));
    final relatedAsync = ref.watch(relatedProductsProvider(widget.productId));
    final selectedVariant = ref.watch(selectedVariantNotifierProvider(widget.productId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          detailAsync.value?.productName ?? '',
          style: const TextStyle(
            color: Color(0xFF222222), 
            fontFamily: 'Metropolis', 
            fontSize: 18, 
            fontWeight: FontWeight.w400,
            height: 22 / 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: detailAsync.when(
        data: (product) {
          double displayPrice = selectedVariant?.salePrice ?? product.salePrice;
          List<VariantOption> safeVariants = variantsAsync.value ?? [];
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gallery
                SizedBox(
                  height: 450,
                  child: product.galleries.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: product.galleries.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              product.galleries[index],
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Container(color: Colors.grey[200]),
                ),
                
                // Variants Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (safeVariants.isNotEmpty) {
                                    _openSizeSelectionBottomSheet(context, buttonText: 'SELECT', variants: safeVariants);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedVariant != null 
                                          ? (selectedVariant.title.contains(', ') ? selectedVariant.title.split(', ').last : selectedVariant.title) 
                                          : 'Size',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black54),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (safeVariants.isNotEmpty) {
                                    _openSizeSelectionBottomSheet(context, buttonText: 'SELECT', variants: safeVariants);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedVariant != null 
                                          ? (selectedVariant.title.contains(', ') ? selectedVariant.title.split(', ').first : 'Color') 
                                          : 'Color',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black54),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            product.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: product.isFavorite ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _handleFavorite(product),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title & Price
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.sku != null && product.sku.isNotEmpty ? product.sku : product.productName,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.sku != null && product.sku.isNotEmpty ? product.productName : product.shortDescription,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${displayPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                // Ratings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < product.averageRating.round() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.totalReviews})',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    product.productDescription != null && product.productDescription.isNotEmpty 
                        ? product.productDescription 
                        : product.shortDescription,
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                  ),
                ),

                // Add to Cart Box
                Container(
                  width: double.infinity,
                  height: 112,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        width: 134,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDB3022),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => _handleAddToCart(product, safeVariants),
                            child: const Text(
                              'ADD TO CART',
                              style: TextStyle(
                                fontFamily: 'Metropolis',
                                color: Colors.white, 
                                fontSize: 14, 
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Shipping info
                const ListTile(
                  title: Text('Shipping info', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16)),
                  trailing: Icon(Icons.chevron_right),
                ),
                const Divider(height: 1),

                // Support
                const ListTile(
                  title: Text('Support', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16)),
                  trailing: Icon(Icons.chevron_right),
                ),
                const Divider(height: 1),

                // Related Products
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'You can also like this',
                        style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, color: Color(0xFF222222)),
                      ),
                      relatedAsync.when(
                        data: (list) => Text('${list.length} items', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: Color(0xFF9B9B9B))),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: relatedAsync.when(
                    data: (relatedList) {
                      if (relatedList.isEmpty) {
                        return const Center(child: Text('No related products'));
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: relatedList.length,
                        itemBuilder: (context, index) {
                          final p = relatedList[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: SizedBox(
                              width: 150,
                              child: ProductCard(
                                product: p,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e')),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
