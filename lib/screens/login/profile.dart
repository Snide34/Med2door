import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_colours.dart' as app_colors;

// --- 1. Data Model ---
class OrderItem {
  final String id;
  final String date;
  final int items;
  final double total;
  final String status;

  const OrderItem({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
  });
}

// --- 2. Widget (Equivalent to TSX Component) ---
class ProfilePage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final VoidCallback? onNavigateToHome;
  final VoidCallback? onNavigateToCart;
  final int cartCount;

  const ProfilePage({
    super.key,
    required this.onBack,
    required this.onLogout,
    this.onNavigateToHome,
    this.onNavigateToCart,
    this.cartCount = 0,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;

  // Dummy data equivalent to the TSX 'orderHistory' array
  static const List<OrderItem> orderHistory = [
    OrderItem(
      id: 'MD123456',
      date: '10 Nov 2024',
      items: 3,
      total: 425,
      status: 'Delivered',
    ),
    OrderItem(
      id: 'MD123455',
      date: '05 Nov 2024',
      items: 2,
      total: 165,
      status: 'Delivered',
    ),
    OrderItem(
      id: 'MD123454',
      date: '28 Oct 2024',
      items: 1,
      total: 120,
      status: 'Delivered',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _user = Supabase.instance.client.auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'Guest';
    return Scaffold(
      backgroundColor: app_colors.kGrey50, // bg-gray-50
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            // Padding added to ensure content scrolls over the Bottom Nav placeholder
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildHeader(context, userName), _buildBody(context)],
            ),
          ),

          // Bottom Navigation (Placeholder/Sticky Footer)
          Align(
            alignment: Alignment.bottomCenter,
            // Replace with your actual BottomNav widget when available
            child: _BottomNavPlaceholder(
              currentScreen: 'profile',
              cartCount: widget.cartCount,
              onNavigate: (screen) {
                if (screen == 'home' && widget.onNavigateToHome != null)
                  widget.onNavigateToHome!();
                if (screen == 'cart' && widget.onNavigateToCart != null)
                  widget.onNavigateToCart!();
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Builder Methods ---

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      decoration: BoxDecoration(
        // bg-gradient-to-br from-teal-500 to-teal-600
        gradient: LinearGradient(
          colors: [app_colors.kPrimaryTeal, app_colors.kPrimaryTealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ), // rounded-b-3xl
      ),
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 80),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            InkWell(
              onTap: widget.onBack,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: app_colors.kWhite,
                  size: 24,
                ), // ArrowLeft
              ),
            ),
            const SizedBox(height: 16),

            // Profile Info
            Row(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: app_colors.kWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: app_colors.kBlack.withAlpha(51),
                        blurRadius: 10,
                      ),
                    ], // shadow-lg
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_outline,
                      color: app_colors.kPrimaryTealDark,
                      size: 40,
                    ), // User icon
                  ),
                ),
                const SizedBox(width: 16),

                // Name and Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: app_colors.kWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.email ?? 'user@example.com',
                      style: TextStyle(
                        color: app_colors.kTeal100,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions (Moved up by negative margin)
          Transform.translate(
            offset: const Offset(0, -48),
            child: _buildQuickActions(),
          ),

          // --- Order History ---
          Transform.translate(
            offset: const Offset(0, -48),
            child: _buildOrderHistory(context),
          ),

          // --- Menu Options ---
          Transform.translate(
            offset: const Offset(0, -48),
            child: _buildMenuOptions(),
          ),

          // --- Logout Button ---
          Transform.translate(
            offset: const Offset(0, -48),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: OutlinedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: app_colors.kErrorRed,
                  side: BorderSide(color: app_colors.kPurple200),
                  backgroundColor: app_colors.kWhite,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app_colors.kBlack.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            icon: Icons.location_on_outlined,
            label: 'Address Book',
            bgColor: app_colors.kLightTeal,
            iconColor: app_colors.kPrimaryTealDark,
          ),
          _buildQuickActionItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            bgColor: app_colors.kBlue50,
            iconColor: Colors.blue.shade600,
          ),
          _buildQuickActionItem(
            icon: Icons.help_outline,
            label: 'Help',
            bgColor: app_colors.kPurple100,
            iconColor: app_colors.kPurpleCTA,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: app_colors.kGrey600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHistory(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app_colors.kBlack.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: app_colors.kGrey800,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/order-history'),
                child: Text(
                  'View All',
                  style: TextStyle(color: app_colors.kPrimaryTealDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: orderHistory
                .map((order) => _buildOrderItem(order))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: app_colors.kWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: app_colors.kGrey200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: app_colors.kGrey800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: app_colors.kSuccessGreen.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: app_colors.kSuccessGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.date} • ${order.items} items',
                    style: TextStyle(color: app_colors.kGrey600, fontSize: 13),
                  ),
                  Text(
                    '₹${order.total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: app_colors.kGrey800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Container(
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app_colors.kBlack.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          _buildMenuOptionItem(
            Icons.notifications_none,
            'Notifications',
            onTap: () {},
          ),
          _buildMenuOptionItem(
            Icons.location_on_outlined,
            'Saved Addresses',
            onTap: () {},
          ),
          _buildMenuOptionItem(
            Icons.help_outline,
            'Help & Support',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptionItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: app_colors.kGrey200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: app_colors.kGrey600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: app_colors.kGrey800),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: app_colors.kGrey500),
          ],
        ),
      ),
    );
  }
}

// --- 3. Bottom Nav Placeholder (Replace with actual BottomNav widget later) ---
class _BottomNavPlaceholder extends StatelessWidget {
  final String currentScreen;
  final int cartCount;
  final Function(String) onNavigate;

  const _BottomNavPlaceholder({
    required this.currentScreen,
    required this.cartCount,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        boxShadow: [
          BoxShadow(
            color: app_colors.kBlack.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              isSelected: currentScreen == 'home',
              onTap: () => onNavigate('home'),
            ),
            _BottomNavItem(
              icon: Icons.shopping_cart_outlined,
              label: 'Cart',
              isSelected: currentScreen == 'cart',
              onTap: () => onNavigate('cart'),
              badgeCount: cartCount,
            ),
            _BottomNavItem(
              icon: Icons.person, // Filled icon for active state
              label: 'Profile',
              isSelected: currentScreen == 'profile',
              onTap: () => onNavigate('profile'),
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
  final VoidCallback onTap;
  final int badgeCount;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? app_colors.kPrimaryTealDark
        : app_colors.kGrey500;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(icon, color: color, size: 28),
                if (badgeCount > 0 && label == 'Cart')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: app_colors.kPink500,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: app_colors.kWhite,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
