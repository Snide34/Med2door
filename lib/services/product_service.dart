import 'package:med2door/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  // Private constructor
  ProductService._privateConstructor();

  // Static instance
  static final ProductService _instance = ProductService._privateConstructor();

  // Factory constructor
  factory ProductService() {
    return _instance;
  }

  Future<List<Product>>? _productsFuture;

  Future<List<Product>> getProducts() {
    _productsFuture ??= _fetchProducts();
    return _productsFuture!;
  }

  Future<List<Product>> _fetchProducts() async {
    try {
      // Fetch products with a 15-second timeout to prevent indefinite hanging
      final response = await Supabase.instance.client
          .from('product')
          .select()
          .timeout(const Duration(seconds: 15));

      final productList = (response as List).map((data) => Product.fromMap(data)).toList();
      return productList;
    } catch (e) {
      // If an error occurs (e.g., timeout, network issue), print it and return an empty list.
      // This ensures the app doesn't get stuck.
      print('Error fetching products: $e');
      return [];
    }
  }
}
