import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:med2door/product.dart';
import 'package:med2door/services/product_service.dart';
import 'package:med2door/utils/app_colours.dart';

class Category {
  final String name;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const Category({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

class MainScreen extends StatefulWidget {
  final String? userName;
  const MainScreen({super.key, this.userName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final int cartCount = 3;
  List<Product> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  final List<Category> _categories = const [
    Category(name: 'Medicines', icon: Icons.medical_services_outlined, iconColor: kPrimaryTeal, bgColor: kLightTeal),
    Category(name: 'Vitamins', icon: Icons.favorite_border, iconColor: kPink500, bgColor: kPink100),
    Category(name: 'Devices', icon: Icons.thermostat_outlined, iconColor: kPurpleCTA, bgColor: kLightPurple),
    Category(name: 'Covid Care', icon: Icons.warning_amber_rounded, iconColor: kWarningOrange, bgColor: kOrange50),
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await ProductService().getProducts();
      if (mounted) {
        setState(() {
          _products = products.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching products: $e')),
        );
      }
    }
  }

  void onNavigateToCart() {
    Navigator.of(context).pushNamed('/cart');
  }

  void onNavigateToProfile() {
    Navigator.pushNamed(context, '/profile', arguments: widget.userName);
  }

  void onNavigateToPrescriptionOrder() {
    Navigator.of(context).pushNamed('/prescription-order');
  }

  void onViewMedicine(Product medicine) {
    Navigator.of(context).pushNamed('/medicine-details', arguments: medicine);
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: kGrey50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate.fixed(
                            [
                              _buildPrescriptionOrderButton(),
                              const SizedBox(height: 24),
                              _buildCategoriesGrid(),
                              const SizedBox(height: 24),
                              _buildOffersBanner(),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Popular Medicines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viewing All Medicines...')));
                                    },
                                    child: const Text('See All', style: TextStyle(color: kPrimaryTealDark)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = filteredProducts[index];
                              return _buildMedicineItem(product);
                            },
                            childCount: filteredProducts.length,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kWhite,
          boxShadow: [
            BoxShadow(
              color: kBlack.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(icon: Icons.home, label: 'Home', isSelected: true, onTap: () {}),
              _BottomNavItem(icon: Icons.shopping_cart_outlined, label: 'Cart', isSelected: false, onTap: onNavigateToCart, badgeCount: cartCount),
              _BottomNavItem(icon: Icons.person_outline, label: 'Profile', isSelected: false, onTap: onNavigateToProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [kPrimaryTeal, kPrimaryTealDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: kPrimaryTeal, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hello 👋', style: TextStyle(color: kTeal100, fontSize: 16)),
                    Text(widget.userName ?? 'Guest', style: const TextStyle(color: kWhite, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildHeaderActionButton(icon: Icons.shopping_cart_outlined, onPressed: onNavigateToCart),
                        if (cartCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: kPink500,
                                shape: BoxShape.circle,
                                border: Border.all(color: kWhite, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  cartCount.toString(),
                                  style: const TextStyle(
                                    color: kWhite,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    _buildHeaderActionButton(icon: Icons.person_outline, onPressed: onNavigateToProfile),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              readOnly: true,
              onTap: () => Navigator.of(context).pushNamed('/search'),
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search, color: kGrey),
                filled: true,
                fillColor: kWhite,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kTeal300, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActionButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: kWhite, size: 20),
      ),
    );
  }

  Widget _buildPrescriptionOrderButton() {
    return InkWell(
      onTap: onNavigateToPrescriptionOrder,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPurpleCTA, kPurple700],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPurple700.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description_outlined, color: kWhite, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Order Medicine with Prescription',
                  style: TextStyle(color: kWhite, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Upload & get doorstep delivery',
                  style: TextStyle(color: kPurple100, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kGrey800),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigating to ${category.name}')));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: kBlack.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category.icon, color: category.iconColor, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: kGrey600),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOffersBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPink100, kPurple100],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: kBlack.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎉 Special Offer', style: TextStyle(color: kPurple900, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Get 20% off on first order', style: TextStyle(color: kPurple700)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kPurpleCTA,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Shop Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineItem(Product medicine) {
    return InkWell(
      onTap: () => onViewMedicine(medicine),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: kBlack.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: medicine.imageUrl,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: kGrey),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              medicine.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kGrey800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              medicine.composition,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kGrey500, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${double.tryParse(medicine.price)?.toStringAsFixed(0) ?? '0'}',
              style: const TextStyle(color: kPrimaryTealDark, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final int badgeCount;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? kPrimaryTealDark : kGrey500;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 28),
              if (badgeCount > 0 && label == 'Cart')
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: kPink500,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(color: kWhite, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
