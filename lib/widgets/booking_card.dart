import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:home_service_app/models/booking.dart';
import 'package:home_service_app/models/enums.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/booking/update_booking.dart';
import 'package:home_service_app/screens/dispute_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final List<Widget> actions;
  final Widget? additionalContent;

  const BookingCard({
    super.key,
    required this.booking,
    required this.actions,
    this.additionalContent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<BookingProvider>(context, listen: false)
            .fetchSingleBooking(booking.id);
        Navigator.pushNamed(context, '/detail_booking');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      '${ApiService.API_URL_FILE}${booking.technicianProfileImage}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.technicianName,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(booking.serviceName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            'Location: ${booking.address.subcity}, ${booking.address.wereda}'),
                        Text(booking.scheduledDate),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(booking.description ?? '',
                  style: const TextStyle(
                      fontSize: 16, height: 1.5, color: Colors.grey)),
              if (additionalContent != null) ...[
                const SizedBox(height: 16),
                additionalContent!,
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actions,
              ),
            ],
          ),
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
                    : SizedBox.shrink();
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
          );
        },
      ),
    );
  }

  Widget _actionButton(String label, Color color,
      {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildReviewDisplay(Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            '${AppLocalizations.of(context)!.yourRating}: ${booking.review!.rating}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(booking.review!.review ?? '',
            style: const TextStyle(fontSize: 16)),
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
          title: Text(AppLocalizations.of(context)!.rateAndReview),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 8),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.writeYourReview,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .pleaseProvideRatingAndReview)),
                  );
                }
              },
              child: const Text('Submit Review'),
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
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        TextField(
          controller: reviewController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.writeYourReview,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
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
