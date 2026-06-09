import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/product_home.dart';
import 'home_provider.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getCategories();
});

final categoryProductsProvider = FutureProvider.family<List<ProductHome>, String>((ref, categoryId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getProductsByCategory(categoryId);
});
