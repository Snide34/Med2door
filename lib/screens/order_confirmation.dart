import 'package:flutter/material.dart';
import 'package:med2door/models/order.dart';
import 'package:med2door/screens/receipt_page.dart';
import 'package:med2door/utils/app_colours.dart' as app_colors;

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.kLightTeal.withAlpha(100),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: app_colors.kWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: app_colors.kPrimaryTeal.withAlpha(50),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_circle_outline, color: app_colors.kPrimaryTealDark, size: 96),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Order Placed Successfully! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: app_colors.kPrimaryTealDark),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your medicines are on the way. You\'ll receive them within 2-3 business days.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: app_colors.kTextGrey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/receipt',
                      arguments: const Order(
                        id: 'MD123456',
                        date: 'Dec 23, 2025',
                        status: 'Delivered',
                        items: [
                          OrderItem(id: '1', name: 'Paracetamol 500mg', price: 45, quantity: 2),
                          OrderItem(id: '2', name: 'Vitamin C Tablets', price: 120, quantity: 1),
                        ],
                        totalItems: 3,
                        total: 210,
                        deliveryAddress: '123 Main Street, City - 123456',
                        paymentMethod: 'UPI',
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app_colors.kPrimaryTealDark,
                    foregroundColor: app_colors.kWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('View Order Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: app_colors.kPrimaryTealDark,
                    side: const BorderSide(color: app_colors.kPrimaryTealDark, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
