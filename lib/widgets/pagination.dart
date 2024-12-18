import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Pagination extends StatelessWidget {
  final int totalPage;
  final int currentPage;
  final Function(int) onPageChanged;

  const Pagination({
    super.key,
    required this.totalPage,
    required this.currentPage,
    required this.onPageChanged,
  });

  List<Widget> _buildPageNumbers() {
    List<Widget> pageNumbers = [];
    for (int i = 1; i <= totalPage; i++) {
      pageNumbers.add(
        GestureDetector(
          onTap: () => onPageChanged(i),
          child: Container(
            width: 50.w,
            height: 50.h,
            margin: EdgeInsets.only(right: 4.w),
            decoration: BoxDecoration(
                color: i == currentPage ? Colors.blue : Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12.r)),
            child: Center(
              child: Text(
                '$i',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: i == currentPage ? Colors.white : Colors.black,
                  fontWeight:
                      i == currentPage ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return pageNumbers;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            child: Container(
                width: 50.w,
                height: 50.h,
                margin: EdgeInsets.only(right: 4.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12.r)),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: currentPage == 1 ? Colors.grey : Colors.black,
                )),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildPageNumbers(),
              ),
            ),
          ),
          GestureDetector(
            onTap: currentPage < totalPage
                ? () => onPageChanged(currentPage + 1)
                : null,
            child: Container(
                width: 50.w,
                height: 50.h,
                margin: EdgeInsets.only(right: 4.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12.r)),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: currentPage == totalPage ? Colors.grey : Colors.black,
                )),
          ),
        ],
      ),
    );
  }
}
