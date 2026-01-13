import 'package:flutter/material.dart';
import 'package:med2door/utils/app_colours.dart';

extension BuildContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? kErrorRed : kSuccessGreen,
      ),
    );
  }
}
