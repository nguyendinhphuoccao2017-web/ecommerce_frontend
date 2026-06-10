import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/horizontal_product_card.dart';
import '../models/category.dart';

final viewModeProvider = StateProvider<bool>((ref) => false); // false for list (default), true for grid

class CategoryProductsScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;
  final List<Category>? allCategories;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.allCategories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(categoryProductsProvider(categoryId));
    final isGridMode = ref.watch(viewModeProvider);

    String shortName = categoryName.replaceAll(RegExp(r'\s*[/&]\s*.*'), '').toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF222222)),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Heading
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 16, bottom: 12),
            child: Text(
              "Women's $shortName",
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontWeight: FontWeight.w700,
                fontSize: 34,
                color: Color(0xFF222222),
                height: 1.0,
              ),
            ),
          ),
          
          // Sub-category Pills
          if (allCategories != null)
            SizedBox(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: allCategories!.length,
                itemBuilder: (context, index) {
                  final cat = allCategories![index];
                  if (cat.id == categoryId) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryProductsScreen(
                            categoryId: cat.id,
                            categoryName: cat.categoryName,
                            allCategories: allCategories,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 30,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(29),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat.categoryName,
                        style: const TextStyle(
                          fontFamily: 'Metropolis',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 12),

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
                            return HorizontalProductCard(
                              product: products[index],
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
