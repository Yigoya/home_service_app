import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_service_app/utils/functions.dart';
import 'package:logger/web.dart';
import 'dart:io';

class ApiService {
  final Dio _dio = Dio();
  final storage = const FlutterSecureStorage();
  static String API_URL = "https://hulumoya.zapto.org";
  // static String API_URL = "http://10.2.76.189:5000";

  static String API_URL_FILE = "$API_URL/uploads/";
  ApiService() {
    _dio.options.baseUrl = API_URL; // Replace with actual URL
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
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

  // I don't think this is ma fault
  Future<Response> putRequestWithFormData(
      String endpoint, FormData data) async {
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

  Future<Response> jobFinderSignup(
      {required String name,
      required String email,
      required String phoneNumber,
      required String password}) async {
    return await _dio.post("/auth/register", data: {
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
      "role": "JOB_SEEKER"
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

  // Upload resume file and return the URL
  Future<String?> uploadResumeFile(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/uploads/', data: formData);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Assuming the API returns the file URL in response.data['url']
      return response.data['url'] ??
          response.data['fileUrl'] ??
          response.data['path'];
    }
    return null;
  }

  // Upload resume for job seeker and return the URL
  Future<String?> uploadJobSeekerResume({
    required int userId,
    required String filePath,
  }) async {
    try {
      Logger().d('Uploading resume for user ID: $userId');
      Logger().d('File path: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        Logger().e('File does not exist: $filePath');
        return null;
      }

      final fileSize = await file.length();
      Logger().d('File size: $fileSize bytes');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      Logger().d('Making request to: /profiles/seeker/$userId/resume');
      final response =
          await _dio.post('/profiles/seeker/$userId/resume', data: formData);

      Logger().d('Response status: ${response.statusCode}');
      Logger().d('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resumeUrl = response.data['resumeUrl'];
        Logger().d('Resume URL: $resumeUrl');
        return resumeUrl;
      } else {
        Logger().e('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      Logger().e('DioException during resume upload: $e');
      Logger().e('Response status: ${e.response?.statusCode}');
      Logger().e('Response data: ${e.response?.data}');
      Logger().e('Error message: ${e.message}');
      return null;
    } catch (e) {
      Logger().e('Unexpected error during resume upload: $e');
      return null;
    }
  }

  // Create/Update job seeker profile
  Future<Response> createJobSeekerProfile({
    required int userId,
    required String headline,
    required String summary,
    required String skills,
    String? resumeUrl,
  }) async {
    try {
      Logger().d('Creating/Updating job seeker profile...');
      Logger().d('User ID: $userId');

      final formData = FormData.fromMap({
        'userId': userId,
        'headline': headline,
        'summary': summary,
        'skills': skills.toString(),
        'resume': resumeUrl ?? 'placeholder',
      });

      Logger().d('Request data: ${formData.fields}');
      Logger().d('Making request to: /profiles/seeker');

      final response = await _dio.post('/profiles/seeker', data: formData);

      Logger().d('Response status: ${response.statusCode}');
      Logger().d('Response data: ${response.data}');

      return response;
    } on DioException catch (e) {
      Logger().e('DioException during profile creation: $e');
      Logger().e('Response status: ${e.response?.statusCode}');
      Logger().e('Response data: ${e.response?.data}');
      Logger().e('Error message: ${e.message}');
      rethrow;
    } catch (e) {
      Logger().e('Unexpected error during profile creation: $e');
      rethrow;
    }
  }

  // Submit job application
  Future<Response> submitJobApplication({
    required int jobId,
    required int userId,
    required String coverLetter,
    required String resumeUrl,
  }) async {
    try {
      Logger().d('Submitting job application...');
      Logger().d('Job ID: $jobId, User ID: $userId');

      final data = {
        'userId': userId,
        'coverLetter': coverLetter,
        'resumeUrl': resumeUrl,
      };

      Logger().d('Request data: $data');
      Logger().d('Making request to: /jobs/$jobId/apply');

      final response = await _dio.post('/jobs/$jobId/apply', data: data);

      Logger().d('Response status: ${response.statusCode}');
      Logger().d('Response data: ${response.data}');

      return response;
    } on DioException catch (e) {
      Logger().e('DioException during job application: $e');
      Logger().e('Response status: ${e.response?.statusCode}');
      Logger().e('Response data: ${e.response?.data}');
      Logger().e('Error message: ${e.message}');
      rethrow;
    } catch (e) {
      Logger().e('Unexpected error during job application: $e');
      rethrow;
    }
  }

  // Fetch user applications
  Future<Response> getUserApplications(int userId) async {
    try {
      // Authorization header removed as backend no longer requires it
      Logger().d('Fetching applications for user ID: $userId');
      Logger().d('Making request to: /my-applications/$userId');

      final response = await _dio.get('/my-applications/$userId');

      Logger().d('Response status: ${response.statusCode}');
      Logger().d('Response data: ${response.data}');

      return response;
    } on DioException catch (e) {
      Logger().e('DioException while fetching applications: $e');
      Logger().e('Response status: ${e.response?.statusCode}');
      Logger().e('Response data: ${e.response?.data}');
      Logger().e('Error message: ${e.message}');
      rethrow;
    } catch (e) {
      Logger().e('Unexpected error while fetching applications: $e');
      rethrow;
    }
  }

  Future<Response> postMultipartRequest(
      String endpoint, FormData formData) async {
    try {
      String? token = await storage.read(key: 'auth_token');
      return await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Save a job for a user
  Future<Response> saveJob({required int userId, required int jobId}) async {
    try {
      Logger().d('Saving job $jobId for user $userId');
      final response = await _dio.post('/saved/$userId/jobs/$jobId');
      Logger().d('Response status:  [32m${response.statusCode} [0m');
      Logger().d('Response data: ${response.data}');
      return response;
    } on DioException catch (e) {
      Logger().e('DioException while saving job: $e');
      Logger().e('Response status: ${e.response?.statusCode}');
      Logger().e('Response data: ${e.response?.data}');
      Logger().e('Error message: ${e.message}');
      rethrow;
    } catch (e) {
      Logger().e('Unexpected error while saving job: $e');
      rethrow;
    }
  }

  // Get saved jobs for a user
  Future<Response> getSavedJobs(int userId) async {
    try {
      Logger().d('Fetching saved jobs for user $userId');
      final response = await _dio.get('/saved/$userId/jobs');
      Logger().d('Response status:  [32m${response.statusCode} [0m');
      Logger().d('Response data: ${response.data}');
      return response;
    } on DioException catch (e) {
      Logger().e('DioException while fetching saved jobs: $e');
      Logger().e('Response status: ${e.response?.statusCode}');
      Logger().e('Response data: ${e.response?.data}');
      Logger().e('Error message: ${e.message}');
      rethrow;
    } catch (e) {
      Logger().e('Unexpected error while fetching saved jobs: $e');
      rethrow;
    }
  }

  // Remove a saved job for a user
  Future<Response> removeSavedJob(
      {required int userId, required int jobId}) async {
    try {
      Logger().d('Removing saved job $jobId for user $userId');
      final response = await _dio.delete('/saved/$userId/jobs/$jobId');
      Logger().d('Response status:  [32m${response.statusCode} [0m');
      Logger().d('Response data: ${response.data}');
      return response;
    } on DioException catch (e) {
      Logger().e('DioException while removing saved job: $e');
      Logger().e('Response status: ${e.response?.statusCode}');
      Logger().e('Response data: ${e.response?.data}');
      Logger().e('Error message: ${e.message}');
      rethrow;
    } catch (e) {
      Logger().e('Unexpected error while removing saved job: $e');
      rethrow;
    }
  }

  // Upload profile image for job seeker and return the full URL
  Future<String?> uploadProfileImage({
    required int userId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/profile/uploadProfileImage/$userId',
          data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final fileName = response.data['profileImage'];
        if (fileName != null && fileName is String) {
          return 'https://hulumoya.zapto.org/uploads/$fileName';
        }
      }
      return null;
    } catch (e) {
      Logger().e('Error uploading profile image: $e');
      return null;
    }
  }

  Future<Response> postMultipartRequestWithoutToken(
      String endpoint, FormData formData) async {
    try {
      return await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

// {
//   "keep": [
//     "id",
//     "jobId",
//     "jobTitle",
//     "companyName",
//     "companyLogo",
//     "status",
//     "appliedDate",
//     "coverLetter",
//     "resumeUrl",
//     "jobType",
//     "location",
//     "salaryRange"
//   ],
//   "optional": [
//     "avatar",
//     "companyName",
//     "jobType",
//     "location",
//     "salaryRange"
//   ],
//   "remove": [
//     "email",
//     "phone",
//     "experience",
//     "rating",
//     "jobSeekerId",
//     "jobSeekerName"
//   ]
// }
