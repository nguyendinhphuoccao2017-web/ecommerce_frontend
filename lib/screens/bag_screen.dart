import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/coupon_provider.dart';
import '../widgets/promo_codes_bottom_sheet.dart';
import 'checkout_screen.dart';

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
        title: const Text(
          'My Bag',
          style: TextStyle(
            color: Colors.black,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: cartState.when(
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return const Center(child: Text('Your bag is empty.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
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
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                                          icon: const Icon(Icons.more_vert, color: Colors.grey, size: 24),
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 8,
                                          offset: const Offset(-150, 0), // Shift left so it overlays cleanly
                                          onSelected: (value) async {
                                            if (value == 'favorite') {
                                              await ref.read(cartProvider.notifier).toggleFavorite(item.productId);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Toggled favorite for ${item.productName}')),
                                                );
                                              }
                                            } else if (value == 'delete') {
                                              await ref.read(cartProvider.notifier).removeItem(item.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Removed ${item.productName} from cart')),
                                                );
                                              }
                                            }
                                          },
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'favorite',
                                              height: 48,
                                              child: Text('Add to favorites', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14)),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              height: 48,
                                              child: Text('Delete from the list', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.variantTitle != null)
                                    Text(
                                      item.variantTitle!,
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                                          Text('${item.quantity}'),
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
                    );
                  },
                ),
              ),
              // Total amounts
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Promo Code Input Box (triggers Bottom Sheet)
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
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
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerLeft,
                                child: selectedPromo != null
                                    ? Text(
                                        selectedPromo,
                                        style: const TextStyle(
                                          fontFamily: 'Metropolis',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Color(0xFF222222),
                                        ),
                                      )
                                    : const Text(
                                        'Enter your promo code',
                                        style: TextStyle(color: Colors.grey, fontSize: 14),
                                      ),
                              ),
                            ),
                          ),
                          if (selectedPromo != null)
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                              onPressed: () {
                                ref.read(selectedPromoProvider.notifier).state = null;
                              },
                            )
                          else
                            Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                onPressed: () async {
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total amount:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '${cart.subtotal.toStringAsFixed(0)}\$',
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
        loading: () => const Center(child: CircularProgressIndicator()),
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
