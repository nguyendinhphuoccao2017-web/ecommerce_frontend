import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/cart_response.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'favorite_provider.dart';

final cartProvider = AsyncNotifierProvider<CartNotifier, CartResponse?>(() {
  return CartNotifier();
});

class CartNotifier extends AsyncNotifier<CartResponse?> {
  late ApiService _apiService;

  @override
  Future<CartResponse?> build() async {
    _apiService = ref.read(apiServiceProvider);
    return await fetchCart();
  }

  Future<CartResponse?> fetchCart() async {
    try {
      final cart = await _apiService.getCart();
      return cart;
    } catch (e) {
      // If unauthorized or error, return null or empty
      return null;
    }
  }

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchCart());
  }

  Future<void> addToCart(String productId, String? variantOptionId, int quantity) async {
    try {
      await _apiService.addToCart(productId, variantOptionId, quantity);
      await loadCart();
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }
  Future<void> removeItem(String itemId) async {
    try {
      final token = ref.read(authProvider);
      final response = await http.delete(
        Uri.parse('${ApiService.apiBaseUrl}/card-items/$itemId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final newCart = await fetchCart();
        state = AsyncValue.data(newCart);
      } else {
        print('Failed to remove item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  Future<void> toggleFavorite(String productId, {String? variantOptionId}) async {
    try {
      await _apiService.toggleFavorite(productId, variantOptionId: variantOptionId);
      ref.invalidate(favoriteProductsProvider);
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
}
