import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med2door/main.dart';
import 'package:med2door/utils/utils.dart';
import '../../utils/app_colours.dart' as AppColors;

class UserDetailsFormScreen extends StatefulWidget {
  const UserDetailsFormScreen({super.key});

  @override
  State<UserDetailsFormScreen> createState() => _UserDetailsFormScreenState();
}

class _UserDetailsFormScreenState extends State<UserDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();

  String _gender = '';
  File? _profileImage;
  File? _prescriptionFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, Function(File) onPicked) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        onPicked(File(pickedFile.path));
      });
    }
  }

  Future<String?> _uploadFile(File file, String bucket) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}';
    try {
      await supabase.storage.from(bucket).upload(fileName, file);
      return supabase.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = supabase.auth.currentUser;
      if (user == null) {
        context.showSnackBar('You are not logged in.');
        setState(() => _isLoading = false);
        return;
      }

      String? avatarUrl;
      if (_profileImage != null) {
        avatarUrl = await _uploadFile(_profileImage!, 'user_uploads');
      }

      final profileData = {
        'id': user.id,
        'full_name': _fullNameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'gender': _gender,
        'address': _addressController.text.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      try {
        await supabase.from('profiles').upsert(profileData);
        if (mounted) {
          context.showSnackBar('Profile saved successfully!');
          Navigator.pushReplacementNamed(
            context,
            '/main',
            arguments: _fullNameController.text.trim(),
          );
        }
      } catch (e) {
        context.showSnackBar('Failed to save profile: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      context.showSnackBar(
        'Location services are disabled. Please enable the services',
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        context.showSnackBar('Location permissions are denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      context.showSnackBar(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
      return false;
    }
    return true;
  }

  Future<void> _handleCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks[0];
      setState(() {
        _addressController.text =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';
      });
    } catch (e) {
      context.showSnackBar('Could not fetch location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleMapSearch() {
    context.showSnackBar(
      'Map search functionality would open here to select location',
    );
  }

  void _handlePrescriptionUpload() {
    _pickImage(ImageSource.gallery, (file) {
      setState(() {
        _prescriptionFile = file;
      });
    });
  }

  Widget _buildTextField({
    required String placeholder,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: Icon(icon, color: AppColors.kGrey500),
        filled: true,
        fillColor: AppColors.kWhite,
        // bg-white
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // rounded-xl
          borderSide: BorderSide(color: AppColors.kGrey200), // border-gray-200
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.kGrey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.kPrimaryTealDark, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // p-6
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0), // mb-6
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kPrimaryTealDark, // text-teal-600
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please fill in your details',
                      style: TextStyle(
                        color: AppColors.kGrey500,
                      ), // text-gray-500
                    ),
                  ],
                ),
              ),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Avatar Section ---
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 96, // w-24
                                height: 96, // h-24
                                decoration: BoxDecoration(
                                  color: AppColors.kGrey200, // bg-gray-200
                                  shape: BoxShape.circle,
                                  image: _profileImage != null
                                      ? DecorationImage(
                                          image: FileImage(_profileImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _profileImage == null
                                    ? Center(
                                        child: Icon(
                                          Icons.person_outline,
                                          size: 48,
                                          color: AppColors.kGrey500,
                                        ), // User icon
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    _pickImage(ImageSource.gallery, (file) {
                                      _profileImage = file;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors
                                          .kPrimaryTealDark, // bg-teal-600
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.kBlack.withOpacity(
                                            0.2,
                                          ),
                                          blurRadius: 6,
                                        ),
                                      ], // shadow-lg
                                    ),
                                    child: const Icon(
                                      Icons.upload,
                                      color: AppColors.kWhite,
                                      size: 16,
                                    ), // Upload icon
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Full Name Input ---
                        _buildTextField(
                          placeholder: "Full Name",
                          icon: Icons.person_outline,
                          controller: _fullNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16), // space-y-4
                        // --- Age & Gender Inputs ---
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                placeholder: "Age",
                                icon: Icons.calendar_today_outlined, // Calendar
                                keyboardType: TextInputType.number,
                                controller: _ageController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 58,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.kWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.kGrey200),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _gender.isEmpty ? null : _gender,
                                    hint: Text(
                                      'Gender',
                                      style: TextStyle(
                                        color: AppColors.kTextGrey,
                                      ),
                                    ),
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'male',
                                        child: Text('Male'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'female',
                                        child: Text('Female'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'other',
                                        child: Text('Other'),
                                      ),
                                    ],
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _gender = newValue ?? '';
                                      });
                                    },
                                    style: TextStyle(
                                      color: AppColors.kGrey600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Address Section ---
                        _buildAddressSection(),
                        const SizedBox(height: 16),

                        // --- Prescription Upload ---
                        _buildPrescriptionUploadSection(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Submit Button (Sticky Footer) ---
              Padding(
                padding: const EdgeInsets.only(top: 16.0), // pt-4
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPrimaryTealDark, // bg-teal-600
                    foregroundColor: AppColors.kWhite,
                    minimumSize: const Size(double.infinity, 48), // w-full h-12
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ), // rounded-xl
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : const Text(
                          'Save & Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kTeal100.withOpacity(
          0.5,
        ), // bg-teal-50 (Using kTeal100 as base)
        borderRadius: BorderRadius.circular(16), // rounded-2xl
      ),
      padding: const EdgeInsets.all(16), // p-4
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.kPrimaryTealDark,
              ), // MapPin
              const SizedBox(width: 8),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kPrimaryTealDark,
                ),
              ), // text-teal-700
            ],
          ),
          const SizedBox(height: 12),

          // Map Search Input (readOnly)
          _buildTextField(
            placeholder: 'Search for your location...',
            icon: Icons.search,
            controller: TextEditingController(),
            // Use a dummy controller
            readOnly: true,
            onTap: _handleMapSearch,
          ),
          const SizedBox(height: 12),

          // Current Location Button
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleCurrentLocation,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.near_me), // Navigation icon
            label: const Text(
              'Use Current Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.kPrimaryTealDark,
              // text-teal-600
              side: BorderSide(color: AppColors.kPrimaryTealDark),
              // border-teal-600
              minimumSize: const Size(double.infinity, 48),
              // w-full h-12
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // rounded-xl
              backgroundColor: AppColors.kWhite.withOpacity(
                0.9,
              ), // hover:bg-teal-100 equivalent
            ),
          ),
          const SizedBox(height: 12),

          // Address Textarea
          TextFormField(
            maxLines: 4,
            minLines: 4,
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Complete delivery address with landmarks...',
              filled: true,
              fillColor: AppColors.kWhite,
              contentPadding: const EdgeInsets.all(16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.kGrey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.kGrey200),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kPurple50, // bg-purple-50
        borderRadius: BorderRadius.circular(16), // rounded-2xl
      ),
      padding: const EdgeInsets.all(16), // p-4
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: AppColors.kPurpleCTA,
              ), // FileText
              const SizedBox(width: 8),
              Text(
                'Upload Prescription (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kPurple700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // File Upload Button/Area
          InkWell(
            onTap: _handlePrescriptionUpload,
            child: Container(
              height: 48, // h-12
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.kWhite,
                borderRadius: BorderRadius.circular(12), // rounded-xl
                border: Border.all(
                  color: AppColors.kPurple300,
                  style: BorderStyle.solid,
                  width: 2,
                ), // border-dashed border-purple-300
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 20,
                    color: AppColors.kPurpleCTA,
                  ), // Upload icon
                  const SizedBox(width: 8),
                  Text(
                    _prescriptionFile?.path.split('/').last ??
                        'Choose PDF or Image',
                    style: TextStyle(
                      color: AppColors.kPurpleCTA,
                      fontWeight: FontWeight.w600,
                    ), // text-purple-600
                  ),
                ],
              ),
            ),
          ),

          // Uploaded File Status
          if (_prescriptionFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: AppColors.kPurpleCTA,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _prescriptionFile!.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.kGrey600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _prescriptionFile = null),
                      child: Text(
                        'Remove',
                        style: TextStyle(color: AppColors.kErrorRed),
                      ), // text-red-500
                    ),
                  ],
                ),
              ),
            ),

          // Helper Text
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                'Upload prescription for prescription-only medicines',
                style: TextStyle(color: AppColors.kPurpleCTA, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
