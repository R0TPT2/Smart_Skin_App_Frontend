import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';  // Import for debugPrint

class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';
  final String baseUrlMedical = '${dotenv.env['API_URL'] ?? ''}/medical_images';
  final String baseUrlTickets = '${dotenv.env['API_URL'] ?? ''}/tickets';

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      debugPrint('Token retrieved successfully: ${token.substring(0, min(10, token.length))}...');
    } else {
      debugPrint('No token found in SharedPreferences');
    }
    return token;
  }
  
  // Get both the token and the correct auth header format based on your backend
  Future<String?> _getAuthHeader() async {
    final token = await _getAuthToken();
    if (token == null) {
      return null;
    }
    // Use simple Token format instead of Bearer since your backend uses custom JWT
    return token;
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      final uri = Uri.parse('$baseUrlMedical/upload/');
      debugPrint('Uploading to: $uri');
      
      final request = http.MultipartRequest('POST', uri);
      
      // Set token without 'Bearer' prefix based on your JWT implementation
      request.headers['Authorization'] = token;
      request.headers['Accept'] = 'application/json';
      // ContentType is automatically set for multipart requests
      
      debugPrint('Request headers: ${request.headers}');
      
      final stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: basename(imageFile.path),
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
      
      debugPrint('Sending request with file: ${basename(imageFile.path)}');
      final response = await request.send();
      
      debugPrint('Response status code: ${response.statusCode}');
      final responseData = await response.stream.bytesToString();
      debugPrint('Response body: $responseData');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(responseData);
        return jsonData['image_path'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
      throw Exception('Image upload error: $e');
    }
  }

  // Rest of your methods remain the same
  Future<Map<String, dynamic>> saveMedicalImage({
    required String patientId,
    required String imagePath,
    required String? lesionType,
    required int priority,
    required double primaryScore,
    required double secondaryScore,
    String? doctorNotes,
    String? diagnosisResult,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      final String finalDiagnosisResult = diagnosisResult ??
          (primaryScore > 0.526 ? 'MALIGNANT' : 'BENIGN');
      
      debugPrint('Saving medical image to: $baseUrlMedical/medical-images/create/');
      final response = await http.post(
        Uri.parse('$baseUrlMedical/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'patient_id': patientId,
          'image_path': imagePath,
          'diagnosis_result': finalDiagnosisResult,
          'primary_ai_score': primaryScore,
          'secondary_ai_score': secondaryScore,
          'lesion_type': lesionType,
          'priority': priority,
          'doctor_notes': doctorNotes,
        }),
      );
      
      debugPrint('Save image response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to save medical image: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Save medical image error: $e');
      throw Exception('Save medical image error: $e');
    }
  }

  Future<Map<String, dynamic>> createTicket({
    required String medicalImageId,
    required Map<String, dynamic> symptomData,
    required String diagnosisResult,
    required int priority,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getString('patient_id') ?? 'unknown';
      
      final response = await http.post(
        Uri.parse('$baseUrlTickets/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'patient_id': patientId,
          'medical_image_id': medicalImageId,
          'symptom_data': symptomData,
          'diagnosis_result': diagnosisResult,
          'priority': priority,
          'status': 'pending',  
        }),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create ticket: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Create ticket error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPatientTickets() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getString('patient_id') ?? 'unknown';
      
      final response = await http.get(
        Uri.parse('$baseUrlTickets/patient/$patientId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get tickets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get tickets error: $e');
    }
  }

  Future<String?> getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('patient_id');
  }
}

// Helper function for min value
int min(int a, int b) => a < b ? a : b;