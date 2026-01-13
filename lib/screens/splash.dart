import 'dart:async';
import 'package:flutter/material.dart';
import 'package:med2door/services/product_service.dart';
import 'package:med2door/utils/app_colours.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadAndRedirect();
  }

  Future<void> _loadAndRedirect() async {
    // Wait for all necessary data to be loaded.
    await Future.wait([
      ProductService().getProducts(),
      // Add other data-loading futures here if needed
      Future.delayed(const Duration(seconds: 2)), // Keep a minimum splash time
    ]);
    _performAuthCheck();
  }

  Future<void> _performAuthCheck() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('full_name')
          .eq('id', session.user.id)
          .single();

      if (!mounted) return;

      final userName = response['full_name'] as String? ?? 'Guest';

      if (userName != 'Guest') {
        Navigator.of(context).pushReplacementNamed('/main', arguments: userName);
      } else {
        Navigator.of(context).pushReplacementNamed('/complete-profile');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/complete-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kPrimaryTeal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can replace this with your app's logo
            Icon(Icons.local_hospital, size: 100, color: kWhite),
            SizedBox(height: 20),
            Text(
              'med2door',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: kWhite,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kWhite),
            ),
          ],
        ),
      ),
    );
  }
}
