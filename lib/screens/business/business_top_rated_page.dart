import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/business_provider.dart';
import '../../widgets/app_bar_widget.dart';
import 'business_detail_page.dart';

class BusinessTopRatedPage extends StatefulWidget {
  const BusinessTopRatedPage({Key? key}) : super(key: key);

  @override
  State<BusinessTopRatedPage> createState() => _BusinessTopRatedPageState();
}

class _BusinessTopRatedPageState extends State<BusinessTopRatedPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Make sure we have data loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessProvider>(context, listen: false);
      if (provider.businessServices.isEmpty) {
        setState(() {
          _isLoading = true;
        });
        provider.initialize().then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        title: 'Top Rated Businesses',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<BusinessProvider>(
              builder: (context, provider, child) {
                // Get top-rated businesses (no limit, show all sorted by rating)
                final topRatedBusinesses =
                    provider.getTopRatedBusinesses(limit: 100);

                if (topRatedBusinesses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_center_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No businesses available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: topRatedBusinesses.length,
                  itemBuilder: (context, index) {
                    final business = topRatedBusinesses[index];
                    return _buildBusinessCard(business);
                  },
                );
              },
            ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    final rating = business['rating'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BusinessDetailPage(businessId: business['id']),
            ),
          );
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business image banner
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    business['imageUrl'] ??
                        'https://via.placeholder.com/400x150',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.business, size: 50),
                      );
                    },
                  ),
                ),

                // Business details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business['name'] ?? 'Unknown Business',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        business['description'] ?? 'No description available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business['address'] ?? 'No address available',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Services preview (first 2 services)
                      if (business['services'] != null &&
                          (business['services'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Popular Services:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(
                              (business['services'] as List).length > 2
                                  ? 2
                                  : (business['services'] as List).length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        color: Colors.green, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      business['services'][index]['name'] ??
                                          'Unknown service',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '\$${business['services'][index]['price']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if ((business['services'] as List).length > 2)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '+${(business['services'] as List).length - 2} more services',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Rating badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$rating',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category tag
            Positioned(
              top: 125,
              left: 12,
              child: Consumer<BusinessProvider>(
                builder: (context, provider, child) {
                  final category =
                      provider.getCategoryById(business['categoryId']);
                  if (category != null) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getColorFromHex(category['color'] ?? '#2196F3'),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIconData(category['icon'] ?? 'category'),
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category['name'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to convert hex color string to Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Helper method to get IconData from string
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home_repair_service':
        return Icons.home_repair_service;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'grass':
        return Icons.grass;
      case 'format_paint':
        return Icons.format_paint;
      default:
        return Icons.category;
    }
  }
}
