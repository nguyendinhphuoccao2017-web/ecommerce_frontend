import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../widgets/product_card.dart';

final viewModeProvider = StateProvider<bool>((ref) => true); // true for grid, false for list

class CategoryProductsScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(categoryProductsProvider(categoryId));
    final isGridMode = ref.watch(viewModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Color(0xFF222222),
            fontFamily: 'Metropolis',
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF222222)),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Filter & Sort Bar
          Container(
            color: const Color(0xFFF9F9F9),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.filter_list, size: 24, color: Color(0xFF222222)),
                    SizedBox(width: 8),
                    Text('Filters', style: TextStyle(fontSize: 11, fontFamily: 'Metropolis')),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.swap_vert, size: 24, color: Color(0xFF222222)),
                    SizedBox(width: 8),
                    Text('Price: lowest to high', style: TextStyle(fontSize: 11, fontFamily: 'Metropolis')),
                  ],
                ),
                IconButton(
                  icon: Icon(isGridMode ? Icons.view_list : Icons.grid_view, color: const Color(0xFF222222)),
                  onPressed: () {
                    ref.read(viewModeProvider.notifier).state = !isGridMode;
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products available.'));
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isGridMode
                      ? GridView.builder(
                          itemCount: products.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.55,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: products[index],
                              isNewSection: false, 
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ProductCard(
                                  product: products[index],
                                  isNewSection: false,
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
