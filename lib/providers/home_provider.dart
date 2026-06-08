import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/slideshow.dart';
import '../models/product_home.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final slideshowsProvider = FutureProvider<List<Slideshow>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getSlideshows();
});

final newProductsProvider = FutureProvider<List<ProductHome>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getProductsByTag('New');
});

final saleProductsProvider = FutureProvider<List<ProductHome>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getProductsByTag('Sale');
});
