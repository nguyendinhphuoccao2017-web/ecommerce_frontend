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
      appBar: AppBar(
        title: const Text('Shipping Addresses', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: checkoutState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: checkoutState.addresses.length,
              itemBuilder: (context, index) {
                final address = checkoutState.addresses[index];
                final isSelected = address.id == checkoutState.selectedAddress?.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      ref.read(checkoutProvider.notifier).selectAddress(address);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(address.fullName ?? 'Jane Doe', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  minimumSize: const Size(60, 40),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AddingShippingAddressScreen(address: address)),
                                  );
                                },
                                child: const Text('Edit', style: TextStyle(color: Color(0xFFDB3022))),
                              )
                            ],
                          ),
                          Text(address.fullAddress, style: const TextStyle(fontSize: 14, height: 1.5)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: const Color(0xFFDB3022),
                                onChanged: (value) {
                                  if (value == true) {
                                    ref.read(checkoutProvider.notifier).selectAddress(address);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              const Text('Use as the shipping address'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddingShippingAddressScreen()));
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
