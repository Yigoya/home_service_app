import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/web.dart';

Future<Map<String, String>> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return {
      "deviceType": "Android",
      "deviceModel": androidInfo.model ?? "Unknown",
      "operatingSystem": "ANDROID ${androidInfo.version.release ?? "Unknown"}"
    };
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return {
      "deviceType": "iPhone",
      "deviceModel": iosInfo.utsname.machine ?? "Unknown",
      "operatingSystem": "iOS ${iosInfo.systemVersion ?? "Unknown"}"
    };
  }

  return {
    "deviceType": "Unknown",
    "deviceModel": "Unknown",
    "operatingSystem": "Unknown"
  };
}

enum UserStatus {
  GUEST,
  CUSTOMER,
  TECHNICIAN,
  TOKEN_ENTRY,
  PROOF_ENTRY,
  WAITING_FOR_APPROVAL,
}

const storage = FlutterSecureStorage();

Future<void> saveUserStatus(UserStatus status) async {
  await storage.write(key: 'user_status', value: status.name);
}

// Future<UserStatus> getUserStatus(BuildContext context) async {
//   await NotificationService().initialize();
//   await Provider.of<UserProvider>(context, listen: false).loadUser();
//   await Provider.of<HomeServiceProvider>(context, listen: false).loadHome();
//   String? status = await storage.read(key: 'user_status');
//   Logger().d(status);
//   return UserStatus.values.firstWhere(
//     (e) => e.name == status,
//     orElse: () => UserStatus.GUEST,
//   );
// }

void showTopMessage(BuildContext context, String message,
    {bool isSuccess = true, bool isWaring = false}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSuccess && !isWaring
                  ? Colors.green
                  : isWaring
                      ? Colors.amber[600]
                      : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);

  // Remove the message after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

String formatNumber(int number) {
  if (number >= 1000000) {
    return (number / 1000000).toStringAsFixed(1) + 'M';
  } else if (number >= 1000) {
    return (number / 1000).toStringAsFixed(1) + 'k';
  } else {
    return number.toString();
  }
}

/// A robust function to get the current location and address
Future<Map<String, Object?>> getCurrentLocation() async {
  try {
    // Check if location services are enabled
    if (!await Geolocator.isLocationServiceEnabled()) {
      return {
        "error":
            "Location services are disabled. Please enable them in settings."
      };
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          "error":
              "Location permission denied. Please grant permission to access location."
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        "error":
            "Location permission is permanently denied. Please enable it in settings."
      };
    }

    // Fetch the current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // Convert coordinates to a human-readable address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      final location = {
        "street": place.street,
        "subcity": place.subLocality,
        "city": place.locality,
        "country": place.country,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "postalCode": place.postalCode,
        "name": place.name,
      };
      return location;
    } else {
      return {"error": "Unable to fetch address for the current location."};
    }
  } catch (e) {
    // Catch and return any errors
    return {"error": "An error occurred while fetching the location: $e"};
  }
}
