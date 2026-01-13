import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:med2door/utils/utils.dart';
import 'package:med2door/utils/app_colours.dart';

class VerificationScreen extends StatefulWidget {
  final String mobileNumber;

  const VerificationScreen({super.key, required this.mobileNumber});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.isNotEmpty) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.sms,
        token: _otpCode,
        phone: widget.mobileNumber,
      );

      if (response.session != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/complete-profile');
        }
      } else {
        context.showSnackBar('Invalid OTP. Please try again.');
      }
    } on AuthException catch (e) {
      context.showSnackBar(e.message);
    } catch (e) {
      context.showSnackBar('An unexpected error occurred.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: widget.mobileNumber,
        channel: OtpChannel.sms,
      );
      context.showSnackBar('A new OTP has been sent.');
    } on AuthException catch (e) {
      context.showSnackBar(e.message);
    } catch (e) {
      context.showSnackBar('An unexpected error occurred.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: kBlack,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: kWhite,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const MobileVerificationIcon(),
              const SizedBox(height: 20),
              const Text(
                'Verify Mobile Number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTeal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "We've sent a 6-digit OTP to",
                style: TextStyle(fontSize: 16, color: kTextGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                widget.mobileNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => OtpBox(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    isFocused: _focusNodes[index].hasFocus,
                    onChanged: (value) {
                      if (value.isEmpty && index > 0) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_focusNodes[index - 1]);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: _resendOtp,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: kPrimaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccessButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: kWhite)
                      : const Text(
                          'Verify & Continue',
                          style: TextStyle(
                            fontSize: 18,
                            color: kWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Didn\'t receive the code?',
                style: TextStyle(color: kGrey),
              ),
              InkWell(
                onTap: () {},
                child: const Text(
                  'Contact Support',
                  style: TextStyle(
                    color: kPrimaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileVerificationIcon extends StatelessWidget {
  const MobileVerificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: kLightTeal,
        shape: BoxShape.circle,
        border: Border.all(color: kPrimaryTeal.withAlpha(26), width: 2),
      ),
      child: const Center(
        child: Icon(
          Icons.phone_android_outlined,
          size: 50,
          color: kPrimaryTeal,
        ),
      ),
    );
  }
}

class OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<String> onChanged;

  const OtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kBorderGrey, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kPrimaryTeal, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
