import 'package:flutter/material.dart';
import 'package:home_service_app/models/rating.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/booking/buy_coins_page.dart';
import 'package:home_service_app/screens/home/questionnaire_page.dart';
import 'package:home_service_app/screens/home/category_services.dart';
import 'package:home_service_app/screens/home/select_location.dart';
import 'package:home_service_app/screens/home/sidebar_drawer.dart';
import 'package:home_service_app/screens/home/widgets.dart';
import 'package:home_service_app/screens/profile/customer_profile_page.dart';
import 'package:home_service_app/screens/profile/technician_detail_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/language_selector.dart';
import 'package:home_service_app/widgets/slide_show.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFocused = false;
  bool _showAllCategories = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isFocused) {
      setState(() {
        _isFocused = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeServiceProvider>(context);
    Logger().d(Localizations.localeOf(context));
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const SideNavDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<UserProvider>(context, listen: false).loadUser();
            await provider.loadHome(Localizations.localeOf(context));
          },
          child: ListView(
            children: [
              _buildBannerSection(provider),
              _buildServiceCategories(provider),
              _buildTechnicianListView(),
              _buildCustomerReviewsSection(),
              const FAQSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianListView() {
    final technicians =
        Provider.of<HomeServiceProvider>(context).topTechnicians;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Divider(
            color: Colors.grey[400],
            thickness: 1.w,
          ),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.ourBestTechnicians,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...technicians.map((tech) => _buildTechnicianCard(tech)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerReviewsSection() {
    final reviews = Provider.of<HomeServiceProvider>(context).reviews;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Divider(
            color: Colors.grey[400],
            thickness: 1.w,
          ),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(AppLocalizations.of(context)!.whatTheCustomerSays,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...reviews.map((review) => _buildReviewCard(review)),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Divider(
            color: Colors.grey[400],
            thickness: 1.w,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildBannerSection(HomeServiceProvider provider) {
    final location = Provider.of<HomeServiceProvider>(context).location;
    Logger().d(Localizations.localeOf(context));
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      color: Colors.green, size: 24.sp),
                  SizedBox(width: 5.w),
                  Text("current location",
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.w500)),
                  SizedBox(width: 5.w),
                  Text(
                      '${location['subcity'] ?? ''}, ${location['city'] ?? ''}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
              SizedBox(height: 16.h),
              _buildSearchBar(provider),
              SizedBox(height: 8.h),
              SlideshowComponent(slides: [
                {
                  'image': 'assets/images/banner2.jpg',
                  'title': 'Professional Home Services'
                },
                {
                  'image': 'assets/images/banner3.jpg',
                  'title': 'Reliable and Trusted Technicians'
                },
                {
                  'image': 'assets/images/banner4.jpg',
                  'title': 'Quality Service at Your Doorstep'
                },
              ]),
              SizedBox(height: _isFocused ? 92.h : 16.h),
            ],
          ),
        ),
        if (_isFocused)
          Builder(
            builder: (context) {
              return Positioned(
                top: 110.h,
                height: 300.h,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  height: 300.h,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: const Color.fromARGB(255, 3, 90, 29),
                        width: 1.w),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[400]!,
                          offset: Offset(0, 2.h),
                          blurRadius: 8.r)
                    ],
                  ),
                  child: provider.fiterableBySearch.isNotEmpty
                      ? ListView.builder(
                          itemCount: provider.fiterableBySearch.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                // Provider.of<HomeServiceProvider>(context,
                                //         listen: false)
                                //     .fetchServiceQuestions(
                                //         provider.services[index].id);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SelectLocation(
                                            service: provider
                                                .fiterableBySearch[index])));
                              },
                              title: Text(
                                provider.fiterableBySearch[index].name,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "Service Not Found",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 23.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSearchBar(HomeServiceProvider provider) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36.r),
            border: _isFocused
                ? Border.all(
                    color: const Color.fromARGB(255, 0, 88, 22), width: 2.w)
                : Border.all(
                    color: const Color.fromARGB(255, 3, 90, 29), width: 1.w),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    provider.filterServicesBySearch(search: value);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                    alignLabelWithHint: true,
                    hintText: AppLocalizations.of(context)!.searchForServices,
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 18.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 88, 22),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(36),
                      bottomRight: Radius.circular(36)),
                ),
                child: IconButton(
                  onPressed: () {
                    provider.filterServicesBySearch(search: '');
                  },
                  icon: Icon(Icons.search, color: Colors.grey[200]),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 4.h,
        ),
      ],
    );
  }

  Widget _buildServiceCategories(HomeServiceProvider provider) {
    return Column(
      children: [
        SizedBox(
          height: (138 *
                  (provider.categories.length > 6 && !_showAllCategories
                          ? 6
                          : provider.categories.length)
                      .h) +
              80.h,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.categories.length > 6 && !_showAllCategories
                ? 7
                : provider.categories.length + 1,
            itemBuilder: (context, index) {
              if (index ==
                  (provider.categories.length > 6 && !_showAllCategories
                      ? 6
                      : provider.categories.length)) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAllCategories = !_showAllCategories;
                    });
                  },
                  child: Container(
                    height: 40.h,
                    margin:
                        EdgeInsets.only(right: 16.w, left: 16.w, bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[200]!, width: 1.w),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[400]!,
                            offset: Offset(0, 2.h),
                            blurRadius: 4.r)
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _showAllCategories ? 'See Less' : 'See More',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 88, 22),
                          fontWeight: FontWeight.w400,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }
              final category = provider.categories[index];
              return GestureDetector(
                onTap: () {
                  provider.filterServicesByCategory(category.id);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CategoryServices()));
                },
                child: Container(
                  height: 120.h,
                  margin: EdgeInsets.only(right: 16.w, left: 16.w, bottom: 8.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                        color: provider.selectedCategoryId == category.id
                            ? const Color.fromARGB(255, 0, 88, 22)
                            : Colors.grey[200]!,
                        width: 1.w),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[400]!,
                          offset: Offset(0, 2.h),
                          blurRadius: 2.r)
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            [
                              Icons.home_repair_service,
                              Icons.cleaning_services,
                              Icons.electrical_services,
                              Icons.plumbing,
                              Icons.construction,
                              Icons.door_back_door_outlined
                            ].elementAt(index % 6),
                            size: 32.sp,
                            color: const Color.fromARGB(255, 0, 88, 22),
                          ),
                          SizedBox(width: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category.categoryName,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22.sp)),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width - 130.w,
                                child: Text(
                                  category.description ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      color: Colors.grey[600],
                                      height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.grey[600], size: 22.sp),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // provider.fiterableBySearch
        //                     .where((service) =>
        //                         service.categoryId ==
        //                         provider.categories[index].id)
        //                     .isNotEmpty
        //                 ? Column(
        //                     children: [
        //                       Padding(
        //                         padding: const EdgeInsets.symmetric(
        //                             horizontal: 32.0),
        //                         child: Divider(
        //                           thickness: 1.5.w,
        //                           color: Colors.black.withOpacity(0.1),
        //                         ),
        //                       ),
        //                       SizedBox(
        //                         height: 50.h,
        //                         child: ListView(
        //                             scrollDirection: Axis.horizontal,
        //                             children: [
        //                               SizedBox(
        //                                 width: 16.w,
        //                               ),
        //                               ...provider.fiterableBySearch
        //                                   .where((service) =>
        //                                       service.categoryId ==
        //                                       provider.categories[index].id)
        //                                   .map((service) => Row(
        //                                         children: [
        //                                           GestureDetector(
        //                                             onTap: () {
        //                                               Provider.of<HomeServiceProvider>(
        //                                                       context,
        //                                                       listen: false)
        //                                                   .fetchServiceQuestions(
        //                                                       provider
        //                                                           .fiterableBySearch[
        //                                                               index]
        //                                                           .id);
        //                                               Navigator.push(
        //                                                   context,
        //                                                   MaterialPageRoute(
        //                                                       builder: (context) =>
        //                                                           QuestionnairePage(
        //                                                               service: provider
        //                                                                       .fiterableBySearch[
        //                                                                   index])));
        //                                             },
        //                                             child: Container(
        //                                               margin: EdgeInsets.only(
        //                                                 left: 8.w,
        //                                               ),
        //                                               padding:
        //                                                   EdgeInsets.symmetric(
        //                                                       horizontal: 32.w,
        //                                                       vertical: 8.h),
        //                                               decoration: BoxDecoration(
        //                                                 color: Colors.white,
        //                                                 borderRadius:
        //                                                     BorderRadius
        //                                                         .circular(32.r),
        //                                                 border: Border.all(
        //                                                     color: Colors.blue),
        //                                               ),
        //                                               child: Text(
        //                                                 service.name,
        //                                                 style: TextStyle(
        //                                                   fontSize: 14.sp,
        //                                                   color: Colors.black,
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                           ),
        //                                         ],
        //                                       ))
        //                                   .toList(),
        //                             ]),
        //                       ),
        //                     ],
        //                   )
        //                 : SizedBox.shrink()
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 16.w),
        //   child: Row(
        //     children: [
        //       Text(
        //         "Services ",
        //         style: TextStyle(
        //           fontSize: 22.sp,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // Container(
        //   margin: EdgeInsets.all(16.w),
        //   padding: EdgeInsets.all(4.w),
        //   height: 50.h,
        //   decoration: BoxDecoration(
        //     color: Colors.grey[300],
        //     borderRadius: BorderRadius.circular(25.r),
        //   ),
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(25.r),
        //     child: ListView(
        //       scrollDirection: Axis.horizontal,
        //       children: provider.categories.map((category) {
        //         return GestureDetector(
        //             onTap: () {
        //               provider.filterServicesByCategory(category.id);
        //             },
        //             child: Container(
        //               margin: EdgeInsets.only(right: 8.w),
        //               padding: EdgeInsets.symmetric(horizontal: 16.w),
        //               decoration: BoxDecoration(
        //                 color: provider.selectedCategory == category.id
        //                     ? Colors.white
        //                     : null,
        //                 borderRadius: BorderRadius.circular(25.r),
        //               ),
        //               child: Center(
        //                   child: Text(category.categoryName,
        //                       style: TextStyle(
        //                           color: provider.selectedCategory ==
        //                                   category.id
        //                               ? Colors.black
        //                               : const Color.fromARGB(255, 55, 84, 122),
        //                           fontWeight: FontWeight.w600,
        //                           fontSize: 16.sp))),
        //             ));
        //       }).toList(),
        //     ),
        // ),
        // ),
      ],
    );
  }

  Widget _buildservices(HomeServiceProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0.w),
      child: Wrap(
        spacing: 5.w,
        runSpacing: 6.h,
        children: provider.fiterableByCatagory
            .map((service) => _buildServiceCard(service))
            .toList(),
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return GestureDetector(
      onTap: () {
        Provider.of<HomeServiceProvider>(context, listen: false)
            .fetchServiceQuestions(service.id);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuestionnairePage(service: service)));
      },
      child: Container(
        width: 180.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        margin: EdgeInsets.only(left: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            service.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianCard(Technician tech) {
    return Container(
      width: 324.w,
      margin: EdgeInsets.only(left: 16.w, top: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.grey[300]!, width: 2.w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  '${ApiService.API_URL_FILE}${tech.profileImage}',
                  fit: BoxFit.cover,
                  width: 72.w,
                  height: 72.h,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/profile.png',
                      width: 72.w,
                      height: 72.h,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tech.name,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    width: 206.w,
                    child: Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        children: tech.services.asMap().entries.map((entry) {
                          int index = entry.key;
                          var service = entry.value;
                          if (index > 3) {
                            return SizedBox.shrink();
                          } else if (index == 3) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '...',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                              ),
                            );
                          }
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              service.name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp),
                            ),
                          );
                        }).toList()),
                  )
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            tech.bio,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Spacer(),
          Row(
            children: [
              if (tech.subcity != null || tech.city != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.location,
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.grey, size: 16.sp),
                        SizedBox(width: 5.w),
                        Text(
                          '${tech.subcity ?? ''}, ${tech.city ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              SizedBox(width: 20.w),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.rating,
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.star,
                          color: Color.fromARGB(255, 235, 173, 5), size: 16.sp),
                      SizedBox(width: 5.w),
                      Text(
                        '${tech.rating ?? 0}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TechncianDetailPage(
                            technicianId: tech.id,
                          )));
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(AppLocalizations.of(context)!.viewProfile,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: EdgeInsets.only(left: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey[300]!, width: 2.w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              review.rating,
              (index) => Icon(Icons.star, color: Colors.yellow, size: 16.sp),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            review.review,
            style: TextStyle(fontSize: 14.sp, height: 1.5.h),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Spacer(),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  '${ApiService.API_URL_FILE}${review.customer.profileImage}',
                  fit: BoxFit.cover,
                  width: 72.w,
                  height: 72.h,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/profile.png',
                      width: 72.w,
                      height: 72.h,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              SizedBox(width: 4.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.customer.name,
                      style: TextStyle(
                          fontSize: 22.sp, fontWeight: FontWeight.bold)),
                  Text(review.customer.email,
                      style:
                          TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
