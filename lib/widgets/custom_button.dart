import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onLoad;
  final Color color;
  final double fontSize;
  final double verticalPadding;
  final double borderRadius;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.onLoad,
    this.color = Colors.blue,
    this.fontSize = 20,
    this.verticalPadding = 12,
    this.borderRadius = 12,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? onLoad : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: fontSize.sp),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
