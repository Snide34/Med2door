import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:med2door/utils/utils.dart';
import 'package:med2door/utils/app_colours.dart';

class PrescriptionOrderScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onProceedToCheckout;

  const PrescriptionOrderScreen({
    super.key,
    required this.onBack,
    required this.onProceedToCheckout,
  });

  @override
  State<PrescriptionOrderScreen> createState() => _PrescriptionOrderScreenState();
}

class _PrescriptionOrderScreenState extends State<PrescriptionOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _prescriptionFile;
  final _addressController = TextEditingController();
  bool _orderForSomeoneElse = false;
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  bool _isUploading = false;

  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _addressController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePrescriptionUpload() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _prescriptionFile = File(pickedFile.path);
      });
      context.showSnackBar('Prescription selected: ${pickedFile.name}');
    }
  }

  void _handleCurrentLocation() {
    context.showSnackBar('Fetching current location...', isError: false);
  }

  void _handleMapSearch() {
    context.showSnackBar('Map search would open here to select location', isError: false);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_prescriptionFile == null) {
      context.showSnackBar('Please upload a prescription.', isError: true);
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      context.showSnackBar('Please enter a delivery address.', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw 'User is not authenticated.';
      }

      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'prescriptions/$fileName';
      await _supabase.storage.from('user_uploads').upload(filePath, _prescriptionFile!);
      final fileUrl = _supabase.storage.from('user_uploads').getPublicUrl(filePath);

      final orderData = {
        'user_id': user.id,
        'prescription_url': fileUrl,
        'delivery_address': _addressController.text.trim(),
        'order_for_someone_else': _orderForSomeoneElse,
        'receiver_name': _orderForSomeoneElse ? _receiverNameController.text.trim() : null,
        'receiver_phone': _orderForSomeoneElse ? _receiverPhoneController.text.trim() : null,
        'status': 'Pending Verification',
      };

      await _supabase.from('prescription_orders').insert(orderData);

      context.showSnackBar('Order submitted successfully! A pharmacist will call you soon.');
      widget.onProceedToCheckout();
    } catch (e) {
      context.showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildUploadSection(),
                      const SizedBox(height: 16),
                      _buildAddressSection(),
                      const SizedBox(height: 16),
                      _buildReceiverSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryTeal, kPrimaryTealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: kPrimaryTeal, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              onTap: widget.onBack,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back_ios_new, color: kWhite, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order with Prescription',
                  style: TextStyle(color: kWhite, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Upload & order medicines',
                  style: TextStyle(color: kTeal100, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(color: kBlack.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: kLightPurple, borderRadius: BorderRadius.circular(8.0)),
                child: const Icon(Icons.description, color: kPurpleCTA, size: 20),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upload Prescription', style: TextStyle(color: kNeutral800, fontWeight: FontWeight.bold)),
                  Text('PDF, JPG or PNG format', style: TextStyle(color: kIconGrey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _handlePrescriptionUpload,
            child: Container(
              height: 128,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kPurple50,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: kPurple300, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file, color: kPurpleCTA, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    _prescriptionFile?.path.split('/').last ?? 'Click to upload prescription',
                    style: const TextStyle(color: kPurpleCTA, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Max size: 5MB',
                    style: TextStyle(color: kPurple300, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (_prescriptionFile != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: kPurple50,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: kPurple200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(color: kPurpleCTA, borderRadius: BorderRadius.circular(8.0)),
                    child: const Icon(Icons.description, color: kWhite, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _prescriptionFile!.path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Uploaded successfully', style: TextStyle(color: kIconGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _prescriptionFile = null),
                    child: const Text('Remove', style: TextStyle(color: kErrorRed)),
                  )
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: kBlue50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: kBlue200),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: kCategoryDevices),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Our pharmacist will verify your prescription and prepare your order',
                    style: TextStyle(color: kTextBlueGrey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(color: kBlack.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: kLightTeal, borderRadius: BorderRadius.circular(8.0)),
                child: const Icon(Icons.location_pin, color: kPrimaryTealDark, size: 20),
              ),
              const SizedBox(width: 8),
              const Text('Delivery Address', style: TextStyle(color: kNeutral800, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            readOnly: true,
            onTap: _handleMapSearch,
            decoration: InputDecoration(
              hintText: 'Search for your location...',
              prefixIcon: const Icon(Icons.search, color: kGrey),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: kBorderGrey)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: kBorderGrey)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: kPrimaryTealDark)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _handleCurrentLocation,
            icon: const Icon(Icons.near_me),
            label: const Text('Use Current Location', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryTealDark,
              side: const BorderSide(color: kPrimaryTealDark, width: 1.5),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              backgroundColor: kWhite,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            maxLines: 4,
            minLines: 4,
            validator: (value) => value!.trim().isEmpty ? 'Please enter a delivery address' : null,
            decoration: InputDecoration(
              hintText: 'Enter complete delivery address with landmarks...',
              contentPadding: const EdgeInsets.all(16.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: kBorderGrey)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: kBorderGrey)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: kPrimaryTealDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverSection() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(color: kBlack.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('This order is for someone else'),
            value: _orderForSomeoneElse,
            onChanged: (checked) => setState(() => _orderForSomeoneElse = checked ?? false),
            activeColor: kPrimaryTeal,
          ),
          if (_orderForSomeoneElse)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _receiverNameController,
                    validator: (value) => _orderForSomeoneElse && value!.trim().isEmpty ? 'Please enter receiver\'s name' : null,
                    decoration: const InputDecoration(hintText: 'Receiver\'s Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _receiverPhoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) => _orderForSomeoneElse && value!.trim().isEmpty ? 'Please enter receiver\'s phone' : null,
                    decoration: const InputDecoration(hintText: 'Receiver\'s Phone Number'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _isUploading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: kPrimaryTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isUploading
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(kWhite))
            : const Text('Submit', style: TextStyle(fontSize: 18, color: kWhite, fontWeight: FontWeight.bold)),
      ),
    );
  }
}