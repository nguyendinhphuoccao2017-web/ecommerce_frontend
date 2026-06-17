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
      final token = ref.read(authProvider);
      final response = await http.get(
        Uri.parse('${ApiService.apiBaseUrl}/coupons'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final coupons = data.map((e) => Coupon.fromJson(e)).toList();
        state = AsyncValue.data(coupons);
      } else {
        state = AsyncValue.error('Failed to load coupons', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final couponProvider = StateNotifierProvider<CouponNotifier, AsyncValue<List<Coupon>>>((ref) {
  return CouponNotifier(ref);
});

final selectedPromoProvider = StateProvider<String?>((ref) => null);

