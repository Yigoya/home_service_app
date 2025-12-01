import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/models/business.dart';
import 'package:home_service_app/models/business_detail.dart'
    as business_detail;
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/business_provider.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/screens/business/business_detail_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Sub-category model
class SubCategory {
  final int id;
  final String name;
  final IconData icon;
  final Color color;

  SubCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class BusinessListPage extends StatefulWidget {
  final Service service;
  final int categoryId;
  final List<Service>? subCategories;

  const BusinessListPage({
    Key? key,
    required this.service,
    required this.categoryId,
    this.subCategories,
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

  // Sub-category selection state
  String? _selectedSubCategory;
  List<SubCategory> _subCategories = [];

  @override
  void initState() {
    super.initState();

    // Initialize sub-categories from service data
    _initializeSubCategories();

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
      _fetchBusinesses();

      // Add scroll listener for pagination
      _scrollController.addListener(_scrollListener);
    });
  }

  // Initialize sub-categories from service data
  void _initializeSubCategories() {
    print("Initializing sub-categories...");
    print("Widget subCategories: ${widget.subCategories?.length ?? 0}");
    log("Widget subCategories: ${widget.subCategories}");

    if (widget.subCategories != null && widget.subCategories!.isNotEmpty) {
      _subCategories = widget.subCategories!.map((service) {
        // Generate colors and icons based on service index
        final colors = [
          Colors.green,
          Colors.orange,
          Colors.brown,
          Colors.blue,
          Colors.pink,
          Colors.red,
          Colors.purple,
          Colors.teal,
          Colors.amber,
          Colors.indigo,
        ];
        final icons = [
          Icons.eco,
          Icons.grain,
          Icons.local_cafe,
          Icons.agriculture,
          Icons.local_florist,
          Icons.store,
          Icons.pets,
          Icons.apple,
          Icons.local_drink,
          Icons.business,
        ];

        final index = widget.subCategories!.indexOf(service);
        print(
            "Creating sub-category: ${service.services.toString()} with ID: ${service.id}");
        return SubCategory(
          id: service.id,
          name: service.name,
          icon: icons[index % icons.length],
          color: colors[index % colors.length],
        );
      }).toList();
      print("Initialized ${_subCategories.length} sub-categories");
    } else {
      print("No sub-categories to initialize");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Fetch businesses based on selected sub-category or main category
  void _fetchBusinesses() {
    final provider = Provider.of<BusinessProvider>(context, listen: false);
    final homeProvider =
        Provider.of<HomeServiceProvider>(context, listen: false);

    // If a sub-category is selected, fetch businesses for that sub-category
    // Otherwise, fetch businesses for the main category
    int categoryId = widget.categoryId;
    print(
        "_fetchBusinesses called - Selected sub-category: $_selectedSubCategory");
    print("Main category ID: $categoryId");

    if (_selectedSubCategory != null) {
      // Find the sub-category ID from the selected sub-category name
      final selectedSubCat = _subCategories.firstWhere(
        (subCat) => subCat.name == _selectedSubCategory,
      );
      categoryId = selectedSubCat.id;
      print(
          "Using sub-category ID: $categoryId for sub-category: $_selectedSubCategory");
    } else {
      print("No sub-category selected, using main category ID: $categoryId");
    }

    print("Fetching businesses for category ID: $categoryId");

    // Clear existing businesses before fetching new ones
    provider.clearBusinesses();

    provider.fetchBusinessesByServiceId(
      widget.categoryId,
      locationId: homeProvider.selectedLocation?.id,
    );
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

  // Reset sub-category selection
  void _resetSubCategory() {
    setState(() {
      _selectedSubCategory = null;
    });
    _fetchBusinesses();
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

  // Show sub-category selection modal
  void _showSubCategoryModal() {
    print("_showSubCategoryModal called");
    print("Sub-categories count: ${_subCategories.length}");
    for (var subCat in _subCategories) {
      print("Sub-category: ${subCat.name} (ID: ${subCat.id})");
    }

    if (_subCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No sub-categories available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSubCategoryModal(),
    );
  }

  // Build sub-category selection modal
  Widget _buildSubCategoryModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.category,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Sub-Categories',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Choose the services you\'re interested in',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedSubCategory != null)
                  GestureDetector(
                    onTap: _resetSubCategory,
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.clear_all,
                        color: Colors.red[600],
                        size: 20.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Selected category chip
          if (_selectedSubCategory != null)
            Container(
              height: 50.h,
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8.w),
                    child: Chip(
                      label: Text(
                        _selectedSubCategory!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: _subCategories
                          .firstWhere(
                            (cat) => cat.name == _selectedSubCategory,
                          )
                          .color,
                      deleteIcon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      onDeleted: _resetSubCategory,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16.h),

          // Sub-categories list
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ListView.builder(
                itemCount: _subCategories.length,
                itemBuilder: (context, index) {
                  final category = _subCategories[index];
                  final isSelected = _selectedSubCategory == category.name;

                  return GestureDetector(
                    onTap: () {
                      print(
                          "Sub-category tapped: ${category.name} (ID: ${category.id})");
                      setState(() {
                        if (isSelected) {
                          _selectedSubCategory = null;
                          print("Deselected sub-category");
                        } else {
                          _selectedSubCategory = category.name;
                          print("Selected sub-category: $_selectedSubCategory");
                        }
                      });
                      // Fetch businesses for the selected sub-category
                      _fetchBusinesses();
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: isSelected ? category.color : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                              isSelected ? category.color : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? category.color.withOpacity(0.3)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: isSelected ? 12 : 8,
                            offset: Offset(0, isSelected ? 6 : 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Category name
                          Expanded(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          // Selection indicator
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16.sp,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[700],
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      shadowColor: Colors.blue.withOpacity(0.3),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16.sp,
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
    );
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
                if (provider.isLoading && provider.businessDetails.isEmpty) {
                  // Show loading shimmer
                  return _buildLoadingShimmer();
                }

                if (provider.businessDetails.isEmpty) {
                  // Show empty state
                  return _buildEmptyState(provider);
                }

                // Show business list
                return Column(
                  children: [
                    // Categories button - only show if there are sub-categories
                    if (_subCategories.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: 16.w, right: 16.w),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: _showSubCategoryModal,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: 40.h,
                              width: MediaQuery.of(context).size.width * .4,
                              decoration: BoxDecoration(
                                gradient: _selectedSubCategory != null
                                    ? LinearGradient(
                                        colors: [
                                          Colors.blue[400]!,
                                          Colors.blue[600]!
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.grey[200]!,
                                          Colors.grey[100]!
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(25.r),
                                border: Border.all(
                                  color: _selectedSubCategory != null
                                      ? Colors.blue[300]!
                                      : Colors.grey[400]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _selectedSubCategory != null
                                        ? Colors.blue.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                    blurRadius:
                                        _selectedSubCategory != null ? 12 : 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedSubCategory != null
                                        ? Icons.filter_list
                                        : Icons.menu_sharp,
                                    color: _selectedSubCategory != null
                                        ? Colors.white
                                        : Colors.grey[700],
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _selectedSubCategory == null
                                        ? 'Sub-Categories'
                                        : _selectedSubCategory!,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedSubCategory != null
                                          ? Colors.white
                                          : Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Business list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _fetchBusinesses();
                        },
                        child: ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          children: [
                            // Results count header
                            // Padding(
                            //   padding: EdgeInsets.only(
                            //       bottom: 16.h, left: 16.w, right: 16.w),
                            //   child: Text(
                            //     '${provider.businessDetails.length} Results for your search',
                            //     style: TextStyle(
                            //       fontSize: 22.sp,
                            //       fontWeight: FontWeight.w600,
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            // ),

                            // Business listing
                            ...List.generate(
                              provider.businessDetails.length,
                              (index) => _buildBusinessCard(
                                  provider.businessDetails[index], index),
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

  // New business card design using BusinessDetail for complete data
  Widget _buildBusinessCard(
      business_detail.BusinessDetail businessDetail, int index) {
    final business = businessDetail.business;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessDetailPage(
            businessId: business.id,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h, left: 16.w, right: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content row (image + text)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Image section
                Container(
                  width: 140.w,
                  height: 140.h,
                  child: Stack(
                    children: [
                      // Business image
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          bottomLeft: Radius.circular(20.r),
                        ),
                        child: business.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl:
                                    '${ApiService.API_URL_FILE}${business.images[0]}',
                                fit: BoxFit.cover,
                                width: 140.w,
                                height: 140.h,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[200]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 140.w,
                                    height: 140.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.r),
                                        bottomLeft: Radius.circular(20.r),
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 140.w,
                                  height: 140.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.shade100,
                                        Colors.blue.shade200,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.r),
                                      bottomLeft: Radius.circular(20.r),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.business,
                                      color: Colors.blue.shade600,
                                      size: 32.sp,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: 140.w,
                                height: 140.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.shade100,
                                      Colors.blue.shade200,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.r),
                                    bottomLeft: Radius.circular(20.r),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.business,
                                    color: Colors.blue.shade600,
                                    size: 32.sp,
                                  ),
                                ),
                              ),
                      ),

                      // Top-right badges
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: Column(
                          children: [
                            // Featured badge
                            if (business.isFeatured)
                              Container(
                                margin: EdgeInsets.only(bottom: 4.h),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade400,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 10.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Featured',
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Verified badge
                            if (business.isVerified)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade500,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 10.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side - Content section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business name
                        Text(
                          business.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 8.h),

                        // Rating row
                        if (businessDetail.averageRating != null &&
                            businessDetail.averageRating! > 0)
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade400,
                                      Colors.green.shade500
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 12.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      businessDetail.averageRating!
                                          .toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "${businessDetail.reviewCount} ${businessDetail.reviewCount == 1 ? 'Review' : 'Reviews'}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                        SizedBox(height: 12.h),

                        // Description
                        Text(
                          business.description.length > 60
                              ? '${business.description.substring(0, 60)}...'
                              : business.description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 12.h),

                        // Location
                        if (business.location.city != null &&
                            business.location.city!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  business.location.city!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Action buttons - Scrollable horizontal list
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Call Now button
                    _buildActionButton(
                      icon: Icons.call,
                      label: 'Call Now',
                      color: Colors.blue.shade600,
                      onTap: () => _callPhone(business.phoneNumber),
                      width: 120.w,
                    ),

                    SizedBox(width: 12.w),

                    // Directions button
                    _buildActionButton(
                      icon: Icons.directions,
                      label: 'Directions',
                      color: Colors.grey.shade700,
                      isOutlined: true,
                      onTap: () => _launchMap(business.location),
                      width: 120.w,
                    ),

                    SizedBox(width: 12.w),

                    // WhatsApp button
                    _buildActionButton(
                      icon: Icons.message,
                      label: 'WhatsApp',
                      color: Colors.green.shade600,
                      onTap: () => _launchWhatsApp(business.phoneNumber),
                      width: 120.w,
                    ),

                    // Website button
                    if (business.website.isNotEmpty) ...[
                      SizedBox(width: 12.w),
                      _buildActionButton(
                        icon: Icons.public,
                        label: 'Website',
                        color: Colors.purple.shade600,
                        onTap: () => _launchWebsite(business.website),
                        width: 120.w,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double width,
    bool isOutlined = false,
  }) {
    return Container(
      width: width > 0 ? width : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: isOutlined ? Colors.transparent : color,
              border: isOutlined ? Border.all(color: color, width: 1.5) : null,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: isOutlined
                  ? null
                  : [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isOutlined ? color : Colors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    color: isOutlined ? color : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                height: 200.h,
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
