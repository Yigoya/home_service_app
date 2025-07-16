// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../provider/business_provider.dart';
// import '../../widgets/app_bar_widget.dart';
// import 'business_detail_page.dart';

// class BusinessSearchPage extends StatefulWidget {
//   const BusinessSearchPage({Key? key}) : super(key: key);

//   @override
//   State<BusinessSearchPage> createState() => _BusinessSearchPageState();
// }

// class _BusinessSearchPageState extends State<BusinessSearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Make sure we have data loaded
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<BusinessProvider>(context, listen: false);
//       if (provider.businessServices.isEmpty) {
//         setState(() {
//           _isLoading = true;
//         });
//         provider.initialize().then((_) {
//           setState(() {
//             _isLoading = false;
//           });
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppbarWidget(
//         title: 'Search Businesses',
//         showBackButton: true,
//       ),
//       body: Column(
//         children: [
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search by name or description...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           setState(() {
//                             _searchController.clear();
//                             _searchQuery = '';
//                           });
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//             ),
//           ),

//           // Results
//           if (_isLoading)
//             const Expanded(
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             )
//           else
//             Consumer<BusinessProvider>(
//               builder: (context, provider, child) {
//                 // Show all businesses if no search query
//                 final searchResults = _searchQuery.isEmpty
//                     ? provider.businessServices
//                     : provider.searchBusinesses(_searchQuery);

//                 // if (searchResults.isEmpty) {
//                 //   return Expanded(
//                 //     child: Center(
//                 //       child: Column(
//                 //         mainAxisAlignment: MainAxisAlignment.center,
//                 //         children: [
//                 //           Icon(
//                 //             Icons.search_off,
//                 //             size: 64,
//                 //             color: Colors.grey[400],
//                 //           ),
//                 //           const SizedBox(height: 16),
//                 //           Text(
//                 //             _searchQuery.isEmpty
//                 //                 ? 'No businesses available'
//                 //                 : 'No results found for "$_searchQuery"',
//                 //             style: TextStyle(
//                 //               fontSize: 18,
//                 //               color: Colors.grey[600],
//                 //             ),
//                 //             textAlign: TextAlign.center,
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //   );
//                 // }

//                 // return Expanded(
//                 //   child: ListView.builder(
//                 //     padding: const EdgeInsets.all(16),
//                 //     itemCount: searchResults.length,
//                 //     itemBuilder: (context, index) {
//                 //       final business = searchResults[index];
//                 //       return _buildBusinessListItem(business);
//                 //     },
//                 //   ),
//                 // );
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBusinessListItem(Map<String, dynamic> business) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       elevation: 2,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => BusinessDetailPage(business: business),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               // Business image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   business['imageUrl'] ?? 'https://via.placeholder.com/60',
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       width: 80,
//                       height: 80,
//                       color: Colors.grey[300],
//                       child: const Icon(Icons.business),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(width: 16),

//               // Business details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       business['name'] ?? 'Unknown Business',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       business['description'] ?? 'No description',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                         Text(
//                           ' ${business['rating'] ?? '0.0'}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         // Show category
//                         if (business['categoryId'] != null)
//                           Consumer<BusinessProvider>(
//                             builder: (context, provider, child) {
//                               final category = provider
//                                   .getCategoryById(business['categoryId']);
//                               if (category != null) {
//                                 return Row(
//                                   children: [
//                                     Icon(
//                                       _getIconData(
//                                           category['icon'] ?? 'category'),
//                                       color: _getColorFromHex(
//                                           category['color'] ?? '#2196F3'),
//                                       size: 16,
//                                     ),
//                                     Text(
//                                       ' ${category['name']}',
//                                       style: TextStyle(
//                                         color: Colors.grey[700],
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               }
//                               return const SizedBox.shrink();
//                             },
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Arrow icon
//               const Icon(Icons.arrow_forward_ios, size: 14),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper method to convert hex color string to Color
//   Color _getColorFromHex(String hexColor) {
//     hexColor = hexColor.replaceAll('#', '');
//     if (hexColor.length == 6) {
//       hexColor = 'FF' + hexColor;
//     }
//     return Color(int.parse(hexColor, radix: 16));
//   }

//   // Helper method to get IconData from string
//   IconData _getIconData(String iconName) {
//     switch (iconName) {
//       case 'home_repair_service':
//         return Icons.home_repair_service;
//       case 'cleaning_services':
//         return Icons.cleaning_services;
//       case 'electrical_services':
//         return Icons.electrical_services;
//       case 'plumbing':
//         return Icons.plumbing;
//       case 'grass':
//         return Icons.grass;
//       case 'format_paint':
//         return Icons.format_paint;
//       default:
//         return Icons.category;
//     }
//   }
// }
