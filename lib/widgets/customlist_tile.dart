import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isFinal;

  const CustomListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
        margin: EdgeInsets.only(top: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: !isFinal
              ? [
                  BoxShadow(
                    color: Colors.grey[100]!,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey[600],
                  size: 28.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}

// Usage in more_page.dart
