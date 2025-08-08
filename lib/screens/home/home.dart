import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:flutter/material.dart';
import 'package:home_service_app/models/catagory.dart';
import 'package:home_service_app/models/rating.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/models/tender.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/business/business_home_page.dart';
import 'package:home_service_app/screens/business/business_list_page.dart';
import 'package:home_service_app/screens/business/service_details_page.dart';
import 'package:home_service_app/screens/home/questionnaire_page.dart';
import 'package:home_service_app/screens/home/category_services.dart';
import 'package:home_service_app/screens/home/select_location.dart';
import 'package:home_service_app/screens/home/tender_categorys.dart';
import 'package:home_service_app/screens/job/job_search_screen.dart';
import 'package:home_service_app/screens/job/main_screen.dart';
import 'package:home_service_app/screens/job/onboarding_screen.dart';
import 'package:home_service_app/screens/marketplace/marketplace_home_page.dart';
import 'package:home_service_app/screens/profile/technician_detail_page.dart';
import 'package:home_service_app/screens/tender/component/tender_card.dart';
import 'package:home_service_app/screens/tender/tender_list_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/widgets/catagory_skeleton.dart';
import 'package:home_service_app/widgets/slide_show.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:home_service_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
// import 'package:chapasdk/chapasdk.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  final bool _showAllCategories = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   FocusScope.of(context).unfocus();
  // }

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;
    Logger().d(bottomInset);

    if (bottomInset > 0.0 && !_isFocused) {
      setState(() {
        _isFocused = true;
      });
    } else if (bottomInset == 0.0 && _isFocused) {
      setState(() {
        _isFocused = false;
      });
    }
  }

  Future<void> pay() async {
    // Generate a random transaction reference with a custom prefix
    String txRef = TxRefRandomGenerator.generate(prefix: 'Pharmabet');

    // Access the generated transaction reference
    String storedTxRef = TxRefRandomGenerator.gettxRef;

    // Print the generated transaction reference and the stored transaction reference
    print('Generated TxRef: $txRef');
    print('Stored TxRef: $storedTxRef');
    await Chapa.getInstance.startPayment(
      context: context,
      onInAppPaymentSuccess: (successMsg) {
        // Handle success events
      },
      onInAppPaymentError: (errorMsg) {
        // Handle error
      },
      amount: '1000',
      currency: 'ETB',
      txRef: storedTxRef,
    );
  }

  void onClick() {
    final txRef = DateTime.now().millisecondsSinceEpoch.toString();
    // Chapa.paymentParameters(
    //   context: context,
    //   publicKey: 'CHAPUBK_TEST-pAf1YBsAF17F5i06Wb9gYAfc4vodbeFs',
    //   currency: 'ETB',
    //   amount: '1',
    //   email: 'fetanchapa.co',
    //   phone: '0911223344',
    //   firstName: 'Israel',
    //   lastName: 'Goytom',
    //   txRef: txRef,
    //   title: 'Order Payment',
    //   desc: 'Payment for order #12345',
    //   nativeCheckout: true,
    //   namedRouteFallBack: '/',
    //   // showPaymentMethodsOnGridView: true,
    //   availablePaymentMethods: ['mpesa', 'cbebirr', 'telebirr', 'ebirr'],
    // );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeServiceProvider>(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(255, 77, 107, 254),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Provider.of<UserProvider>(context, listen: false)
                  .loadUser();
              await provider.loadHome(Localizations.localeOf(context));
            },
            child: ListView(
              children: [
                _buildBannerSection(provider),
                _buildServiceCategories(provider),
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) =>
                //             const JobSearchScreen(onboardingData: null),
                //       ),
                //     );
                //   },
                //   child: Container(
                //     height: 100,
                //     // width: 200,
                //     color: Colors.red,
                //     child: Text(
                //       'WTF',
                //       style: TextStyle(
                //         fontSize: 22.sp,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
                _buildTechnicianListView(),
                // _buildCustomerReviewsSection(),
                // const FAQSection(),
              ],
            ),
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
        technicians.isNotEmpty
            ? SizedBox(
                height: 310.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...technicians.map((tech) => _buildTechnicianCard(tech)),
                  ],
                ),
              )
            : Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  AppLocalizations.of(context)!.noTechniciansFound,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                  ),
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
        reviews.isNotEmpty
            ? SizedBox(
                height: 200.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...reviews.map((review) => _buildReviewCard(review)),
                  ],
                ),
              )
            : Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  AppLocalizations.of(context)!.noReviewsYet,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                  ),
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
    final location = Provider.of<HomeServiceProvider>(context).selectedLocation;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            // Use a white background to match the new design while keeping brand color accents
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.all(16.w).copyWith(top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status bar area
              // SizedBox(
              //   height: MediaQuery.of(context).padding.top,
              //   child: Container(
              //     color: const Color.fromARGB(255, 77, 107, 254),
              //   ),
              // ),
              // Header with hamburger menu, location, and profile
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    icon: Icon(
                      Icons.menu,
                      color: const Color.fromARGB(255, 77, 107, 254),
                      size: 29.sp,
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.location_on_rounded,
                  //       color: Colors.white,
                  //       size: 20.sp,
                  //     ),
                  //     SizedBox(width: 4.w),
                  //     Text(
                  //       '${Provider.of<HomeServiceProvider>(context, listen: false).subCityNameInLanguage(location, Localizations.localeOf(context))}, ${AppLocalizations.of(context)!.addisAbaba}',
                  //       style: TextStyle(
                  //         fontSize: 14.sp,
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //     Icon(
                  //       Icons.keyboard_arrow_down,
                  //       color: Colors.white,
                  //       size: 20.sp,
                  //     ),
                  //   ],
                  // ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color.fromARGB(255, 77, 107, 254),
                          width: 2.w),
                    ),
                    child: CircleAvatar(
                      radius: 18.r,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: const Color.fromARGB(255, 77, 107, 254),
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),*/
              SizedBox(height: 16.h),
              // Search bar
              _buildSearchBar(provider),
              SizedBox(height: 16.h),
              // Hero banner slideshow under the search bar
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SlideshowComponent(
                  slides: const [
                    {
                      'image': 'assets/images/banner.jpg',
                      'title': 'All in one at huluMoya',
                    },
                    {
                      'image': 'assets/images/banner2.jpg',
                      'title': 'All in one at huluMoya',
                    },
                    {
                      'image': 'assets/images/banner3.jpg',
                      'title': 'All in one at huluMoya',
                    },
                    {
                      'image': 'assets/images/banner4.jpg',
                      'title': 'All in one at huluMoya',
                    },
                  ],
                ),
              ),
              SizedBox(height: _isFocused ? 120.h : 16.h),
            ],
          ),
        ),
        if (_isFocused)
          Builder(
            builder: (context) {
              return Positioned(
                top: 90.h,
                height: 300.h,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  height: 300.h,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: const Color.fromARGB(255, 77, 107, 254),
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
                                _focusNode.unfocus();
                                if (provider
                                        .fiterableBySearch[index].categoryId ==
                                    1) {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(MaterialPageRoute(
                                          builder: (context) => TenderListPage(
                                                service: provider
                                                    .fiterableBySearch[index],
                                              )));
                                  return;
                                }
                                if (provider
                                        .fiterableBySearch[index].categoryId ==
                                    2) {
                                  if (provider.fiterableBySearch[index].services
                                      .isNotEmpty) {
                                    // Navigate to ServiceDetailsPage to show child services
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ServiceDetailsPage(
                                          service:
                                              provider.fiterableBySearch[index],
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Navigate to BusinessListPage to show businesses for this service
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BusinessListPage(
                                          service:
                                              provider.fiterableBySearch[index],
                                          categoryId: provider
                                              .fiterableBySearch[index].id,
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }
                                if (provider
                                        .fiterableBySearch[index].categoryId ==
                                    3) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SelectLocation(
                                              service: provider
                                                  .fiterableBySearch[index])));
                                  return;
                                }
                                if (provider
                                        .fiterableBySearch[index].categoryId ==
                                    4) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SelectLocation(
                                              service: provider
                                                  .fiterableBySearch[index])));
                                  return;
                                }
                              },
                              leading:
                                  provider.fiterableBySearch[index].icon == null
                                      ? Icon(
                                          [
                                            Icons.home_repair_service,
                                            Icons.cleaning_services,
                                            Icons.electrical_services,
                                            Icons.plumbing,
                                            Icons.construction,
                                            Icons.door_back_door_outlined
                                          ].elementAt(index % 6),
                                          size: 30.sp,
                                          color: const Color.fromARGB(
                                              255, 77, 107, 254),
                                        )
                                      : Image.network(
                                          '${ApiService.API_URL_FILE}${provider.fiterableBySearch[index].icon}',
                                          width: 30.w,
                                          height: 30.h,
                                          fit: BoxFit.cover,
                                          color: const Color.fromARGB(
                                              255, 77, 107, 254),
                                        ),
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
                            AppLocalizations.of(context)!.serviceNotFound,
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
                    color: const Color.fromARGB(255, 77, 107, 254), width: 3.w)
                : Border.all(
                    color: const Color.fromARGB(255, 77, 107, 254), width: 2.w),
          ),
          height: 56.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
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
                height: double.infinity,
                width: 64.w,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 57, 77, 254),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(36.r),
                    bottomRight: Radius.circular(36.r),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    provider.filterServicesBySearch(search: '');
                  },
                  icon: Icon(Icons.search, color: Colors.white, size: 24.sp),
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
    print(provider.categories.length);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Text(
                'Services Categories',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.0,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              if (provider.categories.isEmpty) {
                return const SkeletonListTile();
              }

              // Hijack the categories list and added a new category
              final categories = provider.categories;
              categories.insert(
                  5,
                  Category(
                    id: 7,
                    categoryName: 'Hulu Jobs',
                    description: 'A place where you find your dream job',
                    services: provider.fiterableByCatagory
                        .where((service) => service.categoryId == 7)
                        .toList(),
                  ));
              // categories.add();
              final category = provider.categories[index];

              return GestureDetector(
                onTap: () {
                  provider.filterServicesByCategory(category.id);
                  _focusNode.unfocus();
                  print(category.id);
                  if (category.id == 1) {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (context) => const TenderCategorys()));
                    return;
                  }
                  if (category.id == 7) {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                const MainScreen(initialTabIndex: 0)));
                    return;
                  }
                  if (category.id == 2) {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (context) => const BusinessHomePage()));
                    return;
                  }
                  if (category.id == 6) {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (context) => MarketplaceHomePage()));
                    return;
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CategoryServices()));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: category.icon == null
                          ? Icon(
                              [
                                Icons.restaurant,
                                Icons.motorcycle,
                                Icons.directions_car,
                                Icons.local_shipping,
                                Icons.shopping_cart,
                                Icons.face,
                                Icons.cleaning_services,
                                Icons.more_horiz
                              ].elementAt(index % 8),
                              size: 34.sp,
                              color: const Color.fromARGB(255, 77, 107, 254),
                            )
                          : Image.network(
                              '${ApiService.API_URL_FILE}${category.icon}',
                              width: 34.w,
                              height: 34.h,
                              fit: BoxFit.cover,
                              color: const Color.fromARGB(255, 77, 107, 254),
                            ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      category.categoryName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
        //            eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2N2IyZjM1ZWJhY2RlNWQ2NzFlYzc2NGMiLCJpYXQiOjE3NDE1MDA1MTQsImV4cCI6MTc0MjM2NDUxNH0.dePxghzCfauUwDFxTOsZNautV9IAQApzS70g_SFpU5g           ),
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
            .fetchServiceQuestions(service.categoryId);
        _focusNode.unfocus();
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
                            return const SizedBox.shrink();
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
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
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
                          color: const Color.fromARGB(255, 235, 173, 5),
                          size: 16.sp),
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
              _focusNode.unfocus();
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
          const Spacer(),
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
