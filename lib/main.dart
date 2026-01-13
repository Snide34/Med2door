import 'package:flutter/material.dart';
import 'package:med2door/product.dart';
import 'package:med2door/screens/cart.dart';
import 'package:med2door/screens/checkout.dart';
import 'package:med2door/screens/login/login.dart';
import 'package:med2door/screens/login/profile.dart';
import 'package:med2door/screens/mainscreen.dart';
import 'package:med2door/screens/medicine_details.dart';
import 'package:med2door/screens/order_confirmation.dart';
import 'package:med2door/screens/order_history.dart';
import 'package:med2door/screens/order_tracking.dart';
import 'package:med2door/screens/receipt_page.dart';
import 'package:med2door/screens/search_page.dart';
import 'package:med2door/screens/splash.dart';
import 'package:med2door/screens/login/signup.dart';
import 'package:med2door/screens/login/user_Details.dart';
import 'package:med2door/screens/login/verification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Package:med2door/screens/prescription_order.dart';

import 'models/order.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uaozmhplybbnmxbmcfaf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVhb3ptaHBseWJibm14Ym1jZmFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMzQ5NDQsImV4cCI6MjA3ODcxMDk0NH0.ciGfHf2AfLboKjrpsVf2d85fzVWF9HBGNVBnFvXxrXk',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'med2door',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const CreateAccountScreen(),
        '/cart': (context) => const CartPage(),
        '/checkout': (context) => const CheckoutScreen(),
        '/order-confirmation': (context) => const OrderConfirmationScreen(),
        '/order-history': (context) => const OrderHistoryScreen(),
        '/order-tracking': (context) {
          final orderId = ModalRoute.of(context)!.settings.arguments as String;
          return OrderTrackingScreen(orderId: orderId);
        },
        '/receipt': (context) {
          final order = ModalRoute.of(context)!.settings.arguments as Order;
          return ReceiptScreen(order: order);
        },
        '/search': (context) => const SearchPage(),
        '/verification': (context) {
          final mobileNumber =
              ModalRoute.of(context)!.settings.arguments as String;
          return VerificationScreen(mobileNumber: mobileNumber);
        },
        '/complete-profile': (context) => const UserDetailsFormScreen(),
        '/main': (context) {
          final userName =
              ModalRoute.of(context)!.settings.arguments as String? ?? 'Guest';
          return MainScreen(userName: userName);
        },
        '/profile': (context) {
          return ProfilePage(
            onBack: () => Navigator.pop(context),
            onLogout: () {
              supabase.auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          );
        },
        '/prescription-order': (context) => PrescriptionOrderScreen(
          onBack: () => Navigator.of(context).pop(),
          onProceedToCheckout: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
          },
        ),
        '/medicine-details': (context) {
          final medicine = ModalRoute.of(context)!.settings.arguments as Product;
          return MedicineDetailsScreen(medicine: medicine);
        },
      },
      themeMode: ThemeMode.dark,
    );
  }
}
