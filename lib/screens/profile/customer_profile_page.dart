import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/models/booking.dart';
import 'package:home_service_app/models/enums.dart';
import 'package:home_service_app/models/user.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/booking/update_booking.dart';
import 'package:home_service_app/screens/detail_booking.dart';
import 'package:home_service_app/screens/dispute_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/widgets/booking_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final ImagePicker _picker = ImagePicker();

  // Pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await Provider.of<ProfilePageProvider>(context, listen: false)
          .uploadProfileImage(FormData.fromMap({
        'file': await MultipartFile.fromFile(pickedFile.path),
      }));

      Provider.of<UserProvider>(context, listen: false).loadUser();
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ProfilePageProvider>(context, listen: false).fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user!.profileImage != null
                              ? NetworkImage(
                                  '${ApiService.API_URL}/uploads/${user.profileImage}')
                              : const AssetImage('assets/images/profile.png')
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              _pickImage();
                            },
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(user.name,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  _showEditNameDialog(context, user);
                                },
                              ),
                            ],
                          ),
                          Text(user.email),
                          Text(user.phoneNumber),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Booking Tabs and List
              Expanded(
                child: Consumer<ProfilePageProvider>(
                  builder: (context, bookingProvider, child) {
                    if (bookingProvider.isLoading ||
                        Provider.of<BookingProvider>(context).isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final bookings = bookingProvider.bookings;
                    return DefaultTabController(
                      length: 5,
                      child: Column(
                        children: [
                          TabBar(
                            labelPadding:
                                const EdgeInsets.only(left: 20, right: 20),
                            dividerColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            isScrollable: true,
                            indicator: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 6),
                            labelStyle: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500), //For Selected tab
                            unselectedLabelStyle: const TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w500),
                            tabs: [
                              Tab(text: AppLocalizations.of(context)!.pending),
                              Tab(text: AppLocalizations.of(context)!.accepted),
                              Tab(text: AppLocalizations.of(context)!.started),
                              Tab(
                                  text:
                                      AppLocalizations.of(context)!.completed),
                              Tab(text: AppLocalizations.of(context)!.denied),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: TabBarView(
                              children: [
                                BookingList(
                                    status: BookingStatus.PENDING.toString(),
                                    bookings: bookings
                                        .where((b) =>
                                            b.status ==
                                            BookingStatus.PENDING.toString())
                                        .toList()),
                                BookingList(
                                    status: BookingStatus.ACCEPTED.toString(),
                                    bookings: bookings
                                        .where((b) =>
                                            b.status ==
                                            BookingStatus.ACCEPTED.toString())
                                        .toList()),
                                BookingList(
                                    status: BookingStatus.STARTED.toString(),
                                    bookings: bookings
                                        .where((b) =>
                                            b.status ==
                                            BookingStatus.STARTED.toString())
                                        .toList()),
                                BookingList(
                                    status: BookingStatus.COMPLETED.toString(),
                                    bookings: bookings
                                        .where((b) =>
                                            b.status ==
                                            BookingStatus.COMPLETED.toString())
                                        .toList()),
                                BookingList(
                                    status: BookingStatus.DENIED.toString(),
                                    bookings: bookings
                                        .where((b) =>
                                            b.status ==
                                            BookingStatus.DENIED.toString())
                                        .toList()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void _showEditNameDialog(BuildContext context, User user) {
    final TextEditingController nameController =
        TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editName),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterYourName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel), // 'Cancel'
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await Provider.of<ProfilePageProvider>(context, listen: false)
                      .updateProfile({'name': nameController.text});
                  Provider.of<UserProvider>(context, listen: false).loadUser();
                  Navigator.of(context).pop();
                }
              },
              child: Provider.of<ProfilePageProvider>(context).isLoading
                  ? const CircularProgressIndicator()
                  : Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({required Color color, required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius - 5);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

class BookingAcceptedList extends StatelessWidget {
  final List<Booking> bookings;

  const BookingAcceptedList({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GestureDetector(
          onTap: () {
            Provider.of<BookingProvider>(context, listen: false)
                .fetchSingleBooking(booking.id);
            Navigator.pushNamed(context, '/detail_booking');
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(booking.serviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(booking.scheduledDate),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(booking.technicianName,
                      style: const TextStyle(fontSize: 16)),
                  Text(
                      'Location: ${booking.address.subcity}, ${booking.address.wereda}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () async {
                            await Provider.of<BookingProvider>(context,
                                    listen: false)
                                .updateBookingStatus(booking.id,
                                    BookingStatus.STARTED.toString());
                            Provider.of<ProfilePageProvider>(context,
                                    listen: false)
                                .fetchBookings();
                          },
                          child: const Text('Start')),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/dispute',
                                arguments: booking.id);
                          },
                          child: const Text('Dispute',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookingStartedList extends StatelessWidget {
  final List<Booking> bookings;

  const BookingStartedList({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GestureDetector(
          onTap: () {
            Provider.of<BookingProvider>(context, listen: false)
                .fetchSingleBooking(booking.id);
            Navigator.pushNamed(context, '/detail_booking');
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(booking.serviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(booking.scheduledDate),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(booking.technicianName,
                      style: const TextStyle(fontSize: 16)),
                  Text(
                      'Location: ${booking.address.subcity}, ${booking.address.wereda}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () async {
                            await Provider.of<BookingProvider>(context,
                                    listen: false)
                                .updateBookingStatus(booking.id,
                                    BookingStatus.COMPLETED.toString());
                            Provider.of<ProfilePageProvider>(context,
                                    listen: false)
                                .fetchBookings();
                          },
                          child: const Text('Complete')),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/dispute',
                                arguments: booking.id);
                          },
                          child: const Text('Dispute',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookingCompletedList extends StatelessWidget {
  final List<Booking> bookings;

  const BookingCompletedList({
    super.key,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GestureDetector(
          onTap: () {
            Provider.of<BookingProvider>(context, listen: false)
                .fetchSingleBooking(booking.id);
            Navigator.pushNamed(context, '/detail_booking');
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(booking.serviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(booking.scheduledDate),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(booking.technicianName,
                      style: const TextStyle(fontSize: 16)),
                  Text(
                      'Location: ${booking.address.subcity}, ${booking.address.wereda}'),
                  const SizedBox(height: 16),
                  booking.review != null
                      ? _buildReviewDisplay(booking)
                      : _buildReviewForm(booking, context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewDisplay(Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Rating: ${booking.review!.rating}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(booking.review!.review ?? '',
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildReviewForm(Booking booking, BuildContext context) {
    double rating = 0.0;
    final TextEditingController reviewController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rate and Review',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
          decoration: const InputDecoration(
            hintText: 'Write your review here',
            border: OutlineInputBorder(),
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
                const SnackBar(
                    content: Text('Please provide a rating and review')),
              );
            }
          },
          child: const Text('Submit Review'),
        ),
      ],
    );
  }
}

class BookingDeniedList extends StatelessWidget {
  final List<Booking> bookings;

  const BookingDeniedList({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GestureDetector(
          onTap: () {
            Provider.of<BookingProvider>(context, listen: false)
                .fetchSingleBooking(booking.id);
            Navigator.pushNamed(context, '/detail_booking');
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(booking.serviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(booking.scheduledDate),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(booking.technicianName,
                      style: const TextStyle(fontSize: 16)),
                  Text(
                      'Location: ${booking.address.subcity}, ${booking.address.wereda}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookingListt extends StatelessWidget {
  final List<Booking> bookings;

  const BookingListt({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GestureDetector(
          onTap: () {
            Provider.of<BookingProvider>(context, listen: false)
                .fetchSingleBooking(booking.id);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookingDetailsPage(),
                ));
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
                      Column(
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(booking.description ?? '',
                      style: const TextStyle(
                          fontSize: 16, height: 1.5, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UpdateBookingPage(booking: booking),
                              ));
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16)),
                            child: const Text('Edit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500))),
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(16)),
                            child: const Text('Dispute',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          )),
                      GestureDetector(
                        onTap: () async {
                          await Provider.of<BookingProvider>(context,
                                  listen: false)
                              .updateBookingStatus(booking.id,
                                  BookingStatus.CANCELED.toString());
                          Provider.of<ProfilePageProvider>(context,
                                  listen: false)
                              .fetchBookings();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16)),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
