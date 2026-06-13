import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_detail.dart';
import '../models/variant_option.dart';
import '../models/product_home.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final productDetailProvider = FutureProvider.family<ProductDetail, String>((ref, productId) async {
  final api = ref.watch(apiServiceProvider);
  return api.getProductDetails(productId);
});

final productVariantsProvider = FutureProvider.family<List<VariantOption>, String>((ref, productId) async {
  final api = ref.watch(apiServiceProvider);
  return api.getVariants(productId);
});

final relatedProductsProvider = FutureProvider.family<List<ProductHome>, String>((ref, productId) async {
  final api = ref.watch(apiServiceProvider);
  return api.getRelatedProducts(productId);
});

// StateNotifier to track the currently selected variant for a specific product
class SelectedVariantNotifier extends StateNotifier<VariantOption?> {
  SelectedVariantNotifier() : super(null);

  void selectVariant(VariantOption variant) {
    state = variant;
  }
}

final selectedVariantNotifierProvider = StateNotifierProvider.family<SelectedVariantNotifier, VariantOption?, String>((ref, productId) {
  return SelectedVariantNotifier();
});
