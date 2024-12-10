import 'package:flutter/material.dart';
import 'package:home_service_app/models/faq.dart';
import 'package:home_service_app/models/rating.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechniciansSection extends StatelessWidget {
  const TechniciansSection({super.key});

  @override
  Widget build(BuildContext context) {
    final technicians =
        Provider.of<HomeServiceProvider>(context).topTechnicians;

    return SizedBox(
      height: 200.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...technicians.map((tech) => _buildTechnicianCard(tech)),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(Technician tech) {
    return Container(
      height: 200.h,
      width: 200.w,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.grey[100],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      '${ApiService.API_URL_FILE}${tech.profileImage}'),
                  radius: 40.r,
                ),
                SizedBox(height: 10.h),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to technician profile page
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      child: const Text('View Profile',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(tech.name ?? 'No Name',
                    style: TextStyle(
                        fontSize: 22.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    SizedBox(width: 5.w),
                    Text(
                        '${tech.rating ?? 0} (${tech.completedJobs ?? 0} Reviews)',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16.sp,
                        )),
                  ],
                ),
                SizedBox(height: 5.h),
                SizedBox(height: 5.h),
                Wrap(
                  spacing: 8.0.w,
                  runSpacing: 4.0.h,
                  children: tech.services
                          .map((service) => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  service.name,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp),
                                ),
                              ))
                          .toList() ??
                      [],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerReviewsSection extends StatelessWidget {
  const CustomerReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = Provider.of<HomeServiceProvider>(context).reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Text("What the Customer Says",
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
        ),
        ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 8.w),
                const Icon(Icons.star, color: Colors.yellow, size: 16),
                Row(
                  children: List.generate(
                    review.rating,
                    (index) =>
                        const Icon(Icons.star, color: Colors.yellow, size: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(review.review,
                style: TextStyle(fontSize: 16.sp, height: 1.5.h)),
            SizedBox(height: 24.h),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      '${ApiService.API_URL_FILE}${review.customer.profileImage}'),
                  radius: 20.r,
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customer.name,
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Text(review.customer.email,
                        style: TextStyle(
                            fontSize: 14.sp, color: Colors.grey[600])),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeServiceProvider>(context);

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.0.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("FAQ",
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 20.h),
          ...provider.faqs.asMap().entries.map((entry) {
            int index = entry.key;
            FAQ faq = entry.value;
            return _buildFAQTile(faq);
          }),
        ],
      ),
    );
  }

  Widget _buildFAQTile(FAQ faq) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: Center(
            child:
                Icon(Icons.card_giftcard, color: Colors.grey[600], size: 26.sp),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(faq.question,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
              SizedBox(height: 5.h),
              Text(faq.answer, style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }
}
