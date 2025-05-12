import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl_med = '${dotenv.env['API_URL'] ?? ''}/medical_images';
  
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token'); 
  }
  
  Future<String> uploadImage(File imageFile) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      final uri = Uri.parse('$baseUrl_med/upload/'); 
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token'; 
      
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
      
      final response = await request.send();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        return jsonData['image_path'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
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
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      final String finalDiagnosisResult = diagnosisResult ?? 
        (primaryScore > 0.526 ? 'MALIGNANT' : 'BENIGN');
      
      final response = await http.post(
        Uri.parse('$baseUrl_med/medical-images/create/'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
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
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to save medical image: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Save medical image error: $e');
    }
  }
  
  Future<String?> getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('patient_id');
  }
}