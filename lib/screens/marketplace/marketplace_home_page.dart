import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/models/marketplace_product.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/marketplace_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/marketplace/marketplace_product_detail.dart';
import 'package:home_service_app/screens/marketplace/marketplace_search_page.dart';
import 'package:home_service_app/screens/marketplace/marketplace_product_list.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({Key? key}) : super(key: key);

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Service> _marketplaceServices = [];
  Service? _selectedService;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarketplaceServices();
    });
  }

  Future<void> _loadMarketplaceServices() async {
    setState(() {
      _isLoadingCategories = true;
    });

    // Get the marketplace category services from HomeServiceProvider
    final homeServiceProvider =
        Provider.of<HomeServiceProvider>(context, listen: false);

    // Find the B2B marketplace category - typically the last category
    // Note: This depends on your actual data structure
    final marketplaceCategory = homeServiceProvider.categories[2];
    // .lastWhere(
    //     (category) =>
    //         category.categoryName.toLowerCase().contains('marketplace') ||
    //         category.categoryName.toLowerCase().contains('b2b'),
    //     orElse: () => homeServiceProvider.categories.last);

    // Get the services from the marketplace category
    _marketplaceServices = marketplaceCategory.services;

    // If there are services, select the first one by default
    if (_marketplaceServices.isNotEmpty) {
      _selectedService = _marketplaceServices.first;

      // Load products for the selected service
      if (_selectedService != null) {
        await _loadProductsForService(_selectedService!);
      }
    }

    setState(() {
      _isLoadingCategories = false;
    });
  }

  Future<void> _loadProductsForService(Service service) async {
    if (service.services.isNotEmpty) {
      // If the service has sub-services, get products for the first sub-service
      await Provider.of<MarketplaceProvider>(context, listen: false)
          .fetchProductsByServiceId(service.services.first.id);
    } else {
      // Otherwise, get products for this service
      await Provider.of<MarketplaceProvider>(context, listen: false)
          .fetchProductsByServiceId(service.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context);
    final products = marketplaceProvider.products;
    final isLoading =
        marketplaceProvider.isLoadingProducts || _isLoadingCategories;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadMarketplaceServices();
          },
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              _buildSearchBar(context),
              _buildCategoryGrid(context),
              _buildFeaturedProductsHeader(context),
              isLoading
                  ? _buildLoadingProductGrid()
                  : products.isEmpty
                      ? _buildEmptyProductList()
                      : _buildProductGrid(products),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      floating: true,
      pinned: false,
      centerTitle: true,
      leading: Container(
        margin: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            // Navigate to profile
          },
          icon: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
            size: 22.sp,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      elevation: 0,
      title: Text(
        'Marketplace',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: 26.sp),
          onPressed: () {
            // Navigate to notifications
          },
        ),
        IconButton(
          icon: Icon(Icons.home_outlined, size: 26.sp),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Navigation()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MarketplaceSearchPage(),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600], size: 22.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Spas & Salons',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Icon(Icons.mic, color: Colors.blue, size: 22.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    if (_isLoadingCategories) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 420.h,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 20.h,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 55.w,
                      height: 11.h,
                      color: Colors.white,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    // Define colors for category icons
    final List<Color> categoryColors = [
      const Color(0xFF5F84A2),
      const Color(0xFF39B0A8),
      const Color(0xFF4E73B9),
      const Color(0xFFF2B132),
      const Color(0xFF7D6E96),
      const Color(0xFF4E73B9),
      const Color(0xFF39B0A8),
      const Color(0xFF5F84A2),
      const Color(0xFFF2B132),
      const Color(0xFF7D6E96),
      const Color(0xFF4E73B9),
      const Color(0xFF39B0A8),
      const Color(0xFF5F84A2),
      const Color(0xFFF2B132),
      const Color(0xFF7D6E96),
      const Color(0xFF4E73B9),
    ];

    // Limit to display only up to 15 services in the grid (for 15 + "See More" button)
    final displayedServices = _marketplaceServices.length > 15
        ? _marketplaceServices.sublist(0, 15)
        : _marketplaceServices;

    // Total items including the "See More" button (unless we have 16 or fewer services total)
    final totalItems =
        _marketplaceServices.length > 15 ? 16 : displayedServices.length;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 560.h,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.75,
            crossAxisSpacing: 6.w,
            mainAxisSpacing: 20.h,
          ),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            // If this is the last item and we have more than 15 services, show "See More"
            if (index == 15 && _marketplaceServices.length > 15) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _buildAllCategoriesScreen(),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        // color: categoryColors[index],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        // color: Colors.white,
                        size: 42.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'See More',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            } else {
              // Show a service category item
              final service = displayedServices[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedService = service;
                  });

                  // If this service has sub-services, navigate to a list view
                  if (service.services.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _buildNestedServiceView(service),
                      ),
                    );
                  } else {
                    // Otherwise, navigate to product list
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketplaceProductList(
                          serviceId: service.id,
                          category: service.name,
                        ),
                      ),
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        // color: categoryColors[index % categoryColors.length],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: service.icon == null
                            ? Icon(
                                _getServiceIcon(service.name),
                                size: 24.sp,
                                // color: Colors.white,
                              )
                            : Image.network(
                                '${ApiService.API_URL_FILE}${service.icon}',
                                width: 34.w,
                                height: 34.h,
                                fit: BoxFit.cover,
                                // color: Colors.white,
                              ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      service.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('machinery') || name.contains('machine')) {
      return Icons.agriculture;
    } else if (name.contains('seed') || name.contains('plant')) {
      return Icons.spa;
    } else if (name.contains('tool') || name.contains('equipment')) {
      return Icons.handyman;
    } else if (name.contains('fertilizer') || name.contains('chemical')) {
      return Icons.eco;
    } else if (name.contains('irrigation') || name.contains('water')) {
      return Icons.water_drop;
    } else if (name.contains('storage') || name.contains('container')) {
      return Icons.inventory_2;
    } else {
      return Icons.category;
    }
  }

  // Full screen to show all categories
  Widget _buildAllCategoriesScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('All Categories'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 20.h,
        ),
        itemCount: _marketplaceServices.length,
        itemBuilder: (context, index) {
          final service = _marketplaceServices[index];
          final List<Color> categoryColors = [
            const Color(0xFF5F84A2),
            const Color(0xFF39B0A8),
            const Color(0xFF4E73B9),
            const Color(0xFFF2B132),
            const Color(0xFF7D6E96),
          ];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedService = service;
              });

              // If this service has sub-services, navigate to a list view
              if (service.services.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _buildNestedServiceView(service),
                  ),
                );
              } else {
                // Otherwise, navigate to product list
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarketplaceProductList(
                      serviceId: service.id,
                      category: service.name,
                    ),
                  ),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    // color: categoryColors[index % categoryColors.length],
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: service.icon == null
                        ? Icon(
                            _getServiceIcon(service.name),
                            size: 24.sp,
                            // color: Colors.white,
                          )
                        : Image.network(
                            '${ApiService.API_URL_FILE}${service.icon}',
                            width: 24.w,
                            height: 24.h,
                            fit: BoxFit.cover,
                            // color: Colors.white,
                          ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  service.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProductsHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Text(
              'Featured Products',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingProductGrid() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildLoadingProductCard(),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildLoadingProductCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 80.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 100.w,
                    height: 20.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProductList() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<MarketplaceProduct> products) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProductCard(products[index]),
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(MarketplaceProduct product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MarketplaceProductDetail(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
                image: DecorationImage(
                  image: product.images.isNotEmpty
                      ? NetworkImage(
                          '${ApiService.API_URL_FILE}${product.images[0]}')
                      : const AssetImage('assets/images/placeholder.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '${product.currency} ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      if (product.minOrderQuantity > 0) ...[
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'MOQ: ${product.minOrderQuantity}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display nested services
  Widget _buildNestedServiceView(Service parentService) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(parentService.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: parentService.services.length,
        itemBuilder: (context, index) {
          final service = parentService.services[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (service.services.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _buildNestedServiceView(service),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketplaceProductList(
                          serviceId: service.id,
                          category: service.name,
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: service.icon == null
                              ? Icon(
                                  _getServiceIcon(service.name),
                                  size: 24.sp,
                                  color: Theme.of(context).primaryColor,
                                )
                              : Image.network(
                                  '${ApiService.API_URL_FILE}${service.icon}',
                                  width: 24.w,
                                  height: 24.h,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (service.description != null &&
                                service.description!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  service.description!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
