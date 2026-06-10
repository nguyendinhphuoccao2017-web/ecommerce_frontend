import 'package:flutter/material.dart';
import 'categories_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222222)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF222222),
          unselectedLabelColor: const Color(0xFF222222),
          indicatorColor: const Color(0xFFDB3022),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Metropolis',
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'Women'),
            Tab(text: 'Men'),
            Tab(text: 'Kids'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWomenTab(context),
          const Center(child: Text('Men Categories (Static)')),
          const Center(child: Text('Kids Categories (Static)')),
        ],
      ),
    );
  }

  Widget _buildWomenTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
            },
            child: Container(
              width: 343,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFDB3022),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SUMMER SALES',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Metropolis',
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Up to 50% off',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Metropolis',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(context, 'New', 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/categories_tab/new.png'),
          const SizedBox(height: 16),
          _buildCategoryCard(context, 'Clothes', 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/categories_tab/clothes.png'),
          const SizedBox(height: 16),
          _buildCategoryCard(context, 'Shoes', 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/categories_tab/shoes.png'),
          const SizedBox(height: 16),
          _buildCategoryCard(context, 'Accesories', 'https://nddvgywmwxlmkmextxre.supabase.co/storage/v1/object/public/categories_tab/accesories.png'),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
      },
      child: Container(
        width: 343,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 23),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontFamily: 'Metropolis',
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Image.network(
                imagePath,
                width: 171,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 171,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
