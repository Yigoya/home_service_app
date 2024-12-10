import 'package:flutter/material.dart';
import 'package:home_service_app/models/rating.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:home_service_app/screens/booking/buy_coins_page.dart';
import 'package:home_service_app/screens/booking/questionnaire_page.dart';
import 'package:home_service_app/screens/home/sidebar_drawer.dart';
import 'package:home_service_app/screens/home/widgets.dart';
import 'package:home_service_app/screens/profile/customer_profile_page.dart';
import 'package:home_service_app/screens/profile/technician_detail_page.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:home_service_app/widgets/language_selector.dart';
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
      backgroundColor: Colors.grey[200],
      drawer: const SideNavDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<UserProvider>(context, listen: false).loadUser();
          },
          child: ListView(
            children: [
              _buildBannerSection(provider),
              _buildServiceCategories(provider),
              _buildservices(provider),
              _buildTechnicianListView(),
              _buildCustomerReviewsSection(),
              const FAQSection(),
            ],
          ),
        ),
      ),
    );
  }

  // New function to build the technician list view
  Widget _buildTechnicianListView() {
    final technicians =
        Provider.of<HomeServiceProvider>(context).topTechnicians;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.ourBestTechnicians,
                style: TextStyle(
                  fontSize: 24.sp,
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
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(AppLocalizations.of(context)!.whatTheCustomerSays,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
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
      ],
    );
  }

  Widget _buildBannerSection(HomeServiceProvider provider) {
    final user = Provider.of<UserProvider>(context).user;
    final coin = Provider.of<UserProvider>(context).coin;
    final location = Provider.of<UserProvider>(context).location;
    Logger().d(Localizations.localeOf(context));
    return Stack(
      children: [
        Container(
          height: Localizations.localeOf(context).languageCode == 'en'
              ? 295.h
              : 265.h,
          decoration: const BoxDecoration(
            color: Color(0xFF222222),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  user != null
                      ? Expanded(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CustomerProfilePage()));
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20.r,
                                      backgroundImage: user.profileImage != null
                                          ? NetworkImage(
                                              '${ApiService.API_URL_FILE}${user.profileImage}')
                                          : const AssetImage(
                                                  'assets/images/profile.png')
                                              as ImageProvider,
                                    ),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Text(
                                      'Hi, ${user.name.substring(0, 1).toUpperCase()}${user.name.substring(1).toLowerCase()}',
                                      style: TextStyle(
                                        fontSize: 28.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                  user != null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const BuyCoinsPage()));
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 4.w),
                            padding: EdgeInsets.only(
                                left: 4.w, right: 12.w, top: 4.h, bottom: 4.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xaadb36a4),
                                Color(0x99f7ff00),
                              ]),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/coin.png',
                                  width: 20.w,
                                  height: 20.h,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  formatNumber(coin),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  const LanguageSelector(),
                  SizedBox(width: 4.w),
                  user == null
                      ? Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pushNamed(RouteGenerator
                                          .technicianRegisterPage);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.r),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF642b73),
                                        Color(0xFFc6426e),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    'Become a Technician',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pushNamed(RouteGenerator.loginPage);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.r),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFC466B),
                                        Color(0xFF3F5EFB),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              SizedBox(height: 24.h),
              Text("Current Location",
                  style: TextStyle(
                      fontSize: 22.sp,
                      color: Colors.grey[200]!,
                      fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      color: Colors.green[400], size: 16.sp),
                  Text(
                      '${location['subcity'] ?? ''}, ${location['city'] ?? ''}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: const Color.fromARGB(255, 6, 245, 245),
                      )),
                ],
              ),
              SizedBox(height: 36.h),
              Text(
                AppLocalizations.of(context)!.everythingAtYourFingertips,
                style: TextStyle(
                  fontSize: 32.sp,
                  color: const Color.fromARGB(255, 123, 162, 194),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 36.h),
              _buildSearchBar(provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(HomeServiceProvider provider) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: _isFocused
                ? Border.all(color: Colors.blue, width: 1.5.w)
                : null,
          ),
          child: TextField(
            onChanged: (value) {
              provider.filterServicesBySearch(search: value);
            },
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              hintText: AppLocalizations.of(context)!.searchForServices,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 20.sp),
              border: InputBorder.none,
              prefixIcon: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
                icon: Icon(Icons.search, color: Colors.black.withOpacity(0.5)),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 4.h,
        ),
        if (_isFocused)
          Container(
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: const Color.fromARGB(69, 33, 149, 243), width: 1.5.w),
            ),
            child: ListView.builder(
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                print(provider.categories[index].categoryName);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        provider.filterServicesBySearch(
                            isCategory: true,
                            categoryId: provider.categories[index].id);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 16.h, left: 16.w),
                        child: Text(
                          provider.categories[index].categoryName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    provider.fiterableBySearch
                                .where((service) =>
                                    service.categoryId ==
                                    provider.categories[index].id)
                                .length !=
                            0
                        ? SizedBox(
                            height: 50.h,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  SizedBox(
                                    width: 16.w,
                                  ),
                                  ...provider.fiterableBySearch
                                      .where((service) =>
                                          service.categoryId ==
                                          provider.categories[index].id)
                                      .map((service) => Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Provider.of<HomeServiceProvider>(
                                                          context,
                                                          listen: false)
                                                      .fetchServiceQuestions(
                                                          provider
                                                              .fiterableBySearch[
                                                                  index]
                                                              .id);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              QuestionnairePage(
                                                                  service: provider
                                                                          .fiterableBySearch[
                                                                      index])));
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    left: 8.w,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 32.w,
                                                      vertical: 8.h),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32.r),
                                                    border: Border.all(
                                                        color: Colors.blue),
                                                  ),
                                                  child: Text(
                                                    service.name,
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                      .toList(),
                                ]),
                          )
                        : SizedBox.shrink()
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildServiceCategories(HomeServiceProvider provider) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Text(
                "Services ",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(4.w),
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.r),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: provider.categories.map((category) {
                return GestureDetector(
                    onTap: () {
                      provider.filterServicesByCategory(category.id);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: provider.selectedCategory == category.id
                            ? Colors.white
                            : null,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                          child: Text(category.categoryName,
                              style: TextStyle(
                                  color: provider.selectedCategory ==
                                          category.id
                                      ? Colors.black
                                      : const Color.fromARGB(255, 55, 84, 122),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp))),
                    ));
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildservices(HomeServiceProvider provider) {
    return Container(
        padding: EdgeInsets.all(4.w),
        child: Wrap(
          spacing: 5.w,
          runSpacing: 6.h,
          children: provider.fiterableByCatagory
              .map((service) => _buildServiceCard(service))
              .toList(),
        ));
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
        width: 12.w * service.name.length.toDouble(),
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
      width: 320.w,
      margin: EdgeInsets.only(left: 16.w, top: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: Offset(0, 2.h),
                blurRadius: 2.r)
          ]),
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
                      fontSize: 24.sp,
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
                                  horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '...',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              service.name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
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
              color: Colors.grey,
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
                    SizedBox(height: 5.h),
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
                            fontSize: 18.sp,
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
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.star,
                          color: Color.fromARGB(255, 235, 173, 5), size: 16.sp),
                      SizedBox(width: 5.w),
                      Text(
                        '${tech.rating ?? 0}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16.sp,
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
                      fontSize: 18.sp)),
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
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: Offset(0, 2.h),
                blurRadius: 2.r)
          ]),
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
            style: TextStyle(fontSize: 16.sp, height: 1.5.h),
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
                          fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  Text(review.customer.email,
                      style:
                          TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
