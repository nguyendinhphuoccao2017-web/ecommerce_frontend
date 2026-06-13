import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorite_provider.dart';
import '../widgets/favorite_product_card.dart';
import '../widgets/horizontal_favorite_product_card.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _isGridMode = true;

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoriteProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        centerTitle: _isGridMode,
        title: _isGridMode
            ? const Text(
                'Favorites',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF222222),
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF222222)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isGridMode)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Favorites',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                  color: Color(0xFF222222),
                ),
              ),
            ),
          if (!_isGridMode) const SizedBox(height: 16),
          // Category Pills Row (Dynamic based on product categories)
          favoritesAsync.when(
            data: (products) {
              final tags = <String>{};
              for (var p in products) {
                tags.addAll(p.categories);
              }
              final tagList = tags.toList()..sort();
              if (tagList.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 30,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: tagList.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(29),
                      ),
                      child: Text(
                        tagList[index],
                        style: const TextStyle(
                          fontFamily: 'Metropolis',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list, size: 24, color: Color(0xFF222222)),
                    const SizedBox(width: 8),
                    const Text(
                      'Filters',
                      style: TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: Color(0xFF222222)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.swap_vert, size: 24, color: Color(0xFF222222)),
                    const SizedBox(width: 8),
                    const Text(
                      'Price: lowest to high',
                      style: TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: Color(0xFF222222)),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isGridMode ? Icons.view_list : Icons.view_module,
                    size: 24,
                    color: const Color(0xFF222222),
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridMode = !_isGridMode;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: favoritesAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      'No favorites yet',
                      style: TextStyle(fontFamily: 'Metropolis', color: Colors.grey),
                    ),
                  );
                }
                if (_isGridMode) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return FavoriteProductCard(product: products[index]);
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return HorizontalFavoriteProductCard(product: products[index]);
                    },
                  );
                }
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
