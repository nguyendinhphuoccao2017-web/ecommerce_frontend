import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/coupon_provider.dart';
import '../models/coupon.dart';

class PromoCodesBottomSheet extends ConsumerStatefulWidget {
  const PromoCodesBottomSheet({super.key});

  @override
  ConsumerState<PromoCodesBottomSheet> createState() => _PromoCodesBottomSheetState();
}

class _PromoCodesBottomSheetState extends ConsumerState<PromoCodesBottomSheet> {
  final TextEditingController _promoController = TextEditingController();

  // Helper to map DB coupon to UI representation
  Map<String, dynamic> _mapCouponToUI(Coupon coupon) {
    String title = 'Special offer';
    String image = 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/promo_bg/10_percent.png';
    Color textColor = const Color(0xFFFFFFFF);
    double left = 9.0;
    double width = 61.0;

    if (coupon.discountValue == 10) {
      title = 'Personal offer';
      image = 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/promo_bg/10_percent.png';
      textColor = const Color(0xFFFFFFFF);
      left = 9.0;
      width = 61.0;
    } else if (coupon.discountValue == 15) {
      title = 'Summer Sale';
      image = 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/promo_bg/15_percent.png';
      textColor = const Color(0xFF222222);
      left = 14.0;
      width = 58.0;
    } else if (coupon.discountValue == 22) {
      title = 'Personal offer';
      image = 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/promo_bg/22_percent.png';
      textColor = const Color(0xFFFFFFFF);
      left = 9.0;
      width = 61.0;
    }

    String daysStr = 'Valid forever';
    if (coupon.couponEndDate != null) {
      final diff = coupon.couponEndDate!.difference(DateTime.now()).inDays;
      if (diff >= 0) {
        daysStr = '$diff days remaining';
      } else {
        daysStr = 'Expired';
      }
    }

    return {
      'discount': coupon.discountValue.toInt().toString(),
      'image': image,
      'title': title,
      'code': coupon.code,
      'days': daysStr,
      'textColor': textColor,
      'left': left,
      'width': width,
    };
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couponsState = ref.watch(couponProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Center(
            child: Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Search Box
          // Search Box or Applied Promo Code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 36,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: EdgeInsets.only(left: 20, right: ref.watch(selectedPromoProvider) == null ? 40 : 8),
                      alignment: Alignment.centerLeft,
                      child: ref.watch(selectedPromoProvider) != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ref.watch(selectedPromoProvider)!,
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
                          : TextField(
                              controller: _promoController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your promo code',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                    ),
                  ),
                  if (ref.watch(selectedPromoProvider) == null)
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
                          onPressed: () {
                            if (_promoController.text.isNotEmpty) {
                              ref.read(selectedPromoProvider.notifier).state = _promoController.text;
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your Promo Codes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
            ),
          ),
          const SizedBox(height: 16),
          // List of promos
          Expanded(
            child: couponsState.when(
              data: (coupons) {
                if (coupons.isEmpty) {
                  return const Center(child: Text('No promo codes available.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: coupons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final mappedPromo = _mapCouponToUI(coupons[index]);
                    return _buildPromoCard(mappedPromo);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFDB3022))),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> promo) {
    final isSelected = ref.watch(selectedPromoProvider) == promo['code'];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side (Image + Text)
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: Image.network(
                    promo['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: promo['discount'] == '10' ? const Color(0xFFDB3022) : (promo['discount'] == '22' ? Colors.black : Colors.grey),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                // Discount Text Overlay
                Positioned(
                  left: promo['left'],
                  top: 23,
                  child: SizedBox(
                    width: promo['width'],
                    height: 34,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo['discount'],
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            color: promo['textColor'],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                                color: promo['textColor'],
                              ),
                            ),
                            Text(
                              'off',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                                color: promo['textColor'],
                              ),
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
          // Right side (Details)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14, top: 12, bottom: 12, right: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        promo['title'],
                        style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo['code'],
                        style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: Color(0xFF222222)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        promo['days'],
                        style: const TextStyle(
                          fontFamily: 'Metropolis', 
                          fontSize: 11, 
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                      SizedBox(
                        width: 93,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(selectedPromoProvider.notifier).state = promo['code'];
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? const Color(0xFF9B1A14) : const Color(0xFFDB3022),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Apply',
                            style: TextStyle(
                              fontFamily: 'Metropolis',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
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
  }
}
