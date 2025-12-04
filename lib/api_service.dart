import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://start-app-u8sb.onrender.com";

  // ------------------ POST REQUEST ------------------
  static Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      print('🔗 API Call: $baseUrl$endpoint');
      print('📤 Request Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final responseBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseBody;
      } else if (response.statusCode == 400) {
        throw Exception(responseBody['error'] ?? 'Bad Request');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid token');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint not found');
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }

  // ------------------ GET REQUEST ------------------
  static Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    String? token,
  }) async {
    try {
      print('🔗 GET: $baseUrl$endpoint');

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      final responseBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to load data');
      }
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }

  // ------------------ PUT REQUEST ------------------
  static Future<Map<String, dynamic>> putRequest(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      print('🔗 PUT: $baseUrl$endpoint');
      print('📤 Request Body: $body');

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      final responseBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to update');
      }
    } catch (e) {
      print('❌ PUT Error: $e');
      rethrow;
    }
  }

  // ------------------ DELETE REQUEST ------------------
  static Future<Map<String, dynamic>> deleteRequest(
    String endpoint, {
    String? token,
  }) async {
    try {
      print('🔗 DELETE: $baseUrl$endpoint');

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      final responseBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to delete');
      }
    } catch (e) {
      print('❌ DELETE Error: $e');
      rethrow;
    }
  }

  // ------------------ AUTH APIs ------------------

  static Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String mobile,
    required String email,
  }) async {
    return await postRequest('/auth/signup', {
      'fullName': fullName,
      'mobile': mobile,
      'email': email,
    });
  }

  static Future<Map<String, dynamic>> signIn(String mobile) async {
    return await postRequest('/auth/signin', {
      'mobile': mobile,
    });
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    return await postRequest('/auth/verify', {
      'mobile': mobile,
      'otp': otp,
    });
  }

  // ------------------ APPOINTMENT APIs ------------------

  static Future<Map<String, dynamic>> createAppointment({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    return await postRequest('/appointments', body, token: token);
  }

  static Future<Map<String, dynamic>> fetchAppointments({
    required String token,
  }) async {
    return await getRequest('/appointments', token: token);
  }

  static Future<Map<String, dynamic>> updateAppointment({
    required String token,
    required String id,
    required Map<String, dynamic> body,
  }) async {
    return await putRequest('/appointments/$id', body, token: token);
  }

  static Future<Map<String, dynamic>> deleteAppointment({
    required String token,
    required String id,
  }) async {
    return await deleteRequest('/appointments/$id', token: token);
  }
}
