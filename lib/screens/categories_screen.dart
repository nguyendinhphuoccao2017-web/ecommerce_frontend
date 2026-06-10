import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

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
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Color(0xFF222222),
            fontFamily: 'Metropolis',
            fontWeight: FontWeight.w400,
            fontSize: 18,
            height: 22 / 18,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // VIEW ALL ITEMS button
          Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 343,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDB3022),
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'VIEW ALL ITEMS',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Metropolis',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Choose category',
              style: TextStyle(
                color: Color(0xFF9B9B9B),
                fontFamily: 'Metropolis',
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                return ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 0.4,
                    color: Color(0xFF9B9B9B),
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                      title: Text(
                        category.categoryName,
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontFamily: 'Metropolis',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryProductsScreen(
                              categoryId: category.id,
                              categoryName: category.categoryName,
                              allCategories: categories,
                            ),
                          ),
                        );
                      },
                    );
                  },
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
