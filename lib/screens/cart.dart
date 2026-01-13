import 'package:flutter/material.dart';
import 'package:med2door/utils/app_colours.dart' as app_colors;

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String? manufacturer;
  final double? originalPrice;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.manufacturer,
    this.originalPrice,
    required this.quantity,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _promoController = TextEditingController();
  
  String? _appliedPromo;
  double _promoDiscount = 0;
  
  final List<CartItem> _cart = [
    CartItem(id: '1', name: 'Paracetamol 500mg', price: 45, image: 'https://i.imgur.com/8f8Y4bC.png', manufacturer: 'MedCorp', originalPrice: 55, quantity: 2),
    CartItem(id: '2', name: 'Vitamin C Tablets', price: 120, image: 'https://i.imgur.com/8f8Y4bC.png', manufacturer: 'HealthPlus', originalPrice: 150, quantity: 1),
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _onUpdateQuantity(String id, int quantity) {
    setState(() {
      final item = _cart.firstWhere((item) => item.id == id);
      if (quantity > 0) {
        item.quantity = quantity;
      } else {
        _cart.removeWhere((item) => item.id == id);
      }
    });
  }

  double get _subtotal {
    return _cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _savings {
    return (_subtotal * 0.15).roundToDouble();
  }

  double get _deliveryFee {
    return _subtotal > 500 ? 0.0 : 40.0;
  }

  double get _total {
    return _subtotal - _promoDiscount + _deliveryFee;
  }

  void _handleApplyPromo() {
    final code = _promoController.text.toUpperCase();
    if (code == 'MED10') {
      setState(() {
        _appliedPromo = 'MED10';
        _promoDiscount = (_subtotal * 0.1).roundToDouble(); // 10% discount
      });
    } else if (code == 'FIRST20') {
      setState(() {
        _appliedPromo = 'FIRST20';
        _promoDiscount = (_subtotal * 0.2).roundToDouble(); // 20% discount
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid promo code: $code'), backgroundColor: app_colors.kErrorRed),
      );
    }
  }

  void _handleRemovePromo() {
    setState(() {
      _appliedPromo = null;
      _promoDiscount = 0;
      _promoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCartEmpty = _cart.isEmpty;

    return Scaffold(
      backgroundColor: app_colors.kGrey50,
      appBar: AppBar(
        backgroundColor: app_colors.kPrimaryTealDark,
        foregroundColor: app_colors.kWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('${_cart.length} ${_cart.length == 1 ? 'item' : 'items'}', style: TextStyle(fontSize: 12, color: app_colors.kWhite.withAlpha(230))),
          ],
        ),
        elevation: 4,
      ),
      body: isCartEmpty
          ? _buildEmptyCartState()
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildDeliveryInfoBanner(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: _cart.map((item) => _buildCartItem(item)).toList(),
                    ),
                  ),
                  _buildPromoSection(),
                  _buildBillDetails(),
                ],
              ),
            ),
      bottomNavigationBar: isCartEmpty ? null : _buildCheckoutButton(),
    );
  }
  
  Widget _buildEmptyCartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 96, color: app_colors.kGrey500),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: app_colors.kGrey800)),
          const SizedBox(height: 8),
          Text('Add medicines to your cart and they will appear here', style: TextStyle(fontSize: 16, color: app_colors.kGrey500), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: app_colors.kPrimaryTealDark,
              foregroundColor: app_colors.kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Browse Medicines'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoBanner() {
    final remainingAmount = 500.0 - _subtotal;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app_colors.kLightTeal,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: app_colors.kPrimaryTealDark, width: 4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_shipping, size: 20, color: app_colors.kPrimaryTealDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _deliveryFee == 0.0
                      ? '🎉 Congrats! You have free delivery'
                      : 'Add ₹${remainingAmount.toStringAsFixed(0)} more for FREE delivery',
                  style: TextStyle(
                    fontSize: 14,
                    color: _deliveryFee == 0.0 ? app_colors.kSuccessGreen.withAlpha(230) : app_colors.kPrimaryTealDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Estimated delivery: 30-45 mins', style: TextStyle(fontSize: 12, color: app_colors.kPrimaryTeal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        boxShadow: [
          BoxShadow(
            color: app_colors.kBlack.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed('/checkout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: app_colors.kPrimaryTealDark,
            foregroundColor: app_colors.kWhite,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Proceed to Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: app_colors.kWhite.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('₹${_total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final itemSavings = item.originalPrice != null && item.originalPrice! > item.price 
        ? (item.originalPrice! - item.price) * item.quantity 
        : 0.0;
        
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app_colors.kGrey.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: app_colors.kGrey200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.medication_liquid, color: app_colors.kGrey500),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: app_colors.kGrey800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.manufacturer ?? 'Generic',
                        style: TextStyle(fontSize: 12, color: app_colors.kGrey500),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${item.price.toStringAsFixed(0)}',
                                style: TextStyle(color: app_colors.kPrimaryTealDark, fontWeight: FontWeight.w600),
                              ),
                              if (item.originalPrice != null && item.originalPrice! > item.price)
                                Text(
                                  '₹${item.originalPrice!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: app_colors.kGrey500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),

                          Container(
                            decoration: BoxDecoration(
                              color: app_colors.kGrey50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                _buildQuantityButton(
                                  icon: item.quantity <= 1 ? Icons.delete_outline : Icons.remove,
                                  color: item.quantity <= 1 ? app_colors.kErrorRed : app_colors.kGrey600,
                                  onTap: () => _onUpdateQuantity(item.id, item.quantity - 1),
                                ),
                                Container(
                                  width: 32,
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.quantity.toString(),
                                    style: TextStyle(fontWeight: FontWeight.bold, color: app_colors.kGrey800),
                                  ),
                                ),
                                _buildQuantityButton(
                                  icon: Icons.add,
                                  color: app_colors.kWhite,
                                  bgColor: app_colors.kPrimaryTealDark,
                                  onTap: () => _onUpdateQuantity(item.id, item.quantity + 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (itemSavings > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: app_colors.kGrey200)),
                  ),
                  child: Text(
                    'You save ₹${itemSavings.toStringAsFixed(0)} on this item',
                    style: TextStyle(fontSize: 12, color: app_colors.kSuccessGreen),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    Color? bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor ?? app_colors.kWhite,
          borderRadius: BorderRadius.circular(8),
          border: bgColor == null ? Border.all(color: app_colors.kGrey200) : null,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildPromoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app_colors.kGrey.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.discount_outlined, color: app_colors.kPrimaryTealDark, size: 20),
              const SizedBox(width: 8),
              Text('Apply Coupon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: app_colors.kGrey800)),
            ],
          ),
          const SizedBox(height: 12),
          
          _appliedPromo != null ? _buildAppliedPromo() : _buildPromoInput(),
          
          if (_appliedPromo == null)
            _buildPromoSuggestions(),
        ],
      ),
    );
  }

  Widget _buildPromoInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _promoController,
            decoration: InputDecoration(
              hintText: 'Enter promo code',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: app_colors.kGrey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: app_colors.kPrimaryTeal, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _promoController,
          builder: (context, value, child) {
            return ElevatedButton(
              onPressed: value.text.isEmpty ? null : _handleApplyPromo,
              style: ElevatedButton.styleFrom(
                backgroundColor: app_colors.kPrimaryTealDark,
                foregroundColor: app_colors.kWhite,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: child,
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildAppliedPromo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: app_colors.kSuccessGreen.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: app_colors.kSuccessGreen.withAlpha(76)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_appliedPromo applied!', style: TextStyle(fontWeight: FontWeight.bold, color: app_colors.kSuccessGreen.withAlpha(230))),
              const SizedBox(height: 4),
              Text('You saved ₹${_promoDiscount.toStringAsFixed(0)}', style: TextStyle(color: app_colors.kSuccessGreen)),
            ],
          ),
          TextButton(
            onPressed: _handleRemovePromo,
            child: Text('Remove', style: TextStyle(color: app_colors.kErrorRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSuggestions() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildSuggestionChip('MED10', 0.1),
          _buildSuggestionChip('FIRST20', 0.2),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionChip(String code, double discountRate) {
    final discount = (_subtotal * discountRate).roundToDouble().toStringAsFixed(0);
    
    return InkWell(
      onTap: () {
        setState(() {
          _promoController.text = code;
          _handleApplyPromo();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: app_colors.kLightTeal,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: app_colors.kTeal100),
        ),
        child: Text(
          '$code - Get ${((discountRate * 100).toInt())}% off (Save ₹$discount)',
          style: TextStyle(fontSize: 12, color: app_colors.kPrimaryTealDark),
        ),
      ),
    );
  }


  Widget _buildBillDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app_colors.kGrey.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bill Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: app_colors.kGrey800)),
          const SizedBox(height: 16),
          
          _buildBillRow('Item Total (${_cart.fold(0, (sum, item) => sum + item.quantity)} items)', '₹${_subtotal.toStringAsFixed(0)}', isDiscount: false),
          const SizedBox(height: 10),

          if (_savings > 0)
            _buildBillRow('Item Savings (Placeholder)', '- ₹${_savings.toStringAsFixed(0)}', isDiscount: true),
          const SizedBox(height: 10),

          if (_appliedPromo != null && _promoDiscount > 0)
            _buildBillRow('Promo Discount ($_appliedPromo)', '- ₹${_promoDiscount.toStringAsFixed(0)}', isDiscount: true),
          const SizedBox(height: 10),

          _buildBillRow(
            'Delivery Fee',
            _deliveryFee == 0.0 ? 'FREE' : '₹${_deliveryFee.toStringAsFixed(0)}',
            isDiscount: _deliveryFee == 0.0,
            showLineThrough: _deliveryFee == 0.0,
          ),
          
          const Divider(height: 24, color: app_colors.kGrey200),

          _buildBillRow('To Pay', '₹${_total.toStringAsFixed(0)}', isTotal: true),
          
          if (_savings > 0 || _promoDiscount > 0)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: app_colors.kSuccessGreen.withAlpha(12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: app_colors.kSuccessGreen.withAlpha(76)),
              ),
              child: Text(
                '🎉 Total Savings: ₹${(_savings + _promoDiscount).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: app_colors.kSuccessGreen.withAlpha(230)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isDiscount = false, bool isTotal = false, bool showLineThrough = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? app_colors.kGrey800 : (isDiscount ? app_colors.kSuccessGreen : app_colors.kGrey600),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? app_colors.kPrimaryTealDark : (isDiscount ? app_colors.kSuccessGreen : app_colors.kGrey800),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            decoration: showLineThrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
