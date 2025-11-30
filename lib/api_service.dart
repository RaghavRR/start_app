import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://start-app-u8sb.onrender.com';

  static Future<Map<String, dynamic>> postRequest(
      String endpoint,
      Map<String, dynamic> body
      ) async {
    try {
      print('🔗 API Call: $baseUrl$endpoint');
      print('📤 Request Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200) {
        return responseBody;
      } else if (response.statusCode == 400) {
        throw Exception(responseBody['error'] ?? 'Bad Request: Please check your input data');
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API Error: $e');
      rethrow;
    }
  }

  // Sign up API - CORRECTED FIELD NAMES
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

  // Sign in API - CORRECTED FIELD NAMES
  static Future<Map<String, dynamic>> signIn(String mobile) async {
    return await postRequest('/auth/signin', {
      'mobile': mobile,
    });
  }

  // Verify OTP API - CORRECTED FIELD NAMES
  static Future<Map<String, dynamic>> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    return await postRequest('/auth/verify', {
      'mobile': mobile,
      'otp': otp,
    });
  }
}