import 'package:flutter/material.dart';
import 'package:med2door/utils/app_colours.dart';

class PillIcon extends StatelessWidget {
  const PillIcon({super.key});

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
      child: Center(
        child: Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [kPillGradientStart, kPillGradientEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }
}
