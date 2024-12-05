import 'package:flutter/material.dart';
import 'package:home_service_app/main.dart';
import 'package:home_service_app/models/rating.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/models/technician.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/notification_provider.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
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

class _HomePageState extends State<HomePage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      print(_focusNode.hasFocus);
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeServiceProvider>(context);
    Logger().d(Localizations.localeOf(context));
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[200],
      drawer: const SideNavDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<UserProvider>(context, listen: false).loadUser();
        },
        child: ListView(
          children: [
            _buildHeaderSection(),
            _buildBannerSection(provider),
            _buildServiceCategories(provider),
            _buildservices(provider),
            _buildTechnicianListView(),
            _buildCustomerReviewsSection(),
            const FAQSection(),
          ],
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.ourBestTechnicians,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
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
          padding: const EdgeInsets.all(16.0),
          child: Text(AppLocalizations.of(context)!.whatTheCustomerSays,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
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

  Widget _buildHeaderSection() {
    final user = Provider.of<UserProvider>(context).user;
    final coin = Provider.of<UserProvider>(context).coin;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  scaffoldKey.currentState!.openDrawer();
                },
              ),
              const SizedBox(width: 4),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BuyCoinsPage()));
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 4, right: 12, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/coin.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatNumber(coin),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const LanguageSelector(),
              const SizedBox(width: 4),
              user != null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CustomerProfilePage()));
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(
                                '${ApiService.API_URL_FILE}${user.profileImage}')
                            : const AssetImage('assets/images/profile.png'),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.login_sharp),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .pushNamed(RouteGenerator.loginPage);
                      },
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              "MoyaTegna",
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 3, 175, 161)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection(HomeServiceProvider provider) {
    final user = Provider.of<UserProvider>(context).user;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [],
          ),
          Text(
            AppLocalizations.of(context)!.hello,
            style: TextStyle(
              fontSize: 32.sp,
              color: Colors.black.withOpacity(0.4),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user != null
                ? '${user.name.substring(0, 1).toUpperCase()}${user.name.substring(1).toLowerCase()}'
                : AppLocalizations.of(context)!.guest,
            style: TextStyle(
              fontSize: 42.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.everythingAtYourFingertips,
            style: const TextStyle(
              fontSize: 32,
              color: Color.fromARGB(255, 123, 162, 194),
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          // Text(
          //   AppLocalizations.of(context)!.welcomeMessage,
          //   style: const TextStyle(
          //     fontSize: 18,
          //     color: Colors.white,
          //   ),
          // ),
          // Text(
          //   AppLocalizations.of(context)!.hello("Eyosi"),
          //   style: const TextStyle(
          //     fontSize: 18,
          //     color: Colors.white,
          //   ),
          // ),
          const SizedBox(height: 30),
          _buildSearchBar(provider),
        ],
      ),
    );
  }

  Widget _buildSearchBar(HomeServiceProvider provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                _isFocused ? Border.all(color: Colors.blue, width: 1.5) : null,
          ),
          child: TextField(
            onChanged: (value) {
              provider.filterServicesBySearch(value);
            },
            focusNode: _focusNode,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              hintText: AppLocalizations.of(context)!.searchForServices,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 20),
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
        const SizedBox(
          height: 4,
        ),
        if (_isFocused)
          Container(
            height: 60 * provider.fiterableBySearch.length.toDouble(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: provider.fiterableBySearch.length,
              itemBuilder: (context, index) {
                print(provider.services[index].name);
                return GestureDetector(
                  onTap: () {
                    Provider.of<HomeServiceProvider>(context, listen: false)
                        .fetchServiceQuestions(
                            provider.fiterableBySearch[index].id);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuestionnairePage(
                                service: provider.fiterableBySearch[index])));
                  },
                  child: ListTile(
                    title: Text(provider.fiterableBySearch[index].name),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildServiceCategories(HomeServiceProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: provider.categories.map((category) {
              return GestureDetector(
                  onTap: () {
                    provider.filterServicesByCategory(category.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: provider.selectedCategory == category.id
                          ? Colors.white
                          : null,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                        child: Text(category.categoryName,
                            style: TextStyle(
                                color: provider.selectedCategory == category.id
                                    ? Colors.black
                                    : const Color.fromARGB(255, 55, 84, 122),
                                fontWeight: FontWeight.w600,
                                fontSize: 18))),
                  ));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildservices(HomeServiceProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 1,
          childAspectRatio: 1,
        ),
        itemCount: provider.fiterableByCatagory.length,
        itemBuilder: (context, index) {
          return _buildServiceCard(provider.fiterableByCatagory[index]);
        },
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.green, size: 20),
                const SizedBox(width: 4),
                Text(
                  '\$${service.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (service.description != null && service.description!.isNotEmpty)
              Text(
                service.description!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            const Spacer(),
            Text(
              service.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianCard(Technician tech) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(left: 16, top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  '${ApiService.API_URL_FILE}${tech.profileImage}',
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/profile.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tech.name ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: tech.services
                            .map((service) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    service.name,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ))
                            .toList() ??
                        [],
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tech.bio ?? 'No bio available',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
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
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.grey, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          '${tech.subcity ?? ''}, ${tech.city ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.rating,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color.fromARGB(255, 235, 173, 5), size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${tech.rating ?? 0}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(AppLocalizations.of(context)!.viewProfile,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              review.rating,
              (index) => const Icon(Icons.star, color: Colors.yellow, size: 16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.review,
            style: const TextStyle(fontSize: 16, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          const Spacer(),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  '${ApiService.API_URL_FILE}${review.customer.profileImage}',
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/profile.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.customer.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(review.customer.email,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
