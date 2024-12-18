import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:home_service_app/models/booking.dart';
import 'package:home_service_app/provider/profile_page_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressesPage extends StatefulWidget {
  final bool isTechinician;
  const AddressesPage({super.key, this.isTechinician = false});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isTechinician) {
        Provider.of<ProfilePageProvider>(context, listen: false)
            .fetchTechnicianAddresses();
      } else {
        Provider.of<ProfilePageProvider>(context, listen: false)
            .fetchCustomerAddresses();
      }
    });
  }

  // Address Card UI
  Widget _buildAddressCard(Address address) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2.r,
            blurRadius: 5.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.redAccent, size: 28.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.street ?? 'No Street Information',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${address.subcity ?? 'No Subcity'}, ${address.city ?? 'No City'}\n'
                  'Wereda: ${address.wereda ?? 'N/A'}, ${address.country ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Addresses',
            style: TextStyle(color: Colors.white, fontSize: 20.sp)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ProfilePageProvider>(
        builder: (context, profilePageProvider, child) {
          if (profilePageProvider.isLoading) {
            return Center(
              child: SpinKitFadingCircle(color: Colors.blueAccent, size: 50.sp),
            );
          } else {
            final addresses = profilePageProvider.addresses;
            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                return _buildAddressCard(addresses[index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement Add Address Functionality
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }
}
