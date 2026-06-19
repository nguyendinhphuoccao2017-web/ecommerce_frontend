import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';
import '../providers/coupon_provider.dart';
import 'shipping_addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'success_screen.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutProvider);
    final appliedCoupon = ref.watch(appliedCouponProvider);

    if (checkoutState.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: const Text('Checkout', style: TextStyle(fontFamily: 'Metropolis', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFDB3022))),
      );
    }

    if (checkoutState.error != null || checkoutState.initData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: const Text('Checkout', style: TextStyle(fontFamily: 'Metropolis', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(checkoutState.error ?? 'Failed to load checkout data.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(checkoutProvider.notifier).loadInitData(),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      );
    }

    final initData = checkoutState.initData!;
    final cart = initData.cart;

    double orderAmount = cart?.subtotal ?? 0.0;
    
    double deliveryAmount = 15.0; // Default fallback
    if (checkoutState.selectedDeliveryMethodId != null && initData.shippingRates.isNotEmpty) {
      deliveryAmount = initData.shippingRates.first.price;
    }

    double discountAmount = 0.0;
    if (appliedCoupon != null) {
      if (appliedCoupon.discountType == 'PERCENTAGE') {
        discountAmount = orderAmount * (appliedCoupon.discountValue / 100);
      } else if (appliedCoupon.discountType == 'FIXED_CART') {
        discountAmount = appliedCoupon.discountValue;
      }
    }

    double afterDiscount = orderAmount - discountAmount;
    if (afterDiscount < 0) afterDiscount = 0;
    
    double summaryAmount = afterDiscount + deliveryAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontFamily: 'Metropolis', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shipping address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (initData.defaultAddress != null)
              _buildAddressCard(context, initData.defaultAddress)
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingAddressesScreen()));
                },
                child: const Text('Add Shipping Address'),
              ),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
                  },
                  child: const Text('Change', style: TextStyle(color: Color(0xFFDB3022))),
                )
              ],
            ),
            const SizedBox(height: 16),
            if (initData.defaultPaymentMethod != null)
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                      ]
                    ),
                    child: Center(
                      child: initData.defaultPaymentMethod!.cardType.toLowerCase() == 'visa'
                          ? Image.network('https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/payment/Visa%20Logo.png', height: 20)
                          : Image.network('https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/payment/mastercard.png', height: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('**** **** **** ${initData.defaultPaymentMethod!.lastFourDigits}', style: const TextStyle(fontSize: 14)),
                ],
              )
            else
              const Text('No default payment method set.', style: TextStyle(fontSize: 14)),
              
            const SizedBox(height: 32),
            const Text('Delivery method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Hybrid Delivery Methods
            Row(
              children: [
                if (initData.shippingZones.isNotEmpty)
                  _buildDeliveryMethod(
                    context, 
                    ref, 
                    initData.shippingZones[0].id, 
                    'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/delivery/fedex.png', 
                    initData.shippingZones[0].name, 
                    checkoutState.selectedDeliveryMethodId == initData.shippingZones[0].id
                  ),
                const SizedBox(width: 16),
                if (initData.shippingZones.length > 1)
                  _buildDeliveryMethod(
                    context, 
                    ref, 
                    initData.shippingZones[1].id, 
                    'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/delivery/usps.png', 
                    initData.shippingZones[1].name, 
                    checkoutState.selectedDeliveryMethodId == initData.shippingZones[1].id
                  ),
                const SizedBox(width: 16),
                if (initData.shippingZones.length > 2)
                  _buildDeliveryMethod(
                    context, 
                    ref, 
                    initData.shippingZones[2].id, 
                    'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/delivery/dhl.png', 
                    initData.shippingZones[2].name, 
                    checkoutState.selectedDeliveryMethodId == initData.shippingZones[2].id
                  ),
              ],
            ),
            const SizedBox(height: 32),
            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('${orderAmount.toStringAsFixed(0)}\$', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            if (discountAmount > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Discount:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('-${discountAmount.toStringAsFixed(0)}\$', style: const TextStyle(fontSize: 16, color: Color(0xFFDB3022), fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('${deliveryAmount.toStringAsFixed(0)}\$', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Summary:', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text('${summaryAmount.toStringAsFixed(0)}\$', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  bool success = await ref.read(checkoutProvider.notifier).submitOrder();
                  if (success) {
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (_) => const SuccessScreen()),
                        (route) => false,
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ref.read(checkoutProvider).error ?? 'Error submitting order')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDB3022),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('SUBMIT ORDER', style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, dynamic address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(address.fullName ?? 'Jane Doe', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingAddressesScreen()));
                },
                child: const Text('Change', style: TextStyle(color: Color(0xFFDB3022))),
              )
            ],
          ),
          Text('${address.addressLine1}\n${address.city}, ${address.state ?? ''} ${address.postalCode}, ${address.country}', style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethod(BuildContext context, WidgetRef ref, String methodId, String imageUrl, String duration, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(checkoutProvider.notifier).selectDeliveryMethod(methodId);
      },
      child: Container(
        width: 100,
        height: 72,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F0F0) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xFFDB3022), width: 1.5) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2), 
                    blurStyle: BlurStyle.inner,
                  ),
                ]
              : [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(imageUrl, height: 20, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(duration, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
