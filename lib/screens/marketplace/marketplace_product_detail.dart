import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/models/marketplace_inquiry.dart';
import 'package:home_service_app/models/marketplace_order.dart';
import 'package:home_service_app/provider/marketplace_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketplaceProductDetail extends StatefulWidget {
  final int productId;

  const MarketplaceProductDetail({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<MarketplaceProductDetail> createState() => _MarketplaceProductDetailState();
}

class _MarketplaceProductDetailState extends State<MarketplaceProductDetail> {
  int _currentImageIndex = 0;
  int _selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketplaceProvider>(context, listen: false)
          .getProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, _) {
          final product = provider.selectedProduct;
          final isLoading = provider.isLoadingProducts;
          
          if (isLoading || product == null) {
            return _buildLoadingShimmer();
          }
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImageContainer(product),
                _buildProductDetails(context, product),
                _buildBottomActionBar(context, product),
              ],
            ),
          );
        },
      ),
    );
  }
  
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // Share functionality can be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share functionality to be implemented'))
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                // Favorite functionality can be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to favorites'))
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300.h,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: 200,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 150,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 24,
                        width: 100,
                        color: Colors.white,
                      ),
                      Container(
                        height: 16,
                        width: 80,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Container(
                    height: 18,
                    width: 120,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 18,
                    width: 120,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 60,
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
  
  Widget _buildProductImageContainer(dynamic product) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Image carousel
        product.images.isNotEmpty
            ? CarouselSlider(
                options: CarouselOptions(
                  height: 350.h,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: product.images.length > 1,
                  autoPlayInterval: Duration(seconds: 5),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: product.images.map<Widget>((image) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Hero(
                      tag: 'product-${product.id}-${product.images.indexOf(image)}',
                      child: Image.network(
                        '${ApiService.API_URL_FILE}$image',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, _) => Center(
                          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        ),
                        loadingBuilder: (ctx, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              )
            : Container(
                height: 350.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400]),
                ),
              ),

        // Page indicator
        if (product.images.length > 1)
          Positioned(
            bottom: 16,
            child: AnimatedSmoothIndicator(
              activeIndex: _currentImageIndex,
              count: product.images.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Theme.of(context).primaryColor,
                dotColor: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          
        // Available badge
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: product.stockQuantity > 0 ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              product.stockQuantity > 0 ? 'IN STOCK' : 'OUT OF STOCK',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildProductDetails(BuildContext context, dynamic product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product category and rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product.category,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text(
                    '4.8', // Static rating for demo, could be dynamic
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '(256)', // Static review count for demo, could be dynamic
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Product name
          Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Price and stock info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.currency,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    product.price.toStringAsFixed(2),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      'Stock: ${product.stockQuantity}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Minimum order quantity
          if (product.minOrderQuantity > 0)
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Minimum Order: ${product.minOrderQuantity}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          
          SizedBox(height: 24),
          
          // Quantity selector
          _buildQuantitySelector(product),
          
          SizedBox(height: 24),
          
          // Description
          _buildInfoSection(
            title: 'Description',
            content: product.description,
            icon: Icons.description_outlined,
          ),
          
          SizedBox(height: 24),
          
          // Specifications
          _buildInfoSection(
            title: 'Specifications',
            content: product.specifications,
            icon: Icons.info_outline,
          ),
          
          SizedBox(height: 24),
          
          // Delivery info
          _buildInfoCard(
            icon: Icons.local_shipping_outlined,
            title: 'Delivery',
            content: 'Standard delivery: 3-5 business days',
            iconBgColor: Colors.orange.withOpacity(0.1),
            iconColor: Colors.orange,
          ),
          
          SizedBox(height: 16),
          
          // Return policy
          _buildInfoCard(
            icon: Icons.assignment_return_outlined, 
            title: 'Return Policy',
            content: '30-day money-back guarantee',
            iconBgColor: Colors.green.withOpacity(0.1),
            iconColor: Colors.green,
          ),
          
          SizedBox(height: 16),
          
          // Warranty
          _buildInfoCard(
            icon: Icons.verified_outlined,
            title: 'Warranty',
            content: '1-year manufacturer warranty',
            iconBgColor: Colors.purple.withOpacity(0.1),
            iconColor: Colors.purple,
          ),
          
          SizedBox(height: 30),
        ],
      ),
    );
  }
  
  Widget _buildQuantitySelector(dynamic product) {
    return Row(
      children: [
        Text(
          'Quantity:',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              _buildQuantityButton(
                icon: Icons.remove,
                onPressed: _selectedQuantity > (product.minOrderQuantity > 0 ? product.minOrderQuantity : 1)
                    ? () => setState(() => _selectedQuantity--)
                    : null,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_selectedQuantity',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildQuantityButton(
                icon: Icons.add,
                onPressed: _selectedQuantity < product.stockQuantity
                    ? () => setState(() => _selectedQuantity++)
                    : null,
              ),
            ],
          ),
        ),
        Spacer(),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Total: ',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              TextSpan(
                text: '${product.currency} ${(product.price * _selectedQuantity).toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuantityButton({required IconData icon, required VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: onPressed == null ? Colors.grey : Colors.black87,
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoSection({required String title, required String content, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomActionBar(BuildContext context, dynamic product) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: IconButton(
                icon: Icon(Icons.chat_outlined, color: Colors.blue),
                onPressed: () => _showInquiryDialog(context, product),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: product.stockQuantity > 0 
                    ? () => _showOrderDialog(context, product) 
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Place Order',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showOrderDialog(BuildContext context, dynamic product) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to place an order'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    int quantity = _selectedQuantity;
    final addressController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final totalAmount = product.price * quantity;
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Place Order',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.images.isNotEmpty
                                ? Image.network(
                                    '${ApiService.API_URL_FILE}${product.images[0]}',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                                  ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${product.currency} ${product.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quantity:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, size: 20),
                                    onPressed: quantity > product.minOrderQuantity
                                        ? () => setState(() => quantity--)
                                        : null,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    color: quantity > product.minOrderQuantity
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    margin: EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      quantity.toString(),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, size: 20),
                                    onPressed: quantity < product.stockQuantity
                                        ? () => setState(() => quantity++)
                                        : null,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    color: quantity < product.stockQuantity
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${product.currency} ${(product.price * quantity).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Shipping:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Free',
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${product.currency} ${totalAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    Text(
                      'Shipping Address',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: 'Enter your shipping address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                      style: GoogleFonts.poppins(),
                    ),
                    
                    SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (addressController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter shipping address'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          
                          final order = MarketplaceOrder(
                            buyerId: user.id,
                            sellerId: product.businessId,
                            productId: product.id,
                            quantity: quantity,
                            totalAmount: totalAmount,
                            status: 'PENDING',
                            shippingDetails: addressController.text,
                            orderDate: DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
                          );
                          
                          final success = await Provider.of<MarketplaceProvider>(context, listen: false)
                              .submitOrder(order);
                          
                          // Close loading dialog
                          Navigator.pop(context);
                          
                          if (success) {
                            Navigator.pop(context);
                            
                            // Show success dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green,
                                        size: 60,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      'Order Placed Successfully!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Your order has been placed successfully and is being processed.',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Confirm Order',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
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
  
  void _showInquiryDialog(BuildContext context, dynamic product) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to send an inquiry'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    final subjectController = TextEditingController(text: 'Inquiry about ${product.name}');
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Send Inquiry',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.images.isNotEmpty
                            ? Image.network(
                                '${ApiService.API_URL_FILE}${product.images[0]}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                              ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${product.currency} ${product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                Text(
                  'Subject',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: GoogleFonts.poppins(),
                ),
                
                SizedBox(height: 16),
                
                Text(
                  'Message',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Enter your message here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 5,
                  style: GoogleFonts.poppins(),
                ),
                
                SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (messageController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a message'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                      
                      final inquiry = MarketplaceInquiry(
                        subject: subjectController.text,
                        message: messageController.text,
                        senderId: user.id,
                        recipientId: product.businessId,
                        productId: product.id,
                        status: 'PENDING',
                      );
                      
                      final success = await Provider.of<MarketplaceProvider>(context, listen: false)
                          .submitInquiry(inquiry);
                      
                      // Close loading dialog
                      Navigator.pop(context);
                      
                      if (success) {
                        Navigator.pop(context);
                        
                        // Show success dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.mark_email_read,
                                    color: Colors.blue,
                                    size: 60,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Inquiry Sent!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Your inquiry has been sent successfully. The seller will respond to you soon.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Send Inquiry',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 