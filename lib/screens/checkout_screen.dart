import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/checkout_provider.dart';
import '../providers/coupon_provider.dart';
import '../models/customer_address.dart';
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
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFDB3022))),
      );
    }

    if (checkoutState.error != null || checkoutState.initData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: _buildAppBar(),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDB3022)),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      );
    }

    final initData = checkoutState.initData!;
    final cart = initData.cart;
    final displayAddress = checkoutState.selectedAddress ?? initData.defaultAddress;

    double baseOrderAmount = cart?.subtotal ?? 0.0;
    double discountAmount = 0.0;
    if (appliedCoupon != null) {
      if (appliedCoupon.discountType == 'PERCENTAGE') {
        discountAmount = baseOrderAmount * (appliedCoupon.discountValue / 100);
      } else if (appliedCoupon.discountType == 'FIXED_CART') {
        discountAmount = appliedCoupon.discountValue;
      }
    }

    double orderAmount = baseOrderAmount - discountAmount;
    if (orderAmount < 0) orderAmount = 0;
    
    double deliveryAmount = 15.0; // Default fallback
    if (checkoutState.selectedDeliveryMethodId != null && initData.shippingRates.isNotEmpty) {
      try {
        deliveryAmount = initData.shippingRates.firstWhere((r) => r.shippingZoneId == checkoutState.selectedDeliveryMethodId).price;
      } catch (e) {
        // ignore fallback
      }
    }

    double summaryAmount = orderAmount + deliveryAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 31, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping address
              const Text(
                'Shipping address',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 21),
              
              if (displayAddress != null)
                _buildAddressCard(context, displayAddress)
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingAddressesScreen()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDB3022)),
                  child: const Text('Add Shipping Address', style: TextStyle(color: Colors.white)),
                ),
                
              const SizedBox(height: 57),
              
              // Payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment',
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1,
                      color: Color(0xFF222222),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 23),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
                      },
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFFDB3022),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 17),
              
              () {
                String paymentMethod = checkoutState.selectedPaymentMethod;
                String lastFourDigits = paymentMethod.length >= 4 ? paymentMethod.substring(paymentMethod.length - 4) : '';
                bool isVisa = lastFourDigits == '4546';
                String logoUrl = isVisa 
                    ? 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/payment/visa_checkout.png'
                    : 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/payment/mastercard_checkout.png';

                return Row(
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
                        child: _buildCachedImage(logoUrl, width: 32),
                      ),
                    ),
                    const SizedBox(width: 17),
                    Text(
                      '**** **** **** $lastFourDigits',
                      style: const TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 14,
                        letterSpacing: -0.15,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                );
              }(),
                
              const SizedBox(height: 58),
              
              // Delivery method
              const Text(
                'Delivery method',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 21),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (initData.shippingZones.isNotEmpty)
                    _buildDeliveryMethod(
                      context, 
                      ref, 
                      initData.shippingZones[0].id, 
                      _getDeliveryLogoUrl(initData.shippingZones[0].displayName), 
                      '2-3 days',
                      checkoutState.selectedDeliveryMethodId == initData.shippingZones[0].id
                    ),
                  if (initData.shippingZones.length > 1)
                    _buildDeliveryMethod(
                      context, 
                      ref, 
                      initData.shippingZones[1].id, 
                      _getDeliveryLogoUrl(initData.shippingZones[1].displayName), 
                      '2-3 days',
                      checkoutState.selectedDeliveryMethodId == initData.shippingZones[1].id
                    ),
                  if (initData.shippingZones.length > 2)
                    _buildDeliveryMethod(
                      context, 
                      ref, 
                      initData.shippingZones[2].id, 
                      _getDeliveryLogoUrl(initData.shippingZones[2].displayName), 
                      '2-3 days',
                      checkoutState.selectedDeliveryMethodId == initData.shippingZones[2].id
                    ),
                ],
              ),
              
              const SizedBox(height: 52),
              
              // Summary Block
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Order:', style: TextStyle(fontFamily: 'Metropolis', fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF9B9B9B))),
                  Text('${orderAmount.toStringAsFixed(0)}\$', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delivery:', style: TextStyle(fontFamily: 'Metropolis', fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF9B9B9B))),
                  Text('${deliveryAmount.toStringAsFixed(0)}\$', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                ],
              ),
              const SizedBox(height: 17),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Summary:', style: TextStyle(fontFamily: 'Metropolis', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF9B9B9B))),
                  Text('${summaryAmount.toStringAsFixed(0)}\$', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
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
                  child: const Text('SUBMIT ORDER', style: TextStyle(fontFamily: 'Metropolis', color: Colors.white, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Checkout',
        style: TextStyle(
          fontFamily: 'Metropolis',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          height: 22 / 18,
          color: Color(0xFF222222),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF222222)),
      centerTitle: true,
    );
  }

  String _getDeliveryLogoUrl(String displayName) {
    if (displayName.toLowerCase().contains('fedex')) {
      return 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/delivery/fedex_png.png';
    } else if (displayName.toLowerCase().contains('usps')) {
      return 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/delivery/usps_com.png';
    } else if (displayName.toLowerCase().contains('dhl')) {
      return 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/delivery/dhl_png.png';
    }
    return 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/delivery/fedex_png.png';
  }

  Widget _buildCachedImage(String url, {double? width, double? height}) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width ?? 40,
          height: height ?? 20,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Widget _buildAddressCard(BuildContext context, CustomerAddress address) {
    return Container(
      width: double.infinity,
      height: 108,
      padding: const EdgeInsets.only(left: 28, right: 23, top: 18, bottom: 18),
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
                  fontWeight: FontWeight.bold,
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingAddressesScreen()));
                },
                child: const Text(
                  'Change',
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xFF555555), width: 1.0) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4), 
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 25,
                    offset: const Offset(0, 1),
                  ),
                ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80, maxHeight: 46),
              child: _buildCachedImage(imageUrl),
            ),
            const SizedBox(height: 2),
            Text(
              duration,
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 11,
                color: Color(0xFF9B9B9B),
                height: 11 / 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
