import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/loading_provider.dart';

import '../models/favorite_product.dart';
import 'home_provider.dart';
import 'category_provider.dart';

final favoriteProductsProvider = FutureProvider<List<FavoriteProduct>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getFavoriteProducts();
});

class FavoriteNotifier extends StateNotifier<bool> {
  FavoriteNotifier(this.ref) : super(false);
  final Ref ref;

  Future<void> toggle(String productId, {String? variantOptionId}) async {
    try {
      ref.read(loadingProvider.notifier).state = true;
      final api = ref.read(apiServiceProvider);
      await api.toggleFavorite(productId, variantOptionId: variantOptionId);
      
      // Invalidate all product lists so they refetch the updated isFavorite status
      ref.invalidate(newProductsProvider);
      ref.invalidate(saleProductsProvider);
      ref.invalidate(categoryProductsProvider);
      ref.invalidate(favoriteProductsProvider);
    } catch (e) {
      print('Error toggling favorite: $e');
      ref.read(loadingProvider.notifier).state = false;
      rethrow;
    }

    // Prolong loading overlay for 3 seconds to prevent double taps while UI updates
    await Future.delayed(const Duration(seconds: 3));
    ref.read(loadingProvider.notifier).state = false;
  }
}

final favoriteNotifierProvider = StateNotifierProvider<FavoriteNotifier, bool>((ref) {
  return FavoriteNotifier(ref);
});
