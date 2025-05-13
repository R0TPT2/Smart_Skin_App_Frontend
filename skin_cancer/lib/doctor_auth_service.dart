import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class DoctorAuthService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';
  
  Future<String?> get accessToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('doctor_access_token');
  }
  
  Future<String?> get refreshToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('doctor_refresh_token');
  }
  
  Future<String?> get doctorId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('doctor_id');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await accessToken;
    if (token == null) return false;
    
    try {
      bool isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        bool refreshSuccess = await refreshAuthToken();
        return refreshSuccess;
      }
      return true;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>> login(String doctorId, String password) async {
    try {
      final url = Uri.parse('$baseUrl/authentication/doctor/login/');
      
      debugPrint('Attempting doctor login to: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'doctor_id': doctorId,
          'password': password,
        }),
      );

      debugPrint('Doctor login response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('Doctor login successful! Response data received');
        
        final String accessToken = data['access'];
        final String refreshToken = data['refresh'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('doctor_access_token', accessToken);
        await prefs.setString('doctor_refresh_token', refreshToken);
        await prefs.setString('doctor_id', doctorId);
        
        if (data['name'] != null) {
          await prefs.setString('doctor_name', data['name']);
        }
        
        debugPrint('Saved doctor auth tokens to SharedPreferences');
        return {
          'success': true,
          'name': data['name'] ?? '',
          'message': 'Login successful'
        };
      } else {
        debugPrint('Doctor login failed: ${response.body}');
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
        }
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Invalid credentials'
        };
      }
    } catch (e) {
      debugPrint('Doctor login error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }
  
  Future<bool> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('doctor_access_token');
      await prefs.remove('doctor_refresh_token');
      await prefs.remove('doctor_id');
      await prefs.remove('doctor_name');
      return true;
    } catch (e) {
      debugPrint('Doctor logout error: $e');
      return false;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await accessToken;
    if (token == null) {
      return {'Content-Type': 'application/json'};
    }
    
    try {
      bool isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        bool refreshSuccess = await refreshAuthToken();
        if (refreshSuccess) {
          final newToken = await accessToken;
          return {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
            'Accept': 'application/json',
          };
        }
      }
    } catch (e) {
      debugPrint('Token validation error in getAuthHeaders: $e');
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }
  
  Future<bool> refreshAuthToken() async {
    try {
      final rToken = await refreshToken;
      
      if (rToken == null) {
        return false;
      }
      
      final url = Uri.parse('$baseUrl/authentication/refresh/');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh': rToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String newAccessToken = data['access'];
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('doctor_access_token', newAccessToken);
        
        return true;
      } else {
        debugPrint('Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  Future<bool> testAuthentication() async {
    try {
      final token = await accessToken;
      if (token == null) return false;
      
      final url = Uri.parse('$baseUrl/authentication/jwt-test/');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Auth test error: $e');
      return false;
    }
  }
}