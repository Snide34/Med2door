import 'package:flutter/material.dart';
import 'package:med2door/screens/cart.dart';
import 'package:med2door/utils/app_colours.dart' as app_colors;

enum PaymentMethod { upi, card, cod }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.upi;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _handlePlaceOrder(List<CartItem> cart) {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a delivery address.'),
          backgroundColor: app_colors.kErrorRed,
        ),
      );
      return;
    }
    // Placeholder for order placement logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order placed with ${_paymentMethod.name} at ${_addressController.text}'),
        backgroundColor: app_colors.kSuccessGreen,
      ),
    );
    Navigator.of(context).pushNamedAndRemoveUntil('/order-confirmation', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // For now, using a dummy cart. In a real app, this would be passed from the previous screen.
    final List<CartItem> cart = [
      CartItem(id: '1', name: 'Paracetamol 500mg', price: 45, image: '', quantity: 2, manufacturer: 'MedCorp'),
      CartItem(id: '2', name: 'Vitamin C Tablets', price: 120, image: '', quantity: 1, manufacturer: 'HealthPlus'),
    ];

    final double subtotal = cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    const double deliveryFee = 40.0;
    final double grandTotal = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: app_colors.kGrey50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: app_colors.kGrey800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Checkout', style: TextStyle(color: app_colors.kGrey800, fontWeight: FontWeight.w600)),
        backgroundColor: app_colors.kWhite,
        elevation: 1,
        shadowColor: app_colors.kGrey.withAlpha(50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAddressCard(),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(),
            const SizedBox(height: 16),
            _buildOrderSummaryCard(cart, subtotal, deliveryFee, grandTotal),
          ],
        ),
      ),
      bottomNavigationBar: _buildPlaceOrderButton(cart, grandTotal),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: app_colors.kBlack.withAlpha(15), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.map_outlined, color: app_colors.kPrimaryTealDark, size: 24),
              SizedBox(width: 12),
              Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: app_colors.kGrey800)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your complete delivery address...',
              filled: true,
              fillColor: app_colors.kGrey50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: app_colors.kBorderGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: app_colors.kBorderGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: app_colors.kPrimaryTeal, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: app_colors.kBlack.withAlpha(15), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.credit_card, color: app_colors.kPrimaryTealDark, size: 24),
              SizedBox(width: 12),
              Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: app_colors.kGrey800)),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            title: 'UPI Payment',
            subtitle: 'Pay via Google Pay, PhonePe, etc.',
            icon: Icons.smartphone,
            method: PaymentMethod.upi,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            title: 'Card Payment',
            subtitle: 'Credit or Debit Card',
            icon: Icons.credit_card,
            method: PaymentMethod.card,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            title: 'Cash on Delivery',
            subtitle: 'Pay when you receive',
            icon: Icons.wallet_outlined,
            method: PaymentMethod.cod,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required PaymentMethod method,
  }) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? app_colors.kLightTeal : app_colors.kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? app_colors.kPrimaryTealDark : app_colors.kBorderGrey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? app_colors.kPrimaryTealDark : app_colors.kIconGrey, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? app_colors.kPrimaryTealDark : app_colors.kGrey800)),
                  Text(subtitle, style: const TextStyle(fontSize: 14, color: app_colors.kTextGrey)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(color: app_colors.kPrimaryTealDark, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: app_colors.kWhite, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(List<CartItem> cart, double subtotal, double deliveryFee, double grandTotal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: app_colors.kBlack.withAlpha(15), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: app_colors.kGrey800)),
          const Divider(height: 32),
          _buildSummaryRow('Subtotal (${cart.fold<int>(0, (p, c) => p + c.quantity)} items)', '₹${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Delivery Fee', '₹${deliveryFee.toStringAsFixed(2)}'),
          const Divider(height: 32),
          _buildSummaryRow('Grand Total', '₹${grandTotal.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: isTotal ? app_colors.kGrey800 : app_colors.kTextGrey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 16, color: isTotal ? app_colors.kPrimaryTealDark : app_colors.kGrey800, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }

  Widget _buildPlaceOrderButton(List<CartItem> cart, double grandTotal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        boxShadow: [BoxShadow(color: app_colors.kBlack.withAlpha(25), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => _handlePlaceOrder(cart),
          style: ElevatedButton.styleFrom(
            backgroundColor: app_colors.kPrimaryTealDark,
            foregroundColor: app_colors.kWhite,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            'Pay ₹${grandTotal.toStringAsFixed(2)} & Confirm Order',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
