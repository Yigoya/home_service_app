import 'package:flutter/material.dart';
import 'package:home_service_app/models/subscription.dart';
import 'package:home_service_app/provider/subsription_provider.dart';
import 'package:home_service_app/screens/auth/login.dart';
import 'package:home_service_app/screens/auth/signup.dart';
import 'package:home_service_app/screens/tender/tender_registeration.dart';
import 'package:provider/provider.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Subscribe Now',
              style: TextStyle(color: Colors.white)),
          elevation: 0,
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       // Navigate to Register page
          //       // Navigator.pushNamed(context, '/register');
          //     },
          //     child: const Text(
          //       'Register Now',
          //       style: TextStyle(color: Colors.white, fontSize: 16),
          //     ),
          //   ),
          //   TextButton(
          //     onPressed: () {
          //       // Navigate to Login page
          //       // Navigator.pushNamed(context, '/login');
          //     },
          //     child:  Text(
          //       'Login',
          //       style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 16),
          //     ),
          //   ),
          // ],
        ),
        body: const SubscriptionContent(),
      ),
    );
  }
}

class SubscriptionContent extends StatefulWidget {
  const SubscriptionContent({super.key});

  @override
  State<SubscriptionContent> createState() => _SubscriptionContentState();
}

class _SubscriptionContentState extends State<SubscriptionContent> {
  final PageController _pageController = PageController(viewportFraction: 0.75);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Subscribe Now to Get Access to Intelligent Tender Database',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We offer Monthly and Annual subscriptions',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: subscriptionProvider.subscriptions.length,
            itemBuilder: (context, index) {
              return _buildSubscriptionCard(
                context: context,
                subscription: subscriptionProvider.subscriptions[index],
                index: index,
              );
            },
          ),
        ),
        // const SizedBox(height: 20),
        // Consumer<SubscriptionProvider>(
        //   builder: (context, provider, child) {
        //     return ElevatedButton(
        //       onPressed: provider.selectedSubscription == null
        //           ? null
        //           : () async {
        //               await _handleSubscription(context, provider);
        //             },
        //       style: ElevatedButton.styleFrom(
        //         minimumSize: const Size(double.infinity, 50),
        //         backgroundColor: Theme.of(context).secondaryHeaderColor,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(12),
        //         ),
        //       ),
        //       child: const Text(
        //         'Subscribe Now',
        //         style: TextStyle(fontSize: 18, color: Colors.white),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }

  Widget _buildSubscriptionCard({
    required BuildContext context,
    required Subscription subscription,
    required int index,
  }) {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    const double maxScale = 1.0; // Full size for center item
    const double minScale = 0.8; // Smaller size for off-center items

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        // Calculate scroll position
        double value = 0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - value.abs()).clamp(0.0, 1.0);
        } else {
          value = index == 0 ? 1.0 : 0.0;
        }

        // Calculate scale based on scroll position
        final double scale = minScale + (maxScale - minScale) * value;
        final double elevation =
            4 + (8 - 4) * value; // Increase elevation for center item
        print(
            'Scale: $scale, Elevation: $elevation for index: $index and value: $value page: ${_pageController.page}');
        return Center(
          child: Transform.scale(
            scale: scale,
            child: Card(
              color: Colors.white,
              elevation: elevation,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: subscription.price == 0.0
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              subscription.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              subscription.price == 0.0
                                  ? '0 Birr'
                                  : '${subscription.price} Birr',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                // color: subscription.price == 0.0
                                //     ? Theme.of(context).secondaryHeaderColor
                                //     : Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        if (subscription.duration != 'N/A')
                          Text(
                            subscription.duration,
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize
                          .min, // Ensure card height adjusts to content
                      children: [
                        const SizedBox(height: 16),
                        ...subscription.features.map((feature) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.grey[600], size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[800]),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                        if (subscription.price == 0.0)
                          SizedBox(
                            height: 32,
                          ),
                        ElevatedButton(
                          onPressed: () {
                            if (subscription.price == 0.0) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupPage()));
                            } else {
                              // subscriptionProvider
                              //     .selectSubscription(subscription);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TenderRegisteration()));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                            backgroundColor: subscription.price == 0.0
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            subscription.price == 0.0
                                ? 'Register Now'
                                : 'Subscribe Now',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (subscription.price == 0.0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Any user of the website can search for State Tenders for Free and download the Tender Documents for Free after registering.',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        SizedBox(
                          height: (subscription.price == 0.0) ? 48 : 16,
                          child: subscriptionProvider.selectedSubscription ==
                                  subscription
                              ? const LinearProgressIndicator()
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubscription(
      BuildContext context, SubscriptionProvider provider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await provider.processSubscriptionPayment();

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription successful!')),
        );
        // Navigate to dashboard or tender access page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Try again.')),
        );
      }
    }
  }
}
