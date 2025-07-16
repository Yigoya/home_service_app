import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/models/business.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/business_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/screens/business/business_detail_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/widgets/app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BusinessListPage extends StatefulWidget {
  final Service service;
  final int categoryId;

  const BusinessListPage({
    Key? key,
    required this.service,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<BusinessListPage> createState() => _BusinessListPageState();
}

class _BusinessListPageState extends State<BusinessListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Fetch businesses when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessProvider>(context, listen: false);
      final homeProvider =
          Provider.of<HomeServiceProvider>(context, listen: false);
      print("${widget.categoryId}");
      provider.fetchBusinessesByServiceId(
        widget.categoryId,
        locationId: homeProvider.selectedLocation?.id,
      );

      // Add scroll listener for pagination
      _scrollController.addListener(_scrollListener);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Load more businesses when reaching the end of the list
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<BusinessProvider>(context, listen: false);
      if (!provider.isLoading && provider.hasMorePages) {
        provider.loadMoreBusinesses();
      }
    }
  }

  // Toggle search view
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _resetSearch();
      }
    });
  }

  // Handle search submission
  void _handleSearch() {
    final query = _searchController.text.trim();
    final provider = Provider.of<BusinessProvider>(context, listen: false);
    provider.searchBusinesses(query);

    // Clear focus
    FocusScope.of(context).unfocus();
  }

  // Reset search
  void _resetSearch() {
    setState(() {
      _searchController.clear();
      if (_isSearching) _toggleSearch();
    });
    final provider = Provider.of<BusinessProvider>(context, listen: false);
    provider.resetSearch();

    // Clear focus
    FocusScope.of(context).unfocus();
  }

  // Handle phone call
  Future<void> _callPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  // Handle website launch
  Future<void> _launchWebsite(String website) async {
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch website')),
      );
    }
  }

  // Launch map with business location
  Future<void> _launchMap(Location location) async {
    String address = location.fullAddress;
    String query = Uri.encodeComponent(address);

    // Check if we have more specific location data
    String mapUrl;

    if (address.isNotEmpty) {
      // Use address for directions
      mapUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    } else if (location.city != null && location.city!.isNotEmpty) {
      // Fallback to just the city if we don't have a full address
      query = Uri.encodeComponent(location.city!);
      mapUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    } else {
      // If no location data at all, show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No location information available')),
      );
      return;
    }

    final Uri uri = Uri.parse(mapUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch map application')),
      );
    }
  }

  // WhatsApp launcher
  Future<void> _launchWhatsApp(String phone) async {
    final phoneNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = 'https://wa.me/$phoneNumber';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar with animation
          SizeTransition(
            sizeFactor: _animation,
            axisAlignment: -1.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search businesses...',
                          prefixIcon:
                              Icon(Icons.search, color: Colors.blue[400]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        onSubmitted: (_) => _handleSearch(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: _handleSearch,
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.blue[500],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Business location indicator
          Consumer<HomeServiceProvider>(
            builder: (context, homeProvider, _) {
              final location = homeProvider.selectedLocation;
              if (location != null) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[300]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Businesses in ${homeProvider.subCityNameInLanguage(location, homeProvider.locale)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),

          // Business listings
          Expanded(
            child: Consumer<BusinessProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.businesses.isEmpty) {
                  // Show loading shimmer
                  return _buildLoadingShimmer();
                }

                if (provider.businesses.isEmpty) {
                  // Show empty state
                  return _buildEmptyState(provider);
                }

                // Show business list
                return Stack(
                  children: [
                    // Business list
                    RefreshIndicator(
                      onRefresh: () async {
                        final homeProvider = Provider.of<HomeServiceProvider>(
                            context,
                            listen: false);
                        await provider.fetchBusinessesByServiceId(
                          widget.categoryId,
                          locationId: homeProvider.selectedLocation?.id,
                          query: provider.searchQuery,
                        );
                      },
                      child: ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        children: [
                          // Results count header
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 16.h, left: 16.w, right: 16.w),
                            child: Text(
                              '${provider.totalElements} Results for your search',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // Business listing
                          ...List.generate(
                            provider.businesses.length,
                            (index) => _buildBusinessCard(
                                provider.businesses[index], index),
                          ),

                          // Loading indicator for pagination
                          if (provider.hasMorePages)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.r),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue[400]!),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Loading overlay when fetching more data
                    if (provider.isLoading && provider.businesses.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4.h,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue[400]!),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Custom AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.service.name,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: Colors.black,
          ),
          onPressed: _toggleSearch,
        ),
      ],
    );
  }

  // Empty state widget
  Widget _buildEmptyState(BusinessProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business,
              size: 64.sp,
              color: Colors.blue[300],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No businesses found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              provider.searchQuery.isNotEmpty
                  ? 'We couldn\'t find any businesses matching your search'
                  : 'There are no businesses for this service yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          if (provider.searchQuery.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 24.h),
              child: ElevatedButton(
                onPressed: _resetSearch,
                child: Text('Clear search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // New business card design using only available data from the model
  Widget _buildBusinessCard(Business business, int index) {
    return GestureDetector(
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BusinessDetailPage(
                        businessId: business.id,
                      )),
            ),
        child: Container(
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business info row with image
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business image
                  Container(
                    width: 132.w,
                    height: 144.h,
                    child: business.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${ApiService.API_URL_FILE}${business.images[0]}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Color.fromARGB(97, 56, 146, 219),
                                child: Center(
                                  child: Icon(Icons.business,
                                      color: Color.fromARGB(255, 56, 145, 219),
                                      size: 40.sp),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Color.fromARGB(97, 56, 146, 219),
                            child: Center(
                              child: Icon(Icons.business,
                                  color: Color.fromARGB(255, 56, 145, 219),
                                  size: 40.sp),
                            ),
                          ),
                  ),

                  // Business details
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Featured flag (if business is featured)
                          if (business.isFeatured)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              margin: EdgeInsets.only(bottom: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                border: Border.all(color: Colors.amber[300]!),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Featured Business',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ),

                          // Verification badge
                          if (business.isVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              margin: EdgeInsets.only(bottom: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified,
                                      color: Colors.blue, size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Business name with verified icon

                          Text(
                            business.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "5.0",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Icon(Icons.star,
                                        color: Colors.white, size: 12.sp),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "8 Ratings",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          // Short description
                          Text(
                            business.description.length > 60
                                ? '${business.description.substring(0, 60)}...'
                                : business.description,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 6.h),

                          // Location and contact info

                          if (business.location.city != null &&
                              business.location.city!.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18.sp,
                                  color: Colors.grey[800],
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    business.location.city!,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[800],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 10.h),
              // if (_hasSocialMedia(business.socialMedia))
              //   Padding(
              //     padding: EdgeInsets.only(left: 10.r, right: 10.r, bottom: 10.r),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.end,
              //       children: [
              //         if (business.socialMedia.facebook != null &&
              //             business.socialMedia.facebook!.isNotEmpty)
              //           _buildSocialButton(Icons.facebook, Colors.blue[700]!,
              //               () => _launchUrl(business.socialMedia.facebook!)),
              //         if (business.socialMedia.twitter != null &&
              //             business.socialMedia.twitter!.isNotEmpty)
              //           _buildSocialButton(Icons.abc, Colors.blue[400]!,
              //               () => _launchUrl(business.socialMedia.twitter!)),
              //         if (business.socialMedia.instagram != null &&
              //             business.socialMedia.instagram!.isNotEmpty)
              //           _buildSocialButton(Icons.camera_alt, Colors.pink[400]!,
              //               () => _launchUrl(business.socialMedia.instagram!)),
              //         if (business.socialMedia.linkedin != null &&
              //             business.socialMedia.linkedin!.isNotEmpty)
              //           _buildSocialButton(Icons.work, Colors.blue[800]!,
              //               () => _launchUrl(business.socialMedia.linkedin!)),
              //       ],
              //     ),
              //   ),
              // Action buttons
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.w),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // Call Now button
                      Container(
                        width: 120.w,
                        child: InkWell(
                          onTap: () => _callPhone(business.phoneNumber),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 56, 145, 219),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.call,
                                    color: Colors.white, size: 20.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  'Call Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 10.w),

                      // Directions button (launches map)
                      Container(
                        width: 140.w,
                        child: InkWell(
                          onTap: () => _launchMap(business.location),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black87),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions,
                                    color: Colors.black87, size: 20.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  'Directions',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 10.w),

                      // WhatsApp button
                      Container(
                        width: 140.w,
                        child: InkWell(
                          onTap: () => _launchWhatsApp(business.phoneNumber),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.h, horizontal: 18.w),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.message,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'WhatsApp',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 10.w),

                      // Website button (only shown if website exists)
                      if (business.website.isNotEmpty)
                        Container(
                          width: 140.w,
                          child: InkWell(
                            onTap: () => _launchWebsite(business.website),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 24.w),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.public,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Website',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      if (business.website.isNotEmpty) SizedBox(width: 10.w),

                      // Space for additional buttons
                      SizedBox(width: 10.w),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // Check if business has any social media links
  bool _hasSocialMedia(SocialMedia socialMedia) {
    return (socialMedia.facebook != null && socialMedia.facebook!.isNotEmpty) ||
        (socialMedia.twitter != null && socialMedia.twitter!.isNotEmpty) ||
        (socialMedia.instagram != null && socialMedia.instagram!.isNotEmpty) ||
        (socialMedia.linkedin != null && socialMedia.linkedin!.isNotEmpty);
  }

  // Create social media button
  Widget _buildSocialButton(IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 18.sp,
          ),
        ),
      ),
    );
  }

  // Launch URL
  Future<void> _launchUrl(String url) async {
    String formattedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      formattedUrl = 'https://$url';
    }

    final Uri uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $formattedUrl')),
      );
    }
  }

  // Loading shimmer effect
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: 200.w,
                height: 24.h,
                color: Colors.white,
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                height: 14.h,
                color: Colors.white,
              ),
              SizedBox(height: 4.h),
              Container(
                width: double.infinity * 0.7,
                height: 14.h,
                color: Colors.white,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Container(
                    width: 100.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 120.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
