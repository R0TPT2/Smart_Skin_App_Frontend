import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';  
import '../../auth_service.dart';  

class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';
  final String baseUrlMedical = '${dotenv.env['API_URL'] ?? ''}/medical_images';
  final String baseUrlTickets = '${dotenv.env['API_URL'] ?? ''}/tickets';
  final AuthService _authService = AuthService();  // Create AuthService instance

  // Get auth headers using the AuthService
  Future<Map<String, String>> _getAuthHeaders() async {
    return await _authService.getAuthHeaders();
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      // Get auth headers with proper JWT token
      final headers = await _getAuthHeaders();
      
      final uri = Uri.parse('$baseUrlMedical/upload/');
      debugPrint('Uploading to: $uri');
      
      final request = http.MultipartRequest('POST', uri);
      
      // Add all auth headers to the request
      headers.forEach((key, value) {
        request.headers[key] = value;
      });
      
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
      } else if (response.statusCode == 401) {
        // Handle unauthorized error - could be expired token
        bool refreshed = await _authService.refreshAuthToken();
        if (refreshed) {
          // Retry the upload after token refresh
          return uploadImage(imageFile);
        } else {
          throw Exception('Authentication failed. Please log in again.');
        }
      } else {
        throw Exception('Failed to upload image: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
      throw Exception('Image upload error: $e');
    }
  }

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
      // Get auth headers with proper JWT token
      final headers = await _getAuthHeaders();
      
      final String finalDiagnosisResult = diagnosisResult ??
          (primaryScore > 0.526 ? 'MALIGNANT' : 'BENIGN');
      
      debugPrint('Saving medical image to: $baseUrlMedical/create/');
      final response = await http.post(
        Uri.parse('$baseUrlMedical/create/'),
        headers: headers,
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
      } else if (response.statusCode == 401) {
        // Handle unauthorized error - could be expired token
        bool refreshed = await _authService.refreshAuthToken();
        if (refreshed) {
          // Retry the request after token refresh
          return saveMedicalImage(
            patientId: patientId,
            imagePath: imagePath,
            lesionType: lesionType,
            priority: priority,
            primaryScore: primaryScore,
            secondaryScore: secondaryScore,
            doctorNotes: doctorNotes,
            diagnosisResult: diagnosisResult,
          );
        } else {
          throw Exception('Authentication failed. Please log in again.');
        }
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
      // Get auth headers with proper JWT token
      final headers = await _getAuthHeaders();
      
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getString('patient_id') ?? 'unknown';
      
      final response = await http.post(
        Uri.parse('$baseUrlTickets/create/'),
        headers: headers,
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
      } else if (response.statusCode == 401) {
        // Handle unauthorized error - could be expired token
        bool refreshed = await _authService.refreshAuthToken();
        if (refreshed) {
          // Retry the request after token refresh
          return createTicket(
            medicalImageId: medicalImageId,
            symptomData: symptomData,
            diagnosisResult: diagnosisResult,
            priority: priority,
          );
        } else {
          throw Exception('Authentication failed. Please log in again.');
        }
      } else {
        throw Exception('Failed to create ticket: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Create ticket error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPatientTickets() async {
    try {
      // Get auth headers with proper JWT token
      final headers = await _getAuthHeaders();
      
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getString('patient_id') ?? 'unknown';
      
      final response = await http.get(
        Uri.parse('$baseUrlTickets/patient/$patientId/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        // Handle unauthorized error - could be expired token
        bool refreshed = await _authService.refreshAuthToken();
        if (refreshed) {
          // Retry the request after token refresh
          return getPatientTickets();
        } else {
          throw Exception('Authentication failed. Please log in again.');
        }
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