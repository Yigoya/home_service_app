import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/models/booking.dart';
import 'package:home_service_app/models/enums.dart';
import 'package:home_service_app/models/user.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/profile/technician_drawer.dart';
import 'package:home_service_app/screens/profile/technician_schedule.dart';
import 'package:home_service_app/screens/profile/user_profile_card.dart';
import 'package:home_service_app/widgets/booking_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechnicianProfilePage extends StatefulWidget {
  const TechnicianProfilePage({super.key});

  @override
  State<TechnicianProfilePage> createState() => _TechnicianProfilePageState();
}

class _TechnicianProfilePageState extends State<TechnicianProfilePage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() async {
    await Provider.of<ProfilePageProvider>(context, listen: false)
        .fetchBookings();
    await Provider.of<ProfilePageProvider>(context, listen: false)
        .fetchTechnicianProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[200],
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 16.h),
              UserProfileComponent(
                  user: user!,
                  onImagePick: _pickImage,
                  onEditName: () => _showEditNameDialog(context, user)),
              SizedBox(height: 16.h),
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
                              EdgeInsets.only(left: 20.w, right: 20.w),
                          dividerColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          isScrollable: true,
                          indicator: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding: EdgeInsets.symmetric(
                              horizontal: 0.w, vertical: 6.h),
                          labelStyle: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500), //For Selected tab
                          unselectedLabelStyle: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w500),
                          tabs: [
                            Tab(text: AppLocalizations.of(context)!.pending),
                            Tab(text: AppLocalizations.of(context)!.accepted),
                            Tab(text: AppLocalizations.of(context)!.started),
                            Tab(text: AppLocalizations.of(context)!.completed),
                            Tab(text: AppLocalizations.of(context)!.declined),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              BookingList(
                                  isTechnician: true,
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
                                  isTechnician: true,
                                  status: BookingStatus.STARTED.toString(),
                                  bookings: bookings
                                      .where((b) =>
                                          b.status ==
                                          BookingStatus.STARTED.toString())
                                      .toList()),
                              BookingList(
                                  isTechnician: true,
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
                }),
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
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
                  : const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class BookingPendingList extends StatelessWidget {
  final List<Booking> bookings;

  const BookingPendingList({super.key, required this.bookings});

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
                                  BookingStatus.ACCEPTED.toString());
                          Provider.of<ProfilePageProvider>(context,
                                  listen: false)
                              .fetchBookings();
                        },
                        child: const Text('Accept'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Provider.of<BookingProvider>(context,
                                  listen: false)
                              .updateBookingStatus(
                                  booking.id, BookingStatus.DENIED.toString());
                          Provider.of<ProfilePageProvider>(context,
                                  listen: false)
                              .fetchBookings();
                        },
                        child: const Text('Decline',
                            style: TextStyle(color: Colors.red)),
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

  const BookingCompletedList({super.key, required this.bookings});

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
                      : const SizedBox.shrink()
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
        return Card(
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
                    TextButton(onPressed: () {}, child: const Text('Edit')),
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
        );
      },
    );
  }
}
