import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/cart_response.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'favorite_provider.dart';
import 'loading_provider.dart';

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
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
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

  final Map<String, Timer> _debounceTimers = {};
  final Map<String, int> _pendingDiffs = {};

  Future<void> updateQuantity(String itemId, String productId, String? variantOptionId, int diff) async {
    final currentCart = state.value;
    if (currentCart == null) return;
    
    final targetItem = currentCart.items.firstWhere((i) => i.id == itemId, orElse: () => currentCart.items.first);
    if (targetItem.id != itemId) return; // Item not found

    if (targetItem.quantity + diff <= 0) {
      return; // Handled by UI delete confirmation
    }

    // Optimistic Update
    final updatedItems = currentCart.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: item.quantity + diff);
      }
      return item;
    }).toList();
    
    double newSubtotal = 0.0;
    for (var item in updatedItems) {
      newSubtotal += item.salePrice * item.quantity;
    }
    
    state = AsyncValue.data(currentCart.copyWith(items: updatedItems, subtotal: newSubtotal));

    // Accumulate diffs for debouncing
    _pendingDiffs[itemId] = (_pendingDiffs[itemId] ?? 0) + diff;

    // Debounce API call
    _debounceTimers[itemId]?.cancel();
    _debounceTimers[itemId] = Timer(const Duration(milliseconds: 500), () async {
      final accumulatedDiff = _pendingDiffs[itemId] ?? 0;
      _pendingDiffs.remove(itemId);
      
      if (accumulatedDiff != 0) {
        try {
          await _apiService.addToCart(productId, variantOptionId, accumulatedDiff);
          // Sync with server after debounced update
          final newCart = await fetchCart();
          if (newCart != null) {
            state = AsyncValue.data(newCart);
          }
        } catch (e) {
          print('Error updating quantity: $e');
          // Revert on error by re-fetching
          final revertedCart = await fetchCart();
          state = AsyncValue.data(revertedCart);
        }
      }
    });
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
