import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:provider/provider.dart';
import 'package:home_service_app/provider/business_provider.dart';
import 'package:home_service_app/models/business_detail.dart';

class BusinessDetailPage extends StatefulWidget {
  final int businessId;

  const BusinessDetailPage({Key? key, required this.businessId})
      : super(key: key);

  @override
  _BusinessDetailPageState createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _businessData;
  List<dynamic> _reviews = [];
  List<dynamic> _services = [];
  double? _totalRating;

  // Review form controllers
  final _reviewCommentController = TextEditingController();
  int _reviewRating = 0;
  List<XFile> _reviewImages = [];
  bool _isSubmittingReview = false;
  String _reviewErrorMessage = '';
  final _imagePicker = ImagePicker();

  // Order form variables
  Map<int, int> _serviceQuantities = {};
  Map<int, Map<String, String>> _serviceOptions = {};
  Map<int, String> _serviceNotes = {};
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  String _specialInstructions = '';
  int? _serviceLocationId;
  int? _paymentMethodId = 1; // Default payment method
  bool _isSubmittingOrder = false;
  String _orderErrorMessage = '';

  // Enquiry form variables
  final _enquiryNameController = TextEditingController();
  final _enquiryEmailController = TextEditingController();
  final _enquiryPhoneController = TextEditingController();
  final _enquiryMessageController = TextEditingController();
  bool _isSubmittingEnquiry = false;
  String _enquiryErrorMessage = '';

  @override
  void dispose() {
    _reviewCommentController.dispose();
    _enquiryNameController.dispose();
    _enquiryEmailController.dispose();
    _enquiryPhoneController.dispose();
    _enquiryMessageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchBusinessDetails();
  }

  void _fetchBusinessDetails() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get the provider
      final provider = Provider.of<BusinessProvider>(context, listen: false);

      // Fetch business details using provider
      provider.fetchBusinessDetails(widget.businessId).then((_) {
        if (provider.businessDetailError.isEmpty) {
          setState(() {
            // Update state with data from provider
            _businessData = provider.businessData;
            _reviews = provider.reviews;
            _totalRating = _calculateRatingFromReviews(_reviews);
            log('Reviews :&&&& $_reviews');
            log('Total Rating :&&&& $_totalRating');
            _services = provider.services;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = provider.businessDetailError;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildReviewsTab() {
    return _reviews.isEmpty
        ? Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.rate_review_outlined,
                      size: 60,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Be the first to review this business',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _showReviewForm,
                    icon: const Icon(Icons.create, size: 20),
                    label: const Text(
                      'Write a Review',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Review summary
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_totalRating ?? 0.0}',
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (index) {
                                      double rating =
                                          _businessData?['rating'] ?? 0.0;
                                      return Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        child: Icon(
                                          index < rating.floor()
                                              ? Icons.star
                                              : (index < rating
                                                  ? Icons.star_half
                                                  : Icons.star_border),
                                          color: const Color(0xFFFFD700),
                                          size: 24,
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_reviews.length} reviews',
                                    style: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _showReviewForm,
                                icon: Icon(Icons.edit,
                                    size: 18, color: const Color(0xFF6366F1)),
                                label: const Text(
                                  'Write Review',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  backgroundColor:
                                      const Color(0xFF6366F1).withOpacity(0.1),
                                  side: BorderSide(
                                      color: const Color(0xFF6366F1)),
                                  foregroundColor: const Color(0xFF6366F1),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Rating distribution
                          // Column(
                          //   children: [
                          //     for (int i = 5; i >= 1; i--)
                          //       Padding(
                          //         padding:
                          //             const EdgeInsets.symmetric(vertical: 2),
                          //         child: Row(
                          //           children: [
                          //             Text(
                          //               '$i',
                          //               style: TextStyle(
                          //                 color: Colors.grey[600],
                          //                 fontSize: 14,
                          //               ),
                          //             ),
                          //             const SizedBox(width: 8),
                          //             Icon(Icons.star,
                          //                 color: Colors.amber, size: 14),
                          //             const SizedBox(width: 8),
                          //             Expanded(
                          //               child: LinearProgressIndicator(
                          //                 value: _calculateRatingPercentage(i),
                          //                 backgroundColor: Colors.grey[200],
                          //                 valueColor:
                          //                     AlwaysStoppedAnimation<Color>(
                          //                   _getRatingColor(i),
                          //                 ),
                          //                 minHeight: 8,
                          //                 borderRadius:
                          //                     BorderRadius.circular(4),
                          //               ),
                          //             ),
                          //             const SizedBox(width: 8),
                          //             Text(
                          //               '${_countRatings(i)}',
                          //               style: TextStyle(
                          //                 color: Colors.grey[600],
                          //                 fontSize: 14,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),

                  // Reviews list
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Only show first 5 reviews in the tab view
                        if (index < _reviews.length && index < 5) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: _buildReviewCard(_reviews[index]),
                          );
                        }
                        // Add a "View all reviews" button if there are more than 5 reviews
                        if (index == 5 && _reviews.length > 5) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: TextButton.icon(
                              onPressed: _showAllReviews,
                              icon: Icon(Icons.more_horiz,
                                  color: const Color(0xFF6366F1)),
                              label: Text(
                                'View all ${_reviews.length} reviews',
                                style: TextStyle(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      color: const Color(0xFF6366F1)),
                                ),
                                backgroundColor:
                                    const Color(0xFF6366F1).withOpacity(0.1),
                                foregroundColor: const Color(0xFF6366F1),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      // +1 for the "View all" button if necessary
                      childCount: _reviews.length <= 5 ? _reviews.length : 6,
                    ),
                  ),

                  // Add bottom padding for FAB
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ],
          );
  }

  // Helper method to show all reviews
  void _showAllReviews() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Reviews (${_reviews.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildReviewCard(_reviews[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Calculate rating from reviews
  double _calculateRatingFromReviews(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0.0;
    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review['rating'] as num;
    }
    return totalRating / reviews.length;
  }

  // Helper method to calculate the percentage of ratings for each star level
  double _calculateRatingPercentage(int stars) {
    if (_reviews.isEmpty) return 0.0;
    final count = _countRatings(stars);
    return count / _reviews.length;
  }

  // Helper method to count ratings for a specific star level
  int _countRatings(int stars) {
    return _reviews
        .where((review) => (review['rating'] as int? ?? 0) == stars)
        .length;
  }

  // Helper method to get color for rating bar
  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildServicesTab() {
    return _services.isEmpty
        ? Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.business_center_outlined,
                      size: 60,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No services available',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'This business hasn\'t added any services yet',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(
                top: 16,
                bottom: 100,
                left: 16,
                right: 16), // Add padding for FAB
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              final serviceId = service['id'] as int;

              // Ensure service is initialized in the quantities map
              if (_serviceQuantities[serviceId] == null) {
                _serviceQuantities[serviceId] = 1;
              }

              final hasImage = service['image_url'] != null;

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service image if available
                      if (hasImage)
                        Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: service['image_url'] as String,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Price tag overlay
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  '\$${service['price']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service name and price (if no image)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    service['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (!hasImage)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Text(
                                      '${service['price']} Birr',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Service info badges
                            if (service['duration'] != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    // Duration badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.blue[700],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${service['duration']} mins',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Service description
                            if (service['description'] != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  service['description'] as String,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    height: 1.5,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                            // Order section with divider
                            Divider(color: Colors.grey[200], thickness: 1),
                            const SizedBox(height: 16),

                            // Quantity and order section
                            Row(
                              children: [
                                // Quantity label
                                Text(
                                  'Quantity:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Quantity selector
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[100],
                                  ),
                                  child: Row(
                                    children: [
                                      // Decrease button
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (_serviceQuantities[
                                                      serviceId]! >
                                                  1) {
                                                _serviceQuantities[serviceId] =
                                                    _serviceQuantities[
                                                            serviceId]! -
                                                        1;
                                              }
                                            });
                                          },
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              Icons.remove,
                                              size: 20,
                                              color: _serviceQuantities[
                                                          serviceId]! >
                                                      1
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Quantity display
                                      Container(
                                        width: 40,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${_serviceQuantities[serviceId]}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),

                                      // Increase button
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _serviceQuantities[serviceId] =
                                                  _serviceQuantities[
                                                          serviceId]! +
                                                      1;
                                            });
                                          },
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              Icons.add,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),

                                // Total price
                                Text(
                                  '${((service['price'] as num) * _serviceQuantities[serviceId]!).toStringAsFixed(2)} Birr',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Order button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _showOrderForm(service),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.grey[100],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Order Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // Show order form in a bottom sheet
  void _showOrderForm(Map<String, dynamic> service) {
    // Reset order form state for this service
    final serviceId = service['id'];
    _serviceQuantities[serviceId] = 1;
    _serviceOptions[serviceId] = {};
    _serviceNotes[serviceId] = '';
    _scheduledDate = null;
    _scheduledTime = null;
    _specialInstructions = '';
    _orderErrorMessage = '';

    // Get service options if available
    List<dynamic> options = service['options'] ?? [];

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order ${service['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quantity:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _serviceQuantities[serviceId]! > 1
                                  ? () {
                                      setState(() {
                                        _serviceQuantities[serviceId] =
                                            _serviceQuantities[serviceId]! - 1;
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              '${_serviceQuantities[serviceId]}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _serviceQuantities[serviceId] =
                                      _serviceQuantities[serviceId]! + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Service options
                    if (options.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Options:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...options.map((option) {
                        final optionName = option['name'];
                        final optionValues =
                            List<String>.from(option['values']);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(optionName),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _serviceOptions[serviceId]![optionName],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: optionValues.map((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _serviceOptions[serviceId]![optionName] =
                                        newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],

                    // Special notes
                    const SizedBox(height: 16),
                    const Text(
                      'Special Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) {
                        _serviceNotes[serviceId] = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Any special requests...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),

                    // Schedule date and time
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Schedule:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _scheduledDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 90)),
                              );
                              if (date != null) {
                                setState(() {
                                  _scheduledDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.grey[600], size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _scheduledDate == null
                                        ? 'Select Date'
                                        : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
                                    style: TextStyle(
                                      color: _scheduledDate == null
                                          ? Colors.grey[600]
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _scheduledTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  _scheduledTime = time;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.grey[600], size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _scheduledTime == null
                                        ? 'Select Time'
                                        : _scheduledTime!.format(context),
                                    style: TextStyle(
                                      color: _scheduledTime == null
                                          ? Colors.grey[600]
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_orderErrorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _orderErrorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmittingOrder
                            ? null
                            : () => _submitOrder(context, service),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.grey[100],
                          side: BorderSide(color: Colors.grey[300]!),
                          foregroundColor: Colors.black,
                        ),
                        child: _isSubmittingOrder
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Order Now - ${((service['price'] as num) * _serviceQuantities[serviceId]!).toStringAsFixed(2)} Birr'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Submit order to the backend
  Future<void> _submitOrder(
      BuildContext context, Map<String, dynamic> service) async {
    // Validate form
    if (_scheduledDate == null || _scheduledTime == null) {
      setState(() {
        _orderErrorMessage = 'Please select date and time';
      });
      return;
    }

    // Check if date time is in the future
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      _scheduledDate!.year,
      _scheduledDate!.month,
      _scheduledDate!.day,
      _scheduledTime!.hour,
      _scheduledTime!.minute,
    );

    if (scheduledDateTime.isBefore(now)) {
      setState(() {
        _orderErrorMessage = 'Please select a future date and time';
      });
      return;
    }

    final serviceId = service['id'];
    setState(() {
      _isSubmittingOrder = true;
      _orderErrorMessage = '';
    });

    try {
      // Create order items
      final List<Map<String, dynamic>> items = [];

      items.add({
        'serviceId': serviceId,
        'quantity': _serviceQuantities[serviceId],
        'selectedOptions': _serviceOptions[serviceId] ?? {},
        'notes': _serviceNotes[serviceId] ?? '',
      });

      // Get the provider
      final provider = Provider.of<BusinessProvider>(context, listen: false);

      // Submit order using provider
      final success = await provider.placeOrderRaw(
        businessId: widget.businessId,
        items: items,
        serviceLocationId: 3, // Mock location ID
        paymentMethodId: 1, // Mock payment method ID
        scheduledDateTime: scheduledDateTime,
        specialInstructions: _specialInstructions,
      );

      if (success) {
        // Reset form state
        _serviceQuantities[serviceId] = 1;
        _serviceOptions[serviceId]?.clear();
        _serviceNotes[serviceId] = '';
        _scheduledDate = null;
        _scheduledTime = null;
        _specialInstructions = '';

        // Order placed successfully
        if (context.mounted) {
          Navigator.pop(context); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service ordered successfully'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Handle error
        setState(() {
          _orderErrorMessage = provider.orderError;
          _isSubmittingOrder = false;
        });
      }
    } catch (e) {
      setState(() {
        _orderErrorMessage = 'Error: $e';
        _isSubmittingOrder = false;
      });
    }
  }

  // Build review card widget
  Widget _buildReviewCard(Map<String, dynamic> review) {
    final int rating = review['rating'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    (review['name'] ?? 'A')[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review['name'] ?? 'Anonymous User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$rating.0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        review['date'] ?? 'Unknown date',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        review['comment'] ?? 'No comment provided.',
                        style: TextStyle(
                          color: Colors.grey[800],
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Review images
          if (review['images'] != null && review['images'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review['images'].length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Show image in full screen
                        _showFullScreenImage(context, review['images'][index]);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: ApiService.API_URL_FILE +
                                review['images'][index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.error_outline,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Response section if available
          if (review['response'] != null && review['response'].isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storefront,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Business Response',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review['response'],
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Show review form in a bottom sheet
  void _showReviewForm() {
    // Reset review form state
    _reviewRating = 0;
    _reviewCommentController.clear();
    _reviewImages.clear();
    _reviewErrorMessage = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Write a Review',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap stars to rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _reviewRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              _reviewRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reviewCommentController,
                      decoration: const InputDecoration(
                        labelText: 'Comment',
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Photos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Add'),
                          onPressed: () async {
                            final images = await _imagePicker.pickMultiImage();
                            if (images.isNotEmpty) {
                              setState(() {
                                _reviewImages.addAll(images);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (_reviewImages.isNotEmpty)
                      Container(
                        height: 100,
                        margin: const EdgeInsets.only(top: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _reviewImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(_reviewImages[index].path),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _reviewImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    if (_reviewErrorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _reviewErrorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmittingReview
                            ? null
                            : () => _submitReview(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmittingReview
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Submit Review'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Submit review to the backend
  Future<void> _submitReview(BuildContext context) async {
    // Validate form
    if (_reviewRating == 0) {
      setState(() {
        _reviewErrorMessage = 'Please select a rating';
      });
      return;
    }

    setState(() {
      _isSubmittingReview = true;
      _reviewErrorMessage = '';
    });

    try {
      // Get current user ID from storage (mock user ID 4 for now)
      final userId = 4; // In a real app, get this from user authentication

      // Get the provider
      final provider = Provider.of<BusinessProvider>(context, listen: false);

      // Submit review using provider
      final success = await provider.submitReview(
        businessId: widget.businessId,
        userId: userId,
        rating: _reviewRating,
        comment: _reviewCommentController.text.isNotEmpty
            ? _reviewCommentController.text
            : null,
        images: _reviewImages.isNotEmpty ? _reviewImages : null,
      );

      if (success) {
        // Reset form
        _reviewRating = 0;
        _reviewCommentController.clear();
        _reviewImages.clear();

        // Review submitted successfully
        if (context.mounted) {
          Navigator.pop(context); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully')),
          );
        }

        // Update UI with new data
        setState(() {
          _businessData = provider.businessData;
          _reviews = provider.reviews;
          _services = provider.services;
        });
      } else {
        // Handle error
        setState(() {
          _reviewErrorMessage = provider.reviewError;
          _isSubmittingReview = false;
        });
      }
    } catch (e) {
      setState(() {
        _reviewErrorMessage = 'Error: $e';
        _isSubmittingReview = false;
      });
    }
  }

  // Add a method to build the About tab
  Widget _buildAboutTab() {
    if (_businessData == null) {
      return const Center(
        child: Text('No business information available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description section

          Text(
            'About ${_businessData?['name']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _businessData!['description'] ?? 'No description available.',
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Business hours section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time,
                        color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Business Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBusinessHours(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contact information section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.contact_phone,
                        color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildContactRow(
                  Icons.phone,
                  'Phone',
                  _businessData!['phone'] ?? 'Not available',
                  () {
                    final phone = _businessData!['phone'];
                    if (phone != null && phone.isNotEmpty) {
                      _launchUrl('tel:$phone');
                    }
                  },
                ),
                const Divider(height: 24),
                _buildContactRow(
                  Icons.email,
                  'Email',
                  _businessData!['email'] ?? 'Not available',
                  () {
                    final email = _businessData!['email'];
                    if (email != null && email.isNotEmpty) {
                      _launchUrl('mailto:$email');
                    }
                  },
                ),
                const Divider(height: 24),
                _buildContactRow(
                  Icons.location_on,
                  'Address',
                  _businessData!['location'] != null
                      ? "${_businessData!['location']['street']}, ${_businessData!['location']['city']}, ${_businessData!['location']['state']}, ${_businessData!['location']['country']}"
                      : 'Not available',
                  () {
                    _openMap();
                  },
                ),
                const Divider(height: 24),
                _buildContactRow(
                  Icons.language,
                  'Website',
                  _businessData!['website'] ?? 'Not available',
                  () {
                    _openWebsite();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Location map section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.map,
                        color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _openMap,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map,
                                    size: 48,
                                    color: Theme.of(context).primaryColor),
                                const SizedBox(height: 8),
                                const Text('View on Google Maps',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Enquiry section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.contact_support,
                        color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Send Enquiry',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildEnquiryForm(),
              ],
            ),
          ),
          // Add bottom padding for better scrolling experience
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Add a method to build the Gallery tab
  Widget _buildGalleryTab() {
    // Get gallery images from the provider
    final provider = Provider.of<BusinessProvider>(context, listen: false);
    final businessDetail = provider.businessDetail;

    if (businessDetail == null || businessDetail.gallery.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 60,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No gallery images available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'This business hasn\'t added any gallery images yet',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.0,
      ),
      itemCount: businessDetail.gallery.length,
      itemBuilder: (context, index) {
        final imageUrl = businessDetail.gallery[index];
        return GestureDetector(
          onTap: () =>
              _showGalleryFullScreenImage(imageUrl, businessDetail.gallery),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: '${ApiService.API_URL_FILE}$imageUrl',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE2E8F0),
                        const Color(0xFFCBD5E1),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF1F5F9),
                        const Color(0xFFE2E8F0),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to show full-screen gallery image
  void _showGalleryFullScreenImage(String imageUrl, List<String> allImages) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Gallery',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          body: PageView.builder(
            itemCount: allImages.length,
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: '${ApiService.API_URL_FILE}${allImages[index]}',
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        strokeWidth: 3,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 60,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method to build business hours
  Widget _buildBusinessHours() {
    final openingHours = _businessData!['openingHours'];
    if (openingHours == null) {
      return const Text('Business hours not available');
    }

    return Column(
      children: [
        _buildBusinessHourRow(
            'Monday',
            _formatHours(
                openingHours['mondayOpen'], openingHours['mondayClose'])),
        _buildBusinessHourRow(
            'Tuesday',
            _formatHours(
                openingHours['tuesdayOpen'], openingHours['tuesdayClose'])),
        _buildBusinessHourRow(
            'Wednesday',
            _formatHours(
                openingHours['wednesdayOpen'], openingHours['wednesdayClose'])),
        _buildBusinessHourRow(
            'Thursday',
            _formatHours(
                openingHours['thursdayOpen'], openingHours['thursdayClose'])),
        _buildBusinessHourRow(
            'Friday',
            _formatHours(
                openingHours['fridayOpen'], openingHours['fridayClose'])),
        _buildBusinessHourRow(
            'Saturday',
            _formatHours(
                openingHours['saturdayOpen'], openingHours['saturdayClose'])),
        _buildBusinessHourRow(
            'Sunday',
            _formatHours(
                openingHours['sundayOpen'], openingHours['sundayClose'])),
      ],
    );
  }

  // Helper method to format business hours
  String _formatHours(String? open, String? close) {
    if (open == null || open.isEmpty || close == null || close.isEmpty) {
      return 'Closed';
    }
    return '$open - $close';
  }

  // Helper method to build business hour row
  Widget _buildBusinessHourRow(String day, String hours) {
    final bool isToday = day == _getCurrentDay();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Colors.blue : Colors.grey[800],
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Colors.blue : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get current day
  String _getCurrentDay() {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final now = DateTime.now();
    // DateTime.weekday returns values 1-7 where 1 is Monday
    return weekdays[now.weekday - 1];
  }

  // Helper method to build contact information row
  Widget _buildContactRow(
      IconData icon, String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  // Helper method to open URL
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await url_launcher.canLaunchUrl(url)) {
      await url_launcher.launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch the link')),
        );
      }
    }
  }

  // Helper method to open website
  void _openWebsite() {
    final website = _businessData?['website'];
    if (website != null && website.isNotEmpty) {
      String url = website;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      _launchUrl(url);
    }
  }

  // Helper method to open map
  void _openMap() {
    final location = _businessData?['location'];
    if (location != null) {
      final String address =
          "${location['street']}, ${location['city']}, ${location['state']}, ${location['country']}";
      _launchUrl('https://maps.google.com/?q=$address');
    }
  }

  // Helper method to show image in full screen
  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: ApiService.API_URL_FILE + imagePath,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build enquiry form widget
  Widget _buildEnquiryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field
        TextField(
          controller: _enquiryNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),

        // Email field
        TextField(
          controller: _enquiryEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter your email address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // Phone field
        TextField(
          controller: _enquiryPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // Message field
        TextField(
          controller: _enquiryMessageController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'Tell us about your enquiry...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            prefixIcon: Icon(Icons.message_outlined),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),

        // Error message
        if (_enquiryErrorMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _enquiryErrorMessage,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ],
            ),
          ),

        if (_enquiryErrorMessage.isNotEmpty) const SizedBox(height: 16),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmittingEnquiry ? null : _submitEnquiry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmittingEnquiry
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Send Enquiry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Submit enquiry to the backend
  Future<void> _submitEnquiry() async {
    // Validate form
    if (_enquiryNameController.text.trim().isEmpty) {
      setState(() {
        _enquiryErrorMessage = 'Please enter your name';
      });
      return;
    }

    if (_enquiryEmailController.text.trim().isEmpty) {
      setState(() {
        _enquiryErrorMessage = 'Please enter your email address';
      });
      return;
    }

    if (_enquiryPhoneController.text.trim().isEmpty) {
      setState(() {
        _enquiryErrorMessage = 'Please enter your phone number';
      });
      return;
    }

    if (_enquiryMessageController.text.trim().isEmpty) {
      setState(() {
        _enquiryErrorMessage = 'Please enter your message';
      });
      return;
    }

    setState(() {
      _isSubmittingEnquiry = true;
      _enquiryErrorMessage = '';
    });

    try {
      // Get the provider
      final provider = Provider.of<BusinessProvider>(context, listen: false);

      // Submit enquiry using provider
      final success = await provider.submitEnquiry(
        businessId: widget.businessId,
        name: _enquiryNameController.text.trim(),
        email: _enquiryEmailController.text.trim(),
        phoneNumber: _enquiryPhoneController.text.trim(),
        message: _enquiryMessageController.text.trim(),
      );

      if (success) {
        // Reset form
        _enquiryNameController.clear();
        _enquiryEmailController.clear();
        _enquiryPhoneController.clear();
        _enquiryMessageController.clear();

        // Reset loading state
        setState(() {
          _isSubmittingEnquiry = false;
        });

        // Enquiry submitted successfully
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enquiry submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Handle error
        setState(() {
          _enquiryErrorMessage = provider.orderError;
          _isSubmittingEnquiry = false;
        });
      }
    } catch (e) {
      setState(() {
        _enquiryErrorMessage = 'Error: $e';
        _isSubmittingEnquiry = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading business details...',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Business Details',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 48,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchBusinessDetails,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    print(
        '${ApiService.API_URL_FILE}${_businessData?['image']} image is image');
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with enhanced image background
          SliverAppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
              ),
            ),
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _businessData?['name'] ?? 'Business Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Enhanced background image with shimmer loading
                  CachedNetworkImage(
                    imageUrl:
                        '${ApiService.API_URL_FILE}${_businessData?['images'][0]}' ??
                            'https://via.placeholder.com/800x600',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFE2E8F0),
                            const Color(0xFFCBD5E1),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF475569),
                            Color(0xFF334155),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  // Enhanced gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Modern business rating summary with enhanced design
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20).copyWith(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${_totalRating ?? '0.0'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '(${_reviews.length} reviews)',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Enhanced open/closed status indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _businessData?['isOpen'] == true
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _businessData?['isOpen'] == true
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _businessData?['isOpen'] == true
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _businessData?['isOpen'] == true
                              ? 'Open Now'
                              : 'Closed',
                          style: TextStyle(
                            color: _businessData?['isOpen'] == true
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Enhanced quick action buttons with modern design
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAction(
                    icon: Icons.call,
                    label: 'Call',
                    onTap: () {
                      final phone = _businessData?['phone'];
                      if (phone != null && phone.isNotEmpty) {
                        _launchUrl('tel:$phone');
                      }
                    },
                    color: const Color(0xFF3B82F6),
                  ),
                  _buildQuickAction(
                    icon: Icons.directions,
                    label: 'Directions',
                    onTap: _openMap,
                    color: const Color(0xFF10B981),
                  ),
                  _buildQuickAction(
                    icon: Icons.language,
                    label: 'Website',
                    onTap: _openWebsite,
                    color: const Color(0xFF8B5CF6),
                  ),
                  _buildQuickAction(
                    icon: Icons.message,
                    label: 'WhatsApp',
                    onTap: () {
                      final phone = _businessData?['phone'];
                      if (phone != null && phone.isNotEmpty) {
                        _launchUrl('https://wa.me/$phone');
                      }
                    },
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ),

          // Modern Tab Bar with enhanced design
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFF6366F1),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Services'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Gallery'),
                ],
              ),
            ),
            pinned: true,
          ),

          // Tab content with enhanced styling
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(),
                _buildServicesTab(),
                _buildReviewsTab(),
                _buildGalleryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SliverAppBarDelegate for the tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
