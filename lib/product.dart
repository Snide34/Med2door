class Product {
  final String name;
  final String price;
  final String imageUrl;
  final String composition;
  final bool isPrescriptionRequired;
  final String category;
  final String manufacturer;

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.composition,
    required this.isPrescriptionRequired,
    required this.category,
    required this.manufacturer,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      price: map['price']?.toString() ?? '0.0',
      imageUrl: map['image_url'] ?? '',
      composition: map['composition'] ?? '',
      isPrescriptionRequired: map['is_prescripti'] ?? false,
      category: map['category'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
    );
  }
}
