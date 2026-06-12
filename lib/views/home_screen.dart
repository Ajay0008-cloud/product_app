import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_list_vm.dart';
import '../viewmodels/wishlist_vm.dart';
import '../viewmodels/cart_vm.dart';
import 'widgets/product_card.dart';
import 'widgets/shimmer_loader.dart';
import 'widgets/filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0; // 0: Shop, 1: Favorites, 2: Cart, 3: Profile
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final PageController _promoController = PageController();
  int _currentPromoPage = 0;

  // Promos array for featured banner slider
  final List<Map<String, String>> _promos = [
    {
      'title': 'THE LUXURY STANDARD',
      'subtitle': 'Up to 30% off selected summer items',
      'tag': 'NEW IN',
      'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'ESSENTIAL SCENTS',
      'subtitle': 'Explore premium designer colognes & oils',
      'tag': 'FRAGRANCE',
      'image': 'https://images.unsplash.com/photo-1541643600914-78b084683601?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'TIMELESS ACCENTS',
      'subtitle': 'Curated high-end accessories & watches',
      'tag': 'EXCLUSIVE',
      'image': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?q=80&w=600&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Auto-sliding promo banner animation loop
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      if (_activeTab == 0 && _promoController.hasClients) {
        final nextPage = (_currentPromoPage + 1) % _promos.length;
        _promoController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
      return true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      Provider.of<ProductListViewModel>(context, listen: false).loadMoreProducts();
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  // Shop View Tab
  Widget _buildShopTab(ProductListViewModel productListVM) {
    final filteredList = productListVM.filteredProducts;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Welcome Header & Profile Avatar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back,',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(128),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'Ajay Chauhan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                // Glowing circular avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFE5C158), Color(0xFFE97B5E)],
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF16161A),
                    child: Text(
                      'AC',
                      style: TextStyle(color: Color(0xFFE5C158), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating search bar & filter triggers
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(8)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search collections...',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFE5C158)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  productListVM.updateSearchQuery('');
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (val) {
                        productListVM.updateSearchQuery(val);
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: productListVM.selectedCategory.isNotEmpty ||
                              productListVM.minPrice > 0 ||
                              productListVM.maxPrice < 2000
                          ? const Color(0xFFE5C158)
                          : const Color(0xFF16161A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(8)),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: productListVM.selectedCategory.isNotEmpty ||
                              productListVM.minPrice > 0 ||
                              productListVM.maxPrice < 2000
                          ? Colors.black
                          : const Color(0xFFE5C158),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Featured promo slider banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: SizedBox(
              height: 165,
              child: PageView.builder(
                controller: _promoController,
                itemCount: _promos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPromoPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final promo = _promos[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withAlpha(8)),
                      image: DecorationImage(
                        image: NetworkImage(promo['image']!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withAlpha(160),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5C158).withAlpha(51),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE5C158).withAlpha(100)),
                            ),
                            child: Text(
                              promo['tag']!,
                              style: const TextStyle(
                                color: Color(0xFFE5C158),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo['title']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                promo['subtitle']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(180),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Categories selector chips row
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: productListVM.categories.length,
              itemBuilder: (context, index) {
                final cat = productListVM.categories[index];
                final slug = cat['slug']!;
                final name = cat['name']!;
                final isSelected = productListVM.selectedCategory == slug;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
                  child: ChoiceChip(
                    label: Text(
                      name,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE5C158),
                    backgroundColor: const Color(0xFF16161A),
                    checkmarkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFE5C158) : Colors.white.withAlpha(8),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        productListVM.selectCategory(slug);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // Grid lists items
        if (productListVM.isLoading)
          const SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: ShimmerGridLoader(),
            ),
          )
        else if (productListVM.error.isNotEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Color(0xFFE97B5E), size: 50),
                    const SizedBox(height: 16),
                    Text(
                      productListVM.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => productListVM.refreshProducts(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5C158),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (filteredList.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, color: Colors.white.withAlpha(20), size: 70),
                  const SizedBox(height: 16),
                  const Text('No products match filters', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 120.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Wrap item in cascade fade animation
                  return FadeInSlideUp(
                    delay: Duration(milliseconds: index * 50),
                    child: ProductCard(product: filteredList[index]),
                  );
                },
                childCount: filteredList.length,
              ),
            ),
          ),
      ],
    );
  }

  // Favorites (Wishlist) View Tab
  Widget _buildFavoritesTab(WishlistViewModel wishlistVM, ProductListViewModel productListVM) {
    final wishlistedProducts = productListVM.products.where((p) {
      return wishlistVM.isWishlisted(p.id);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 8.0),
          child: Text(
            'SAVED ITEMS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE5C158),
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: wishlistedProducts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE97B5E).withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_outline_rounded, color: Color(0xFFE97B5E), size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your collection is waiting',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap the heart icon on products to see them here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 120),
                  itemCount: wishlistedProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    return FadeInSlideUp(
                      delay: Duration(milliseconds: index * 50),
                      child: ProductCard(product: wishlistedProducts[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Shopping Bag (Cart) Tab
  Widget _buildCartTab(CartViewModel cartVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 8.0),
          child: Text(
            'MY COLLECTION BAG',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE5C158),
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: cartVM.items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5C158).withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFE5C158), size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your bag is empty',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add items from product detail pages to begin.',
                          style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
                        itemCount: cartVM.items.length,
                        itemBuilder: (context, index) {
                          final item = cartVM.items[index];
                          final double price = item.product.price * (1 - item.product.discountPercentage / 100);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16161A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withAlpha(8)),
                            ),
                            child: Row(
                              children: [
                                // Thumbnail Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.product.thumbnail,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Text specs
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.product.brand.toUpperCase(),
                                        style: const TextStyle(color: Color(0xFFE5C158), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '\$${price.toStringAsFixed(1)}',
                                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity adjustment controls
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 22),
                                      onPressed: () {
                                        cartVM.updateQuantity(item.product.id, item.quantity - 1);
                                      },
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE5C158), size: 22),
                                      onPressed: () {
                                        cartVM.updateQuantity(item.product.id, item.quantity + 1);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Summary container layout
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161A),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        border: Border(top: BorderSide(color: Colors.white.withAlpha(12))),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal (${cartVM.totalItems} items)', style: const TextStyle(color: Colors.grey)),
                              Text('\$${cartVM.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE5C158), Color(0xFFF0D680)],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                cartVM.clearCart();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF16161A),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: const Center(child: Icon(Icons.check_circle_outline_rounded, color: Color(0xFFE5C158), size: 50)),
                                    content: const Text(
                                      'Thank you for your order! Your luxury showcase transaction is complete.',
                                      textAlign: TextAlign.center,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Back to Gallery', style: TextStyle(color: Color(0xFFE5C158))),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('PROCEED TO CHECKOUT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // Premium Customer Profile Tab
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 120.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CUSTOMER ACCOUNT',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE5C158),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // User Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16161A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(8)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFFE5C158), Color(0xFFE97B5E)]),
                  ),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF16161A),
                    child: Text('AC', style: TextStyle(color: Color(0xFFE5C158), fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ajay Chauhan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('ajay.chauhan.intern@luxe.com', style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5C158).withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('GOLD MEMBER', style: TextStyle(color: Color(0xFFE5C158), fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Order History Header
          const Text('ORDER TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          // Timeline list mockup
          _buildTimelineItem('Order #7492', 'Processing collection shipment', 'June 12, 2026', true),
          _buildTimelineItem('Order #6391', 'Successfully delivered', 'May 28, 2026', false),
          _buildTimelineItem('Order #4102', 'Successfully delivered', 'April 14, 2026', false),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String code, String status, String date, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCurrent ? const Color(0xFFE5C158).withAlpha(50) : Colors.white.withAlpha(6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isCurrent ? Icons.sync : Icons.check_circle_outline, color: isCurrent ? const Color(0xFFE5C158) : Colors.grey, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(status, style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 11)),
                ],
              ),
            ],
          ),
          Text(date, style: TextStyle(color: Colors.white.withAlpha(80), fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productListVM = Provider.of<ProductListViewModel>(context);
    final wishlistVM = Provider.of<WishlistViewModel>(context);
    final cartVM = Provider.of<CartViewModel>(context);

    // Active body selector
    Widget activeBody;
    switch (_activeTab) {
      case 0:
        activeBody = _buildShopTab(productListVM);
        break;
      case 1:
        activeBody = _buildFavoritesTab(wishlistVM, productListVM);
        break;
      case 2:
        activeBody = _buildCartTab(cartVM);
        break;
      case 3:
        activeBody = _buildProfileTab();
        break;
      default:
        activeBody = _buildShopTab(productListVM);
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: activeBody),

          // Custom floating Glassmorphic Bottom Navigation Bar
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF16161A).withAlpha(210),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withAlpha(12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.storefront_rounded, 'Shop'),
                      _buildNavItem(1, Icons.favorite_rounded, 'Saved'),
                      // Cart Nav Item with badge
                      _buildCartNavItem(2, cartVM),
                      _buildNavItem(3, Icons.person_rounded, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFE5C158) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFFE5C158) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartNavItem(int index, CartViewModel cartVM) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_rounded,
                color: isActive ? const Color(0xFFE5C158) : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Bag',
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? const Color(0xFFE5C158) : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (cartVM.totalItems > 0)
            Positioned(
              right: -4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE97B5E),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${cartVM.totalItems}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Fade in slide up animation wrapper for loading products cascade
class FadeInSlideUp extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeInSlideUp({super.key, required this.child, required this.delay});

  @override
  State<FadeInSlideUp> createState() => _FadeInSlideUpState();
}

class _FadeInSlideUpState extends State<FadeInSlideUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: widget.child,
      ),
    );
  }
}
