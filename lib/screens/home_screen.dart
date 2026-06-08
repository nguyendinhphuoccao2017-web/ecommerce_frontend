import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/slideshow_banner.dart';
import '../widgets/product_section.dart';
import '../widgets/custom_bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final slideshowsAsync = ref.watch(slideshowsProvider);
    final newProductsAsync = ref.watch(newProductsProvider);
    final saleProductsAsync = ref.watch(saleProductsProvider);

    return Scaffold(
      body: RefreshIndicator(
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
                  final mainSlideshow = slideshows.firstWhere((s) => s.displayOrder == 1, orElse: () => slideshows.first);
                  return SlideshowBanner(slideshow: mainSlideshow);
                },
                loading: () => const SizedBox(height: 400, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => SizedBox(height: 400, child: Center(child: Text('Error: $err'))),
              ),
              
              const SizedBox(height: 32),
              
              // New Products
              newProductsAsync.when(
                data: (products) => ProductSection(
                  title: 'New',
                  subtitle: 'You\'ve never seen it before!',
                  products: products,
                ),
                loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => Center(child: Text('Error loading new products')),
              ),
              
              const SizedBox(height: 32),
              
              // Sale Products
              saleProductsAsync.when(
                data: (products) => ProductSection(
                  title: 'Sale',
                  subtitle: 'Super summer sale',
                  products: products,
                ),
                loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => Center(child: Text('Error loading sale products')),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
