import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/coupon.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class CouponNotifier extends StateNotifier<AsyncValue<List<Coupon>>> {
  final Ref ref;

  CouponNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    state = const AsyncValue.loading();
    try {
      final apiService = ref.read(apiServiceProvider);
      final List<dynamic> data = await apiService.getCoupons();
      final coupons = data.map((e) => Coupon.fromJson(e)).toList();
      state = AsyncValue.data(coupons);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final couponProvider = StateNotifierProvider<CouponNotifier, AsyncValue<List<Coupon>>>((ref) {
  return CouponNotifier(ref);
});

final selectedPromoProvider = StateProvider<String?>((ref) => null);

final appliedCouponProvider = Provider<Coupon?>((ref) {
  final code = ref.watch(selectedPromoProvider);
  if (code == null) return null;
  final couponsState = ref.watch(couponProvider);
  return couponsState.maybeWhen(
    data: (coupons) {
      try {
        return coupons.firstWhere((c) => c.code == code);
      } catch (e) {
        return null;
      }
    },
    orElse: () => null,
  );
});

