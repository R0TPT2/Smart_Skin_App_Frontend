import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Appointment {
  final String id;
  final String patientId;
  final String? doctorId;
  final String? doctorName;
  final String clinicLocation;
  final DateTime scheduledTime;
  final String status;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.doctorName,
    required this.clinicLocation,
    required this.scheduledTime,
    required this.status,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patient'],
      doctorId: json['doctor'],
      doctorName: json['doctor_details'] != null ? json['doctor_details']['name'] : 'No Doctor Assigned',
      clinicLocation: json['clinic_location'] ?? 'Not specified',
      scheduledTime: DateTime.parse(json['scheduled_time']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class AppointmentService {
  final AuthService _authService = AuthService();
  final String baseUrl;

  AppointmentService() : baseUrl = '${dotenv.env['API_URL'] ?? ''}/api';

  Future<List<Appointment>> getAppointments({bool upcoming = false}) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final patientId = await _authService.patientId;

      if (patientId == null) {
        throw Exception('Patient ID not found');
      }

      final url = Uri.parse('$baseUrl/appointments/by_patient/?patient_id=$patientId');
      if (upcoming) {
        url.queryParameters.addAll({'upcoming': 'true'});
      }

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Appointment.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        // Handle unauthorized error - could be expired token
        bool refreshed = await _authService.refreshAuthToken();
        if (refreshed) {
          // Retry the request after token refresh
          return getAppointments(upcoming: upcoming);
        } else {
          throw Exception('Authentication failed. Please log in again.');
        }
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting appointments: $e');
    }
  }

  Future<void> confirmAppointment(String appointmentId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('$baseUrl/appointments/$appointmentId/confirm/');

      final response = await http.post(url, headers: headers);

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          bool refreshed = await _authService.refreshAuthToken();
          if (refreshed) {
            return confirmAppointment(appointmentId);
          }
        }
        throw Exception('Failed to confirm appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error confirming appointment: $e');
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('$baseUrl/appointments/$appointmentId/cancel/');

      final response = await http.post(url, headers: headers);

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          bool refreshed = await _authService.refreshAuthToken();
          if (refreshed) {
            return cancelAppointment(appointmentId);
          }
        }
        throw Exception('Failed to cancel appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error cancelling appointment: $e');
    }
  }
}