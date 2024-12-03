import 'package:flutter/material.dart';
import 'package:home_service_app/models/faq.dart';
import 'package:home_service_app/models/rating.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:provider/provider.dart';

class TechniciansSection extends StatelessWidget {
  const TechniciansSection({super.key});

  @override
  Widget build(BuildContext context) {
    final technicians =
        Provider.of<HomeServiceProvider>(context).topTechnicians;

    return SizedBox(
      height: 200,
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
      height: 200,
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      '${ApiService.API_URL_FILE}${tech.profileImage}'),
                  radius: 40,
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to technician profile page
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text('View Profile',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(tech.name ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    const SizedBox(width: 5),
                    Text(
                        '${tech.rating ?? 0} (${tech.completedJobs ?? 0} Reviews)',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        )),
                  ],
                ),
                const SizedBox(height: 5),
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
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("What the Customer Says",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
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
            const SizedBox(height: 24),
            Text(review.review,
                style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      '${ApiService.API_URL_FILE}${review.customer.profileImage}'),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customer.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(review.customer.email,
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[600])),
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16.0),
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
          const Text("FAQ",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: Center(
            child: Icon(Icons.card_giftcard, color: Colors.grey[600], size: 26),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(faq.question,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 5),
              Text(faq.answer, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
    // return ExpansionTile(
    //   title: Text(faq.question,
    //       style: const TextStyle(fontWeight: FontWeight.bold)),
    //   initiallyExpanded: faq.isExpanded,
    //   onExpansionChanged: (_) => provider.toggleFAQ(index),
    //   children: [
    //     Padding(padding: const EdgeInsets.all(16.0), child: Text(faq.answer))
    //   ],
    // );
  }
}
