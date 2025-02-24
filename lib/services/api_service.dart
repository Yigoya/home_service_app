import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:logger/web.dart';

class ApiService {
  final Dio _dio = Dio();
  final storage = const FlutterSecureStorage();
  static String API_URL = "https://hulumoya2.zapto.org";
  static String API_URL_FILE = "$API_URL/uploads/";
  ApiService() {
    _dio.options.baseUrl = API_URL; // Replace with actual URL
  }

  Future<Response> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    // String? token = await storage.read(key: "jwt_token");
    // _dio.options.headers['Authorization'] = 'Bearer $token';
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> postRequestWithoutToken(
      String endpoint, Map<String, dynamic> data) async {
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> patchRequestWithoutToken(
      String endpoint, Map<String, dynamic> data) async {
    return await _dio.patch(endpoint, data: data);
  }

  Future<Response> getRequest(String endpoint) async {
    // String? token = await storage.read(key: "jwt_token");
    // _dio.options.headers['Authorization'] = 'Bearer $token';
    return await _dio.get(endpoint);
  }

  Future<Response> deleteRequest(String endpoint) async {
    // String? token = await storage.read(key: "jwt_token");
    // _dio.options.headers['Authorization'] = 'Bearer $token';
    return await _dio.delete(endpoint);
  }

  Future<Response> putRequest(
      String endpoint, Map<String, dynamic> data) async {
    // String? token = await storage.read(key: "jwt_token");
    // _dio.options.headers['Authorization'] = 'Bearer $token';
    return await _dio.put(endpoint, data: data);
  }

  Future<Response> patchRequest(
      String endpoint, Map<String, dynamic> data) async {
    // String? token = await storage.read(key: "jwt_token");
    // _dio.options.headers['Authorization'] = 'Bearer $token';
    return await _dio.patch(endpoint, data: data);
  }

  Future<Response> login(
      {required String email, required String password}) async {
    final deviceInfo = await getDeviceInfo();
    final FCMtoken = await storage.read(key: "fcm_token");
    final data = {
      "email": email,
      "password": password,
      "FCMToken": FCMtoken,
      "deviceType": deviceInfo["deviceType"],
      "deviceModel": deviceInfo["deviceModel"],
      "operatingSystem": deviceInfo["operatingSystem"]
    };
    Logger().d(data);
    return await _dio.post("/auth/login", data: data);
  }

  Future<Response> signup(
      {required String name,
      required String email,
      required String phoneNumber,
      required String password}) async {
    return await _dio.post("/auth/customer/signup", data: {
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password
    });
  }

  Future<Response> getRequestWithoutToken(String endpoint) async {
    return await _dio.get(endpoint);
  }

  Future<Response> getRequestByQueryWithoutToken(
      String endpoint, Map<String, dynamic> query) async {
    return await _dio.get(endpoint, queryParameters: query);
  }

  Future<Response> technicianSignup(FormData formData) async {
    return await _dio.post("/auth/technician/signup", data: formData);
  }

  Future<Response> multiPartRequest(String endpoint, FormData formData) async {
    return await _dio.post(endpoint, data: formData);
  }
}
