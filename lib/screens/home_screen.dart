import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/slideshow_banner.dart';
import '../widgets/product_section.dart';
import '../widgets/custom_bottom_nav.dart';
import '../providers/nav_provider.dart';
import 'shop_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int currentIndex = ref.watch(navIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          _buildHomeTab(ref),
          const ShopScreen(),
          const Center(child: Text('Bag')),
          const FavoritesScreen(),
          const Center(child: Text('Profile')),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navIndexProvider.notifier).state = index;
        },
      ),
    );
  }

  Widget _buildHomeTab(WidgetRef ref) {
    final slideshowsAsync = ref.watch(slideshowsProvider);
    final newProductsAsync = ref.watch(newProductsProvider);
    final saleProductsAsync = ref.watch(saleProductsProvider);

    return RefreshIndicator(
      color: const Color(0xFFDB3022),
      onRefresh: () async {
        // Invalidate the providers so they fetch data again
        ref.invalidate(slideshowsProvider);
        ref.invalidate(newProductsProvider);
        ref.invalidate(saleProductsProvider);
        // Await the new data to stop the refresh spinner
        await Future.wait([
          ref.read(slideshowsProvider.future),
          ref.read(newProductsProvider.future),
          ref.read(saleProductsProvider.future),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Ensure it can be pulled even if content is small
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slideshow Banner
            slideshowsAsync.when(
              data: (slideshows) {
                if (slideshows.isEmpty) return const SizedBox.shrink();
                final sortedSlideshows = List.of(slideshows)..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
                return SizedBox(
                  height: 500,
                  child: PageView.builder(
                    itemCount: sortedSlideshows.length,
                    itemBuilder: (context, index) {
                      return SlideshowBanner(slideshow: sortedSlideshows[index]);
                    },
                  ),
                );
              },
              loading: () => const SizedBox(height: 500, child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SizedBox(height: 500, child: Center(child: Text('Error: $err'))),
            ),
            
            const SizedBox(height: 32),
            
            // New Products
            newProductsAsync.when(
              data: (products) => ProductSection(
                title: 'New',
                subtitle: 'You\'ve never seen it before!',
                products: products,
                isNewSection: true,
              ),
              loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => const Center(child: Text('Error loading new products')),
            ),
            
            const SizedBox(height: 32),
            
            // Sale Products
            saleProductsAsync.when(
              data: (products) => ProductSection(
                title: 'Sale',
                subtitle: 'Super summer sale',
                products: products,
                isNewSection: false,
              ),
              loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => const Center(child: Text('Error loading sale products')),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
