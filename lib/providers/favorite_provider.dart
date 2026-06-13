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
      
      // Await refresh so loading overlay stays until new data is fetched and UI is ready
      await Future.wait([
        ref.refresh(newProductsProvider.future).catchError((_) => []),
        ref.refresh(saleProductsProvider.future).catchError((_) => []),
        ref.refresh(favoriteProductsProvider.future).catchError((_) => []),
      ]);
      
      await Future.delayed(const Duration(seconds: 3));
      ref.read(loadingProvider.notifier).state = false;
    } catch (e) {
      print('Error toggling favorite: $e');
      ref.read(loadingProvider.notifier).state = false;
      rethrow;
    }
  }
}

final favoriteNotifierProvider = StateNotifierProvider<FavoriteNotifier, bool>((ref) {
  return FavoriteNotifier(ref);
});
