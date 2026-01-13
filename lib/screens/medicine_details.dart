import 'package:flutter/material.dart';
import 'package:med2door/product.dart';
import 'package:med2door/utils/app_colours.dart' as app_colors;
import 'package:cached_network_image/cached_network_image.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Product medicine;

  const MedicineDetailsScreen({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.kGrey50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: app_colors.kGrey800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Medicine Details', style: TextStyle(color: app_colors.kGrey800, fontWeight: FontWeight.w600)),
        backgroundColor: app_colors.kWhite,
        elevation: 1,
        shadowColor: app_colors.kGrey.withAlpha(26),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image section
            Container(
              color: app_colors.kWhite,
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: medicine.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: app_colors.kGrey200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: app_colors.kGrey200,
                    child: const Icon(Icons.image_not_supported, color: app_colors.kGrey),
                  ),
                ),
              ),
            ),
            
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailsCard(context),
                  const SizedBox(height: 16),
                  _buildProductInfoCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildAddToCartButton(context),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: app_colors.kBlack.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medicine.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: app_colors.kGrey800),
          ),
          const SizedBox(height: 8),
          Text(
            'By ${medicine.manufacturer}',
            style: const TextStyle(fontSize: 14, color: app_colors.kGrey500),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: app_colors.kLightTeal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              medicine.category,
              style: const TextStyle(color: app_colors.kPrimaryTealDark, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            medicine.composition,
            style: const TextStyle(fontSize: 16, color: app_colors.kTextGrey, height: 1.5),
          ),
          const Divider(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price', style: TextStyle(fontSize: 14, color: app_colors.kGrey500)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${double.tryParse(medicine.price)?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(fontSize: 24, color: app_colors.kPrimaryTealDark, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Stock', style: TextStyle(fontSize: 14, color: app_colors.kGrey500)),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                       Icon(Icons.check_circle, color: app_colors.kSuccessGreen, size: 16),
                       SizedBox(width: 4),
                       Text(
                        'In Stock',
                        style: TextStyle(fontSize: 16, color: app_colors.kSuccessGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: app_colors.kBlack.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: app_colors.kGrey800),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Manufacturer', medicine.manufacturer),
          const Divider(height: 24),
          _buildInfoRow('Composition', medicine.composition),
          const Divider(height: 24),
          _buildInfoRow('Prescription', medicine.isPrescriptionRequired ? 'Required' : 'Not Required'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: app_colors.kGrey500, fontSize: 16),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: app_colors.kGrey800, fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app_colors.kWhite,
        boxShadow: [
          BoxShadow(
            color: app_colors.kBlack.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () {
            if (medicine.isPrescriptionRequired) {
              Navigator.of(context).pushNamed('/prescription-order');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${medicine.name} added to cart')),
              );
            }
          },
          icon: const Icon(Icons.shopping_cart_outlined, color: app_colors.kWhite),
          label: Text(
            'Add to Cart - ₹${double.tryParse(medicine.price)?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: app_colors.kPrimaryTealDark,
            foregroundColor: app_colors.kWhite,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}
