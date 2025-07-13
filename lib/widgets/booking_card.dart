import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:home_service_app/models/booking.dart';
import 'package:home_service_app/models/enums.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
import 'package:home_service_app/screens/booking/update_booking.dart';
import 'package:home_service_app/screens/detail_booking.dart';
import 'package:home_service_app/screens/dispute_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/l10n/app_localizations.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final List<Widget> actions;
  final Widget? additionalContent;
  final bool isTechnician;

  const BookingCard({
    super.key,
    required this.booking,
    required this.actions,
    this.additionalContent,
    this.isTechnician = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<BookingProvider>(context, listen: false)
            .fetchSingleBooking(booking.id);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BookingDetailsPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 10.r,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey[300]!, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    '${ApiService.API_URL_FILE}${isTechnician ? booking.customerProfileImage : booking.technicianProfileImage}',
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/profile.png',
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          isTechnician
                              ? booking.customerName
                              : booking.technicianName,
                          style: TextStyle(
                              fontSize: 20.sp, fontWeight: FontWeight.bold)),
                      Text(booking.serviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          'Location: ${booking.address.subcity}, ${booking.address.wereda}',
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500)),
                      Text(timeRemaining(booking.scheduledDate),
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: Color.fromARGB(255, 0, 88, 22),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(booking.description ?? '',
                style: TextStyle(
                    fontSize: 14.sp, height: 1.5, color: Colors.grey)),
            if (additionalContent != null) ...[
              SizedBox(height: 16.h),
              additionalContent!,
            ],
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

class BookingList extends StatefulWidget {
  final List<Booking> bookings;
  final String status;
  final bool isTechnician;

  const BookingList(
      {super.key,
      required this.bookings,
      required this.status,
      this.isTechnician = false});

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  @override
  Widget build(BuildContext context) {
    if (widget.status == BookingStatus.STARTED.toString()) {
      Logger().d(widget.bookings.map((booking) => booking.toJson()).toList());
    }
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<ProfilePageProvider>(context, listen: false)
            .fetchBookings();
      },
      child: ListView.builder(
        itemCount: widget.bookings.length,
        itemBuilder: (context, index) {
          final booking = widget.bookings[index];

          List<Widget> actions = [];
          Widget? additionalContent;

          if (widget.isTechnician) {
            switch (widget.status) {
              case 'PENDING':
                actions = [
                  GestureDetector(
                    onTap: () async {
                      await Provider.of<BookingProvider>(context, listen: false)
                          .updateBookingStatus(
                              booking.id, BookingStatus.ACCEPTED.toString());
                      await Provider.of<ProfilePageProvider>(context,
                              listen: false)
                          .fetchBookings();
                    },
                    child: _actionButton(
                        AppLocalizations.of(context)!.accept, Colors.black),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Provider.of<BookingProvider>(context, listen: false)
                          .updateBookingStatus(
                              booking.id, BookingStatus.DENIED.toString());
                      await Provider.of<ProfilePageProvider>(context,
                              listen: false)
                          .fetchBookings();
                    },
                    child: _actionButton(
                        AppLocalizations.of(context)!.cancel, Colors.grey[300]!,
                        textColor: Colors.black),
                  )
                ];
                break;
              case 'ACCEPTED':
                break;
              case 'STARTED':
                break;
              case 'COMPLETED':
                additionalContent = booking.review != null
                    ? _buildReviewDisplay(booking)
                    : const SizedBox.shrink();
                break;
              default:
                actions = [];
            }
          } else {
            switch (widget.status) {
              case 'PENDING':
                actions = [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateBookingPage(booking: booking),
                          ));
                    },
                    child: _actionButton(
                        AppLocalizations.of(context)!.edit, Colors.black),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DisputePage(bookingId: booking.id),
                            ));
                      },
                      child: _actionButton(
                          AppLocalizations.of(context)!.dispute,
                          Colors.grey[300]!,
                          textColor: Colors.black)),
                  GestureDetector(
                    onTap: () async {
                      await Provider.of<BookingProvider>(context, listen: false)
                          .updateBookingStatus(
                              booking.id, BookingStatus.CANCELED.toString());
                      await Provider.of<ProfilePageProvider>(context,
                              listen: false)
                          .fetchBookings();
                    },
                    child: _actionButton(
                        AppLocalizations.of(context)!.cancel, Colors.grey[300]!,
                        textColor: Colors.black),
                  )
                ];
              case 'ACCEPTED':
                actions = [
                  GestureDetector(
                    onTap: () async {
                      await Provider.of<BookingProvider>(context, listen: false)
                          .updateBookingStatus(
                              booking.id, BookingStatus.STARTED.toString());
                      await Provider.of<ProfilePageProvider>(context,
                              listen: false)
                          .fetchBookings();
                    },
                    child: _actionButton('Start', Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/dispute',
                          arguments: booking.id);
                    },
                    child: _actionButton(AppLocalizations.of(context)!.dispute,
                        Colors.grey[300]!,
                        textColor: Colors.black),
                  ),
                ];
                break;
              case 'STARTED':
                actions = [
                  GestureDetector(
                    onTap: () async {
                      await _showReviewDialog(context, booking);
                      await Provider.of<BookingProvider>(context, listen: false)
                          .updateBookingStatus(
                              booking.id, BookingStatus.COMPLETED.toString());
                      await Provider.of<ProfilePageProvider>(context,
                              listen: false)
                          .fetchBookings();
                    },
                    child: _actionButton(
                        AppLocalizations.of(context)!.complete, Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/dispute',
                          arguments: booking.id);
                    },
                    child: _actionButton(AppLocalizations.of(context)!.dispute,
                        Colors.grey[300]!,
                        textColor: Colors.black),
                  ),
                ];
                break;
              case 'COMPLETED':
                additionalContent = booking.review != null
                    ? _buildReviewDisplay(booking)
                    : _buildReviewButton(booking, context);
                break;
              case 'DENIED':
                // No additional actions for denied bookings
                break;
              default:
                actions = [];
            }
          }

          return BookingCard(
            booking: booking,
            actions: actions,
            additionalContent: additionalContent,
            isTechnician: widget.isTechnician,
          );
        },
      ),
    );
  }

  Widget _actionButton(String label, Color color,
      {Color textColor = Colors.white}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(label,
          style: TextStyle(
              color: textColor, fontSize: 14.sp, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildReviewDisplay(Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            '${AppLocalizations.of(context)!.yourRating}: ${booking.review!.rating}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        SizedBox(height: 4.h),
        Text(booking.review!.review ?? '', style: TextStyle(fontSize: 14.sp)),
      ],
    );
  }

  Future<void> _showReviewDialog(BuildContext context, Booking booking) async {
    double rating = 0.0;
    final TextEditingController reviewController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            AppLocalizations.of(context)!.rateAndReview,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating Bar Section
                Text(
                  'Rating',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 10,
                    ),
                    onRatingUpdate: (newRating) {
                      rating = newRating;
                    },
                  ),
                ),
                SizedBox(height: 16.h),

                // Review TextField Section
                Text(
                  AppLocalizations.of(context)!.writeYourReview,
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: reviewController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.writeYourReview,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  maxLines: 4,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle:
                    TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),

            // Submit Button
            ElevatedButton(
              onPressed: () async {
                if (rating > 0 && reviewController.text.isNotEmpty) {
                  await Provider.of<BookingProvider>(context, listen: false)
                      .submitReview(
                          booking.id, rating.toInt(), reviewController.text);

                  Provider.of<ProfilePageProvider>(context, listen: false)
                      .fetchBookings();
                  Navigator.of(context).pop();
                } else {
                  // Show error inline if inputs are missing
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                          AppLocalizations.of(context)!
                              .pleaseProvideRatingAndReview,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                AppLocalizations.of(context)!.ok,
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 14.sp,
                                ),
                              )),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                textStyle:
                    TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewButton(Booking booking, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showReviewDialog(context, booking);
      },
      child: Text(AppLocalizations.of(context)!.giveReview),
    );
  }

  Widget _buildReviewForm(Booking booking, BuildContext context) {
    double rating = 0.0;
    final TextEditingController reviewController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.rateAndReview,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (newRating) {
            rating = newRating;
          },
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: reviewController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.writeYourReview,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 8.h),
        ElevatedButton(
          onPressed: () async {
            if (rating > 0 && reviewController.text.isNotEmpty) {
              await Provider.of<BookingProvider>(context, listen: false)
                  .submitReview(
                      booking.id, rating.toInt(), reviewController.text);
              Provider.of<ProfilePageProvider>(context, listen: false)
                  .fetchBookings();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(AppLocalizations.of(context)!
                        .pleaseProvideRatingAndReview)),
              );
            }
          },
          child: Text(AppLocalizations.of(context)!.submitReview),
        ),
      ],
    );
  }
}
