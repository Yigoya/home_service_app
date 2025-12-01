import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/promotion.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback? onTap;
  final bool showBusinessInfo;

  const PromotionCard({
    Key? key,
    required this.promotion,
    this.onTap,
    this.showBusinessInfo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280.w,
        height: 120.h, // Match image section height
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              // Promotion Image
              _buildImageSection(),

              // Bottom shade overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Promotion Details overlaid on image
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildDetailsSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 120.h,
      width: double.infinity,
      decoration: BoxDecoration(
        image: promotion.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(
                    'https://hulumoya.zapto.org/uploads/${promotion.imageUrl!}'),
                fit: BoxFit.cover,
              )
            : null,
        color: promotion.imageUrl == null ? Colors.grey.shade300 : null,
      ),
      child: Stack(
        children: [
          // Fallback icon if no image
          if (promotion.imageUrl == null)
            Center(
              child: Icon(
                Icons.local_offer,
                size: 48.sp,
                color: Colors.grey.shade600,
              ),
            ),

          // Discount Badge
          if (promotion.discountPercentage != null)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${promotion.discountPercentage!.toInt()}% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Promotion Type Badge
          Positioned(
            top: 8.h,
            left: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                promotion.type,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Featured Badge
          if (promotion.isFeatured)
            Positioned(
              top: 8.h,
              left: promotion.type == 'DISCOUNT' ? 70.w : 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 10.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            promotion.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 4.h),

          // Description
          Text(
            promotion.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2.0,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 6.h),

          // Business Info and Validity Period in a row
          Row(
            children: [
              // Business Info
              if (showBusinessInfo) ...[
                Icon(
                  Icons.business,
                  size: 14.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    promotion.businessName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.8),
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
              ],

              // Validity Period
              Icon(
                Icons.calendar_today,
                size: 12.sp,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  promotion.validityPeriod,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.7),
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (promotion.type.toUpperCase()) {
      case 'DISCOUNT':
        return Colors.orange;
      case 'FREE_SHIPPING':
        return Colors.blue;
      case 'BUY_ONE_GET_ONE':
        return Colors.purple;
      case 'FLASH_SALE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
