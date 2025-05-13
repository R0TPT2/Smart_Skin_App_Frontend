import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../appointment_service.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  List<Appointment> _appointments = [];
  final AppointmentService _appointmentService = AppointmentService();
  
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }
  
  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final appointments = await _appointmentService.getAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load appointments: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _confirmAppointment(String appointmentId) async {
    try {
      await _appointmentService.confirmAppointment(appointmentId);
      _showSuccessSnackBar('Appointment confirmed successfully');
      _loadAppointments(); // Refresh the list after confirmation
    } catch (e) {
      _showErrorSnackBar('Failed to confirm appointment: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelAppointment(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Cancellation", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700])),
        content: Text(
            "If you cancel, it will be removed, and you'll have to wait for another appointment."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Return Back", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _appointmentService.cancelAppointment(appointmentId);
                _showSuccessSnackBar('Appointment cancelled successfully');
                _loadAppointments(); // Refresh the list after cancellation
              } catch (e) {
                _showErrorSnackBar('Failed to cancel appointment: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter appointments based on selected tab
    List<Appointment> filteredAppointments = _appointments.where((apt) {
      if (_selectedTabIndex == 0) {
        // Pending tab: show appointments with status PENDING or CONFIRMED but not CANCELLED
        return apt.status != 'CANCELLED';
      } else {
        // Completed tab: show CANCELLED appointments
        return apt.status == 'CANCELLED';
      }
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          title: Center(
            child: Text(
              'My Appointment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
          ),
          backgroundColor: Colors.blue[700],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
          ),
          automaticallyImplyLeading: false,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildTabButton(0, 'Pending Appointment'),
                  SizedBox(width: 10),
                  _buildTabButton(1, 'Cancelled Appointment'),
                ],
              ),
            ),

            // Pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAppointments,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredAppointments.isEmpty
                        ? Center(
                            child: Text(
                              _selectedTabIndex == 0
                                  ? 'No pending appointments'
                                  : 'No cancelled appointments',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = filteredAppointments[index];
                              return _buildAppointmentCard(appointment);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    // Format date and time
    final dateFormatter = DateFormat('dd MMM yyyy');
    final timeFormatter = DateFormat('hh:mm a');
    
    final formattedDate = dateFormatter.format(appointment.scheduledTime);
    final formattedTime = timeFormatter.format(appointment.scheduledTime);
    
    // Determine appointment status
    String statusText;
    Color statusColor;
    
    switch (appointment.status) {
      case 'CONFIRMED':
        statusText = 'Confirmed';
        statusColor = Colors.green;
        break;
      case 'CANCELLED':
        statusText = 'Cancelled';
        statusColor = Colors.red;
        break;
      default:
        statusText = 'Pending';
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Name & Appointment ID in the same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appointment.doctorName ?? 'No Doctor Assigned',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: [
                    Icon(Icons.confirmation_number,
                        color: Colors.blue[700], size: 20),
                    SizedBox(width: 8),
                    Text(appointment.id.substring(0, 8),
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.medical_services, size: 40, color: Colors.blue[700]),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.calendar_today,
                          'Date: $formattedDate'),
                      SizedBox(height: 5),
                      _buildInfoRow(Icons.access_time,
                          'Time: $formattedTime'),
                      SizedBox(height: 5),
                      _buildInfoRow(Icons.location_on,
                          'Location: ${appointment.clinicLocation}'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Only show action buttons for pending appointments
            if (appointment.status != 'CANCELLED') ...[
              Divider(thickness: 1.5, color: Colors.grey[400]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (appointment.status != 'CONFIRMED')
                    ElevatedButton(
                      onPressed: () => _confirmAppointment(appointment.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Confirm', style: TextStyle(color: Colors.white)),
                    ),
                  ElevatedButton(
                    onPressed: () => _cancelAppointment(appointment.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: _selectedTabIndex == index ? Colors.blue[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue[700]!),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: _selectedTabIndex == index ? Colors.white : Colors.blue[700],
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 20),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}