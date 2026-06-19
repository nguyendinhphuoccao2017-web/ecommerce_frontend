import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';
import 'adding_shipping_address_screen.dart';

class ShippingAddressesScreen extends ConsumerWidget {
  const ShippingAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context),
      body: checkoutState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDB3022)))
          : ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 31, bottom: 100),
              itemCount: checkoutState.addresses.length,
              itemBuilder: (context, index) {
                final address = checkoutState.addresses[index];
                final isSelected = address.id == checkoutState.selectedAddress?.id;

                return Container(
                  width: double.infinity,
                  height: 140,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 25,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        ref.read(checkoutProvider.notifier).selectAddress(address);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 28, right: 23, top: 18, bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  address.fullName ?? 'Jane Doe',
                                  style: const TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF222222),
                                    height: 20 / 14,
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddingShippingAddressScreen(address: address)),
                                    );
                                  },
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontFamily: 'Metropolis',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFDB3022),
                                      height: 20 / 14,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${address.addressLine1}\n${address.city}, ${address.state ?? ''} ${address.postalCode}, ${address.country}',
                              style: const TextStyle(
                                fontFamily: 'Metropolis',
                                fontSize: 14,
                                height: 20 / 14,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (!isSelected) {
                                      ref.read(checkoutProvider.notifier).selectAddress(address);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(top: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF222222) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                      border: isSelected 
                                          ? null 
                                          : Border.all(color: const Color(0xFF9B9B9B), width: 2),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                const Text(
                                  'Use as the shipping address',
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 14,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddingShippingAddressScreen()));
          },
          backgroundColor: const Color(0xFF222222),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Shipping Addresses',
        style: TextStyle(
          fontFamily: 'Metropolis',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          height: 22 / 18,
          color: Color(0xFF222222),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222222)),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }
}
