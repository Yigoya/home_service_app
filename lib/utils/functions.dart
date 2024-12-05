import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
