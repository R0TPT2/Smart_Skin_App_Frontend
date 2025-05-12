import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';
  
  // JWT token getters
  Future<String?> get accessToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
  
  Future<String?> get refreshToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }
  
  Future<String?> get patientId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('patient_id');
  }
  
  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    final token = await accessToken;
    return token != null;
  }
  
  // Login function
  Future<bool> login(String nationalId, String password) async {
    try {
      final url = Uri.parse('$baseUrl/authentication/patient/login/');
      
      debugPrint('Attempting login to: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'national_id': nationalId,
          'password': password,
        }),
      );

      debugPrint('Login response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('Login successful! Response data received');
        
        final String accessToken = data['access'];
        final String refreshToken = data['refresh'];

        // Store all needed authentication info
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setString('patient_id', nationalId);
        
        // Try to store patient name if available
        if (data['name'] != null) {
          await prefs.setString('patient_name', data['name']);
        }
        
        debugPrint('Saved auth tokens to SharedPreferences');
        return true;
      } else {
        debugPrint('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }
  
  // Logout function
  Future<bool> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('patient_id');
      await prefs.remove('patient_name');
      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }
  
  // Auth header generator
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await accessToken;
    if (token == null) {
      return {'Content-Type': 'application/json'};
    }
    
    // Note: Your backend accepts either format based on the code
    // 1. With Bearer prefix: 'Bearer $token'
    // 2. Without prefix: just the token
    // I'm using the Bearer format as it's more standard
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }
  
  // Token refresh function
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
        await prefs.setString('access_token', newAccessToken);
        
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
}