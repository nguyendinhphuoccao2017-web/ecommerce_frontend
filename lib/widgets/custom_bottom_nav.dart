import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorite_provider.dart';

class CustomBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Home', 'assets/images/nav_bar/tab1_home.png', Icons.home),
              _buildNavItem(1, 'Shop', 'assets/images/nav_bar/tab2_shop.png', Icons.shopping_cart),
              _buildNavItem(2, 'Bag', 'assets/images/nav_bar/tab3_bag.png', Icons.shopping_bag),
              _buildNavItem(3, 'Favorites', 'assets/images/nav_bar/tab4_favorite.png', Icons.favorite, ref: ref),
              _buildNavItem(4, 'Profile', 'assets/images/nav_bar/tab5_my_profile.png', Icons.person),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconPath, IconData fallbackIcon, {WidgetRef? ref}) {
    bool isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFFDB3022) : Colors.grey;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                iconPath,
                width: 30,
                height: 30,
                color: color,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(fallbackIcon, color: color, size: 30);
                },
              ),
              if (index == 3 && ref != null)
                ref.watch(favoriteProductsProvider).when(
                      data: (favorites) {
                        if (favorites.isNotEmpty) {
                          return Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDB3022),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${favorites.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
