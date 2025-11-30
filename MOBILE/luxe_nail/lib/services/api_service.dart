import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Centralized Base URL
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://192.168.1.67:8000';

  // Headers helper
  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  // ===========================================================================
  // LOGIN
  // ===========================================================================
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/login');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // ===========================================================================
  // GET RESERVATIONS
  // ===========================================================================
static Future<Map<String, dynamic>> getUserProfile(String token) async {
  final url = Uri.parse('$baseUrl/api/v1/user');

  try {
    final response = await http.get(
      url,
      headers: {
        ..._headers,
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Empty response body',
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Failed to load profile (${response.statusCode})',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Connection error: $e',
    };
  }
}


  // ===========================================================================
  // GET CATEGORIES (AI)
  // ===========================================================================
  static Future<Map<String, dynamic>> getCategories(String token) async {
    final url = Uri.parse("$baseUrl/api/v1/categories");

    try {
      final response = await http.get(
        url,
        headers: {
          ..._headers,
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return {
          'success': true,
          'data': json['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch categories (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // ===========================================================================
  // GENERATE AI IMAGE
  // ===========================================================================
  static Future<Map<String, dynamic>> generateAIImage(String token, String prompt, int reservationId) async {
    final url = Uri.parse("$baseUrl/api/v1/ai/generate");

    try {
      final response = await http.post(
        url,
        headers: {
          ..._headers,
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "prompt": prompt,
          "reservation_id": reservationId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'image_url': data['image_url'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Generation failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // ===========================================================================
  // CONFIRM PAYMENT
  // ===========================================================================
  static Future<Map<String, dynamic>> confirmPayment(String token, Map<String, dynamic> paymentData) async {
    final url = Uri.parse("$baseUrl/api/v1/income/store");

    try {
      final response = await http.post(
        url,
        headers: {
          ..._headers,
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(paymentData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Payment confirmation failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static Future<dynamic> getReservations(String token, {required String date}) async {}
}