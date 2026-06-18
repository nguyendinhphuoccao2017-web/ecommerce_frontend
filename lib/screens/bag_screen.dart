import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/coupon_provider.dart';
import '../widgets/promo_codes_bottom_sheet.dart';
import '../models/coupon.dart';
import 'checkout_screen.dart';
import '../providers/loading_provider.dart';
import '../widgets/loading_overlay.dart';

class BagScreen extends ConsumerStatefulWidget {
  const BagScreen({super.key});

  @override
  ConsumerState<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends ConsumerState<BagScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartProvider.notifier).loadCart());
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final selectedPromo = ref.watch(selectedPromoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: cartState.when(
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return const Center(child: Text('Your bag is empty.'));
          }

          final appliedCoupon = ref.watch(appliedCouponProvider);
          double subtotal = cart.subtotal;
          double discountAmount = 0.0;
          if (appliedCoupon != null) {
            if (appliedCoupon.discountType == 'PERCENTAGE') {
              discountAmount = subtotal * (appliedCoupon.discountValue / 100);
            } else if (appliedCoupon.discountType == 'FIXED_CART') {
              discountAmount = appliedCoupon.discountValue;
            }
          }
          double finalAmount = subtotal - discountAmount;
          if (finalAmount < 0) finalAmount = 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
                  child: const Text(
                    'My Bag',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 360,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cart.items.length > 5 ? 5 : cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      child: SizedBox(
                        height: 104,
                        child: Row(
                          children: [
                          // Image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            child: item.image != null
                                ? Image.network(item.image!, width: 104, height: 104, fit: BoxFit.cover)
                                : Container(width: 104, height: 104, color: Colors.grey[300]),
                          ),
                          const SizedBox(width: 12),
                          // Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.productName,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: PopupMenuButton<String>(
                                          color: Colors.white,
                                          constraints: const BoxConstraints(maxWidth: 170, minWidth: 170),
                                          icon: const Icon(Icons.more_vert, color: Colors.grey, size: 24),
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 8,
                                          offset: const Offset(-140, 24),
                                          onSelected: (value) async {
                                            if (value == 'favorite') {
                                              ref.read(loadingProvider.notifier).state = true;
                                              try {
                                                await ref.read(cartProvider.notifier).toggleFavorite(item.productId, variantOptionId: item.variantOptionId);
                                                await Future.delayed(const Duration(seconds: 2));
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Toggled favorite for ${item.productName}')),
                                                  );
                                                }
                                              } catch (e) {
                                                await Future.delayed(const Duration(seconds: 2));
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Failed to toggle favorite: $e')),
                                                  );
                                                }
                                              } finally {
                                                ref.read(loadingProvider.notifier).state = false;
                                              }
                                            } else if (value == 'delete') {
                                              ref.read(loadingProvider.notifier).state = true;
                                              try {
                                                await ref.read(cartProvider.notifier).removeItem(item.id);
                                                await Future.delayed(const Duration(seconds: 2));
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Removed ${item.productName} from cart')),
                                                  );
                                                }
                                              } catch (e) {
                                                await Future.delayed(const Duration(seconds: 2));
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Failed to remove item: $e')),
                                                  );
                                                }
                                              } finally {
                                                ref.read(loadingProvider.notifier).state = false;
                                              }
                                            }
                                          },
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'favorite',
                                              height: 48,
                                              child: SizedBox(
                                                width: 170,
                                                child: Center(
                                                  child: Text('Add to favorites', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14)),
                                                ),
                                              ),
                                            ),
                                            const PopupMenuDivider(height: 1),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              height: 48,
                                              child: SizedBox(
                                                width: 170,
                                                child: Center(
                                                  child: Text('Delete from the list', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(text: 'Color: ', style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 11)),
                                            TextSpan(
                                              text: '${item.color ?? "N/A"}  ',
                                              style: TextStyle(
                                                color: item.color == 'Vui lòng chọn lại' ? Colors.red : const Color(0xFF222222),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const TextSpan(text: 'Size: ', style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 11)),
                                            TextSpan(
                                              text: '${item.size ?? "N/A"}',
                                              style: TextStyle(
                                                color: item.size == 'Vui lòng chọn lại' ? Colors.red : const Color(0xFF222222),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Quantity Controls (Visual only for now, can implement update logic later)
                                      Row(
                                        children: [
                                          _buildQtyButton(Icons.remove, () {}),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 12),
                                          _buildQtyButton(Icons.add, () {}),
                                        ],
                                      ),
                                      Text(
                                        '${item.salePrice.toStringAsFixed(0)}\$',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                  );
                  },
                ),
              ),
              const Spacer(),
              // Total amounts
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                color: Colors.transparent,
                child: Column(
                  children: [
                    // Promo Code Input Box (triggers Bottom Sheet)
                    Padding(
                      padding: EdgeInsets.only(right: selectedPromo == null ? 18.0 : 0.0),
                      child: SizedBox(
                        height: 36,
                        child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: GestureDetector(
                              onTap: selectedPromo == null ? () async {
                                await showModalBottomSheet<String>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                    ),
                                    child: const FractionallySizedBox(
                                      heightFactor: 0.6,
                                      child: PromoCodesBottomSheet(),
                                    ),
                                  ),
                                );
                              } : null,
                                child: Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.only(left: 20, right: selectedPromo == null ? 40 : 0),
                                alignment: Alignment.centerLeft,
                                child: selectedPromo != null
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedPromo,
                                            style: const TextStyle(
                                              fontFamily: 'Metropolis',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Color(0xFF222222),
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                                            onPressed: () {
                                              ref.read(selectedPromoProvider.notifier).state = null;
                                            },
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'Enter your promo code',
                                        style: TextStyle(color: Colors.grey, fontSize: 14),
                                      ),
                              ),
                            ),
                          ),
                          if (selectedPromo == null)
                            Positioned(
                              right: -18,
                              top: 0,
                              bottom: 0,
                              child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                onPressed: () async {
                                  if (selectedPromo != null) return;
                                  await showModalBottomSheet<String>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).viewInsets.bottom,
                                      ),
                                      child: const FractionallySizedBox(
                                        heightFactor: 0.6,
                                        child: PromoCodesBottomSheet(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total amount:',
                          style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${finalAmount.toStringAsFixed(0)}\$',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDB3022),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text(
                          'CHECK OUT',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFDB3022))),
        error: (e, st) => Center(child: Text('Error loading cart: $e')),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.grey),
      ),
    );
  }
}
