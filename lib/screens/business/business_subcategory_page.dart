import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/business_provider.dart';
import 'business_detail_page.dart';
import '../../widgets/app_bar_widget.dart';

class BusinessSubcategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const BusinessSubcategoryPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<BusinessSubcategoryPage> createState() =>
      _BusinessSubcategoryPageState();
}

class _BusinessSubcategoryPageState extends State<BusinessSubcategoryPage> {
  String _sortBy = 'rating'; // Default sort: highest rated
  bool _isGridView = true; // Default view is grid

  @override
  void initState() {
    super.initState();
    // Initialize data if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessProvider>(context, listen: false);
      if (provider.businessServices.isEmpty) {
        provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        title: widget.categoryName,
        showBackButton: true,
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Get businesses for this category
          final businesses = provider.getServicesByCategory(widget.categoryId);

          if (businesses.isEmpty) {
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
                    'No businesses found in this category',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort businesses based on selected option
          _sortBusinesses(businesses);

          return Column(
            children: [
              // Filter and view options
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            icon: const Icon(Icons.sort),
                            isExpanded: true,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortBy = value;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'rating',
                                child: Text('Highest Rated'),
                              ),
                              DropdownMenuItem(
                                value: 'name_asc',
                                child: Text('Name (A-Z)'),
                              ),
                              DropdownMenuItem(
                                value: 'name_desc',
                                child: Text('Name (Z-A)'),
                              ),
                              DropdownMenuItem(
                                value: 'recent',
                                child: Text('Recently Added'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Toggle between grid and list view
                    IconButton(
                      icon: Icon(
                        _isGridView ? Icons.view_list : Icons.grid_view,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Businesses list/grid
              Expanded(
                child: _isGridView
                    ? _buildGridView(businesses)
                    : _buildListView(businesses),
              ),
            ],
          );
        },
      ),
    );
  }

  void _sortBusinesses(List<dynamic> businesses) {
    switch (_sortBy) {
      case 'rating':
        businesses
            .sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
        break;
      case 'name_asc':
        businesses.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        break;
      case 'name_desc':
        businesses.sort((a, b) => (b['name'] ?? '').compareTo(a['name'] ?? ''));
        break;
      case 'recent':
        // Assuming there's a 'createdAt' field in the business data
        // If not, this would need to be implemented differently
        businesses.sort(
            (a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
        break;
    }
  }

  Widget _buildGridView(List<dynamic> businesses) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        final business = businesses[index];
        return _buildBusinessCard(business);
      },
    );
  }

  Widget _buildListView(List<dynamic> businesses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        final business = businesses[index];
        return _buildBusinessListItem(business);
      },
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BusinessDetailPage(businessId: business['id']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                business['imageUrl'] ?? 'https://via.placeholder.com/150',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.business, size: 50),
                  );
                },
              ),
            ),

            // Business details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business['name'] ?? 'Unknown Business',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business['description'] ?? 'No description available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        ' ${business['rating'] ?? '0.0'}',
                        style: const TextStyle(fontSize: 12),
                      ),
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

  Widget _buildBusinessListItem(Map<String, dynamic> business) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Business image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  business['imageUrl'] ?? 'https://via.placeholder.com/60',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.business),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Business details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business['name'] ?? 'Unknown Business',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business['description'] ?? 'No description',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          ' ${business['rating'] ?? '0.0'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.location_on, color: Colors.blue, size: 16),
                        Text(
                          ' ${_shortenAddress(business['address'] ?? 'No address')}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  String _shortenAddress(String address) {
    if (address.length > 20) {
      return '${address.substring(0, 20)}...';
    }
    return address;
  }
}
