import 'package:flutter/material.dart';
import 'package:home_service_app/models/rating.dart';
import 'package:home_service_app/models/techinician_detail.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:provider/provider.dart';

class TechncianDetailPage extends StatefulWidget {
  final int technicianId;

  const TechncianDetailPage({super.key, required this.technicianId});
  @override
  State<TechncianDetailPage> createState() => _TechncianDetailPageState();
}

class _TechncianDetailPageState extends State<TechncianDetailPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<HomeServiceProvider>(context, listen: false)
        .fetchTechnicianDetails(widget.technicianId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<HomeServiceProvider>(
        builder: (context, serviceProvider, child) {
          if (serviceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final techinicianDetail = serviceProvider.techinicianDetail;
          if (techinicianDetail == null) return Container();

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTechnicianCard(techinicianDetail),

                  // Business Hours
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 16),
                    child: Text("Business Hour",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: techinicianDetail.schedule != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (techinicianDetail.schedule!.mondayStart !=
                                      null &&
                                  techinicianDetail.schedule!.mondayEnd != null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Monday",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, bottom: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                              '${techinicianDetail.schedule!.mondayStart} - ${techinicianDetail.schedule!.mondayEnd}'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              if (techinicianDetail.schedule!.tuesdayStart !=
                                      null &&
                                  techinicianDetail.schedule!.tuesdayEnd !=
                                      null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Tuesday",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, bottom: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                              '${techinicianDetail.schedule!.tuesdayStart} - ${techinicianDetail.schedule!.tuesdayEnd}'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              if (techinicianDetail.schedule!.wednesdayStart !=
                                      null &&
                                  techinicianDetail.schedule!.wednesdayEnd !=
                                      null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Wednesday",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, bottom: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                              '${techinicianDetail.schedule!.wednesdayStart} - ${techinicianDetail.schedule!.wednesdayEnd}'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              if (techinicianDetail.schedule!.thursdayStart !=
                                      null &&
                                  techinicianDetail.schedule!.thursdayEnd !=
                                      null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Thursday",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, bottom: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                              '${techinicianDetail.schedule!.thursdayStart} - ${techinicianDetail.schedule!.thursdayEnd}'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              if (techinicianDetail.schedule!.fridayStart !=
                                      null &&
                                  techinicianDetail.schedule!.fridayEnd != null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Friday",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, bottom: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                              '${techinicianDetail.schedule!.fridayStart} - ${techinicianDetail.schedule!.fridayEnd}'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              if (techinicianDetail.schedule!.saturdayStart !=
                                      null &&
                                  techinicianDetail.schedule!.saturdayEnd !=
                                      null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Saturday",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, bottom: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                              '${techinicianDetail.schedule!.saturdayStart} - ${techinicianDetail.schedule!.saturdayEnd}'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              if (techinicianDetail.schedule!.sundayStart !=
                                      null &&
                                  techinicianDetail.schedule!.sundayEnd != null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Sunday",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, bottom: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                              '${techinicianDetail.schedule!.sundayStart} - ${techinicianDetail.schedule!.sundayEnd}'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          )
                        : const Text('No schedule available',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ),

                  // Ratings Section
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text("Ratings for ${techinicianDetail.name}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  techinicianDetail.reviews.isNotEmpty
                      ? Column(
                          children: techinicianDetail.reviews
                              .map((rating) => _buildReviewCard(rating))
                              .toList(),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('No one has rated yet',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTechnicianCard(TechinicianDetail tech) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  '${ApiService.API_URL_FILE}${tech.profileImage}',
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/profile.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tech.name ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: tech.services
                        .map((service) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                service.name,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Location",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${tech.subcity ?? ''}, ${tech.city ?? ''}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookings',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${tech.bookings ?? 0}',
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text(
                    'Rating',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color.fromARGB(255, 235, 173, 5), size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${tech.rating ?? 0}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("More about ${tech.name}",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.7))),
          const SizedBox(height: 6),
          Text(
            tech.bio ?? 'No bio available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              review.rating,
              (index) => const Icon(Icons.star, color: Colors.yellow, size: 16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.review,
            style: const TextStyle(fontSize: 16, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 8),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  '${ApiService.API_URL_FILE}${review.customer.profileImage}',
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/profile.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.customer.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(review.customer.email,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class RatingTile extends StatelessWidget {
  final Review rating;

  const RatingTile({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage(
                'https://example.com/reviewer-image.jpg'), // Replace with actual reviewer image URL
          ),
          title: Text(rating.customer.name),
          subtitle: Row(
            children: List.generate(
                rating.rating,
                (index) =>
                    const Icon(Icons.star, color: Colors.amber, size: 20)),
          ),
          trailing: Text(rating.rating.toString()),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(rating.review),
        ),
        const Divider(),
      ],
    );
  }
}
