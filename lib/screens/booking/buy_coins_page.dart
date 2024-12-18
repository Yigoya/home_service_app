import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuyCoinsPage extends StatelessWidget {
  const BuyCoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample packages (these can come from a backend or a database)
    final coinPackages = [
      {
        'coins': 100,
        'price': 1.99,
        'discount': 0.1,
        'icon': 'assets/images/coin2.png'
      },
      {
        'coins': 500,
        'price': 3.99,
        'discount': 0.1,
        'icon': 'assets/images/coin3.png'
      },
      {
        'coins': 1000,
        'price': 8.99,
        'discount': 0.1,
        'icon': 'assets/images/coins2.png'
      },
      {
        'coins': 5000,
        'price': 15.99,
        'discount': 0.1,
        'icon': 'assets/images/coins.png'
      },
    ];

    Future<void> buyCoin(int amount) async {
      await Provider.of<UserProvider>(context, listen: false).buyCoin(amount);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 182, 230, 227),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.w),
          margin: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                blurRadius: 10.r,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 12.h,
              ),
              Text(
                "Choose a Coin Package",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 450.h,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 1,
                  ),
                  itemCount: coinPackages.length,
                  itemBuilder: (context, index) {
                    final package = coinPackages[index];
                    return Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            blurRadius: 5.r,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            package['icon'] as String,
                            width: 60.w,
                            height: 60.h,
                          ),
                          Text(
                            "${package['coins']} Coins",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              buyCoin(package['coins'] as int);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Purchase Successful"),
                                  content: Text(
                                    "You have purchased ${package['coins']} coins for \$${package['price']}.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  const Color.fromARGB(255, 9, 222, 250),
                                  const Color.fromARGB(255, 9, 250, 190),
                                ]),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                "\$${(package['price'] as double).toStringAsFixed(2)}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
