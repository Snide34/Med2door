import 'package:flutter/material.dart';
import 'package:med2door/models/order.dart';
import 'package:med2door/utils/app_colours.dart' as app_colors;

class ReceiptScreen extends StatelessWidget {
  final Order order;

  const ReceiptScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const deliveryFee = 40.0;
    final grandTotal = order.total + deliveryFee;

    return Scaffold(
      backgroundColor: app_colors.kGrey50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: app_colors.kGrey800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Order Receipt', style: TextStyle(color: app_colors.kGrey800, fontWeight: FontWeight.w600)),
        backgroundColor: app_colors.kWhite,
        elevation: 1,
        shadowColor: app_colors.kGrey.withAlpha(50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSuccessCard(),
            const SizedBox(height: 16),
            _buildOrderDetailsCard(),
            const SizedBox(height: 16),
            _buildOrderItemsCard(),
            const SizedBox(height: 16),
            _buildShareOptionsCard(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildDownloadButton(),
    );
  }

  Widget _buildSuccessCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: app_colors.kGrey.withAlpha(50),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [app_colors.kPrimaryTeal, app_colors.kSuccessGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: const [
            Icon(Icons.check_circle_outline, color: app_colors.kWhite, size: 48),
            SizedBox(height: 16),
            Text('Order Confirmed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: app_colors.kWhite)),
            SizedBox(height: 8),
            Text('Thank you for your order!', style: TextStyle(color: app_colors.kTeal100)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: app_colors.kGrey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem('Order ID', order.id),
                _buildDetailItem('Date', order.date, crossAxisAlignment: CrossAxisAlignment.end),
              ],
            ),
            const Divider(height: 32),
            _buildDetailItem('Delivery Address', order.deliveryAddress, isFullWidth: true),
            const Divider(height: 32),
            _buildDetailItem('Payment Method', order.paymentMethod, isFullWidth: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start, bool isFullWidth = false}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, style: const TextStyle(color: app_colors.kTextGrey)),
        const SizedBox(height: 4),
        SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: app_colors.kGrey800)),
        ),
      ],
    );
  }

  Widget _buildOrderItemsCard() {
    const deliveryFee = 40.0;
    final grandTotal = order.total + deliveryFee;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: app_colors.kGrey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...order.items.map((item) => _buildOrderItem(item)),
            const Divider(height: 32),
            _buildSummaryRow('Subtotal', '₹${order.total.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildSummaryRow('Delivery Fee', '₹${deliveryFee.toStringAsFixed(2)}'),
            const Divider(height: 32),
            _buildSummaryRow('Total Amount', '₹${grandTotal.toStringAsFixed(2)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('Qty: ${item.quantity}', style: const TextStyle(color: app_colors.kTextGrey)),
              ],
            ),
          ),
          Text('₹${(item.price * item.quantity).toStringAsFixed(2)}'),
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

  Widget _buildShareOptionsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: app_colors.kGrey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Receipt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt will be sent to your WhatsApp number'))),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('WhatsApp'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: app_colors.kSuccessGreen,
                      side: const BorderSide(color: app_colors.kSuccessGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt will be sent to your email address'))),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade600,
                      side: BorderSide(color: Colors.blue.shade600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download_outlined),
        label: const Text('Download Receipt'),
        style: ElevatedButton.styleFrom(
          backgroundColor: app_colors.kPrimaryTealDark,
          foregroundColor: app_colors.kWhite,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
