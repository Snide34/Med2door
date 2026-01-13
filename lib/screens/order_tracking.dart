import 'package:flutter/material.dart';
import 'package:med2door/utils/app_colours.dart' as app_colors;

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.kGrey50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: app_colors.kWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Order Tracking', style: TextStyle(color: app_colors.kWhite, fontWeight: FontWeight.w600)),
        backgroundColor: app_colors.kPrimaryTealDark,
        elevation: 1,
        shadowColor: app_colors.kGrey.withAlpha(50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDeliveryEstimateCard(),
            const SizedBox(height: 16),
            _buildTrackingStepsCard(),
            const SizedBox(height: 16),
            _buildDeliveryAddressCard(),
            const SizedBox(height: 16),
            _buildDeliveryPartnerCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryEstimateCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: app_colors.kGrey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.local_shipping, color: app_colors.kSuccessGreen, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Arriving Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: app_colors.kSuccessGreen)),
                Text('Expected by 2:00 PM', style: TextStyle(color: app_colors.kTextGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStepsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: app_colors.kGrey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTrackingStep('Order Received', 'Your order has been placed successfully', 'Dec 23, 2025 - 10:30 AM', isCompleted: true),
            _buildTrackingStep('Pharmacist Verified', 'Prescription verified and medicines prepared', 'Dec 23, 2025 - 11:15 AM', isCompleted: true),
            _buildTrackingStep('Out for Delivery', 'Your order is on the way', 'Dec 23, 2025 - 12:45 PM', isActive: true),
            _buildTrackingStep('Delivered', 'Order will be delivered soon', 'Expected by 2:00 PM'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStep(String title, String subtitle, String timestamp, {bool isCompleted = false, bool isActive = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isActive ? app_colors.kPrimaryTeal : app_colors.kGrey200,
              ),
              child: Icon(isCompleted ? Icons.check : (isActive ? Icons.local_shipping : Icons.more_horiz), color: app_colors.kWhite, size: 16),
            ),
            if (!isActive)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? app_colors.kPrimaryTeal : app_colors.kGrey200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isCompleted || isActive ? app_colors.kGrey800 : app_colors.kGrey500)),
              Text(subtitle, style: const TextStyle(color: app_colors.kTextGrey)),
              const SizedBox(height: 4),
              Text(timestamp, style: const TextStyle(color: app_colors.kPrimaryTeal, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: app_colors.kGrey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: app_colors.kPrimaryTeal, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('123 Main Street, Apartment 4B, City Name - 123456', style: TextStyle(color: app_colors.kTextGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryPartnerCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: app_colors.kGrey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Partner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(radius: 24, backgroundColor: app_colors.kLightTeal, child: Text('RK', style: TextStyle(color: app_colors.kPrimaryTealDark, fontWeight: FontWeight.bold))),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Rajesh Kumar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('+91 98765 43210', style: TextStyle(color: app_colors.kTextGrey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_outlined),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: app_colors.kPrimaryTealDark,
                      foregroundColor: app_colors.kWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message_outlined),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: app_colors.kPrimaryTealDark,
                      side: const BorderSide(color: app_colors.kPrimaryTealDark),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
