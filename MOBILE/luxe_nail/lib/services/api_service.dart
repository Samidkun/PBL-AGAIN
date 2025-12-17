import 'dart:convert';
import 'package:http/http.dart' as http;
// import removed: unused dotenv
import 'package:flutter/foundation.dart';

class ApiService {
  // Centralized Base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://web-luxe-nail-main-jfcax3.laravel.cloud'; // Localhost for Web
    }
    return 'https://web-luxe-nail-main-jfcax3.laravel.cloud'; // Android Emulator
  }

  // Headers helper
  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip',
      };

  // ===========================================================================
  // LOGIN
  // ===========================================================================
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse('$baseUrl/api/login');

    print("➡️ LOGIN REQUEST TO: $url"); // <—— TARUH DI SINI

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print("⬅️ LOGIN RESPONSE: ${response.body}"); // <—— OPSIONAL

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
  static Future<Map<String, dynamic>> getReservations(String token,
      {String? date, String? status}) async {
    String queryString = "";
    if (date != null) queryString += "date=$date&";
    if (status != null) queryString += "status=$status&";

    final url = Uri.parse("$baseUrl/api/v1/reservations?$queryString");

    try {
      final response = await http.get(
        url,
        headers: {
          ..._headers,
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load reservations (${response.statusCode})',
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
  // GET USER PROFILE
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
  static Future<Map<String, dynamic>> generateAIImage(
      String token, String prompt, int reservationId) async {
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
  static Future<Map<String, dynamic>> confirmPayment(
      String token, Map<String, dynamic> paymentData) async {
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

  // ===========================================================================
  // FINISH JOB (Mobile Staff)
  // ===========================================================================
  // ===========================================================================
  // INCREMENT GENERATE COUNT
  // ===========================================================================
  static Future<Map<String, dynamic>> incrementGenerate(
      String token, int reservationId) async {
    final url = Uri.parse(
        "$baseUrl/api/v1/reservations/$reservationId/increment-generate");

    try {
      final response = await http.post(
        url,
        headers: {
          ..._headers,
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to increment count',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> finishJob(
      String token, int reservationId) async {
    final url = Uri.parse("$baseUrl/api/v1/reservations/$reservationId/finish");

    try {
      final response = await http.post(
        url,
        headers: {
          ..._headers,
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to finish job',
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
  // TOGGLE BREAK (Mobile Staff)
  // ===========================================================================
  static Future<Map<String, dynamic>> toggleBreak(String token) async {
    final url = Uri.parse("$baseUrl/api/v1/artist/toggle-break");

    try {
      final response = await http.post(
        url,
        headers: {
          ..._headers,
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'is_on_break': data['data']['is_on_break'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to toggle break',
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
  // UPDATE RESERVATION (Add-on / Design Selection)
  // ===========================================================================
  static Future<Map<String, dynamic>> updateReservation(
      String token, int id, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/api/v1/reservations/$id");

    try {
      final response = await http.put(
        url,
        headers: {
          ..._headers,
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update reservation',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}
