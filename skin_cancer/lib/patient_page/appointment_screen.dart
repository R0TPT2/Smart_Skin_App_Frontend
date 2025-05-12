import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> allAppointments = [
    {
      'name': 'William Andrew',
      'date': '22 Feb 2024',
      'time': '09:45 PM',
      'status': 'At Clinic',
      'ticketId': '145875AB',
      'doctorImage': 'assests/black_doctor.jpg',
      'completed': false, 
      'confirmed': false, 
    },
    {
      'name': 'Saniya Lieders',
      'date': '20 Feb 2024',
      'time': '05:30 PM',
      'status': 'Completed',
      'ticketId': '145876AB',
      'doctorImage': 'assests/black_doctor.jpg',
      'completed': true, 
      'confirmed': true, 
    },
  ];

  void _confirmAppointment(int index) {
    setState(() {
      allAppointments[index]['confirmed'] = true; 
    });
  }

  void _cancelAppointment(int index) {
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
            onPressed: () {
              setState(() {
                allAppointments.removeAt(index); 
              });
              Navigator.pop(context); 
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
                  _buildTabButton(1, 'Complete Appointment'),
                ],
              ),
            ),

            
            Expanded(
              child: ListView.builder(
                itemCount: allAppointments.where((apt) => apt['completed'] == (_selectedTabIndex == 1)).length,
                itemBuilder: (context, index) {
                  final appointmentIndex = allAppointments.indexWhere((apt) => 
                      apt['completed'] == (_selectedTabIndex == 1));
                  final appointment = allAppointments[appointmentIndex];

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
                              Text(appointment['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Row(
                                children: [
                                  Icon(Icons.confirmation_number,
                                      color: Colors.blue[700], size: 20),
                                  SizedBox(width: 8),
                                  Text(appointment['ticketId'],
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
                                child: Image.asset(
                                  appointment['doctorImage'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(Icons.calendar_today,
                                        'Date: ${appointment['date']}'),
                                    SizedBox(height: 5),
                                    _buildInfoRow(Icons.access_time,
                                        'Time: ${appointment['time']}'),
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
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                appointment['status'],
                                style: TextStyle(
                                    color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                          if (!appointment['completed']) ...[
                            Divider(thickness: 1.5, color: Colors.grey[400]),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!appointment['confirmed'])
                                  ElevatedButton(
                                    onPressed: () => _confirmAppointment(appointmentIndex),
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
                                  onPressed: () => _cancelAppointment(appointmentIndex),
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
                },
              ),
            ),
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