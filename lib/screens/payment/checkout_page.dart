import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_service_app/provider/payment_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home_service_app/l10n/app_localizations.dart';

class CheckoutPage extends StatefulWidget {
  final double amount;
  const CheckoutPage({super.key, required this.amount});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    // Fetch banks when the page loads
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        elevation: 0,
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontSize: 20.sp),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Text(
              'Payment Method',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            if (paymentProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  children: paymentProvider.banks.map((bank) {
                    return _buildPaymentMethodItem(
                      bank['name'],
                      bank[
                          'image'], // Assuming the bank data contains a 'logo' field
                      bank[
                          'code'], // Assuming the bank data contains a 'code' field
                      paymentProvider.selectedBank == bank['code'],
                      () {
                        paymentProvider.setSelectedBank(bank['code']);
                      },
                    );
                  }).toList(),
                ),
              ),
            SizedBox(height: 20.h),
            const Spacer(),
            ElevatedButton(
              onPressed: paymentProvider.selectedBank == null
                  ? null
                  : () async {
                      final checkoutUrl = await Provider.of<PaymentProvider>(
                              context,
                              listen: false)
                          .initializePayment(
                        context: context,
                        amount: widget.amount,
                        email: user!.email,
                        firstName: user.name.split(' ')[0],
                        lastName: user.name.contains(' ')
                            ? user.name.split(' ')[1]
                            : '',
                      );
                      if (checkoutUrl.isNotEmpty) {
                        final Uri checkoutUri = Uri.parse(checkoutUrl);
                        if (await canLaunchUrl(checkoutUri)) {
                          await launchUrl(checkoutUri);
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .couldNotLaunchPaymentPage)),
                          );
                        }
                      } else {
                        // Show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .failedToInitializePayment)),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Center(
                child: Text(
                  'Pay ${widget.amount} ETB',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    String name,
    String imagePath,
    String code,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple[50] : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(
              imagePath,
              width: 50.w,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            name,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
