import 'package:flutter/material.dart';
import 'patient_info_screen_settingAppointment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dummy_data.dart'; // Import the dummy data
import 'messaging_screen.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  _AppointmentManagementScreenState createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState extends State<AppointmentManagementScreen> {
  int _selectedIndex = 0; // Index of the selected day

  // Generate today's date and the next 5 days
  List<DateTime> get _dates {
    final List<DateTime> dates = [];
    for (int i = 0; i < 6; i++) {
      dates.add(DateTime.now().add(Duration(days: i)));
    }
    return dates;
  }

  // Format date as "Month DD" (e.g., "January 01")
  String _formatDate(DateTime date) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${monthNames[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }

  // Group patients by date
  Map<String, List<Map<String, dynamic>>> get _patientsByDate {
    final Map<String, List<Map<String, dynamic>>> groupedPatients = {};
    for (var patient in appointedPatients) {
      final date = patient['dateOfResult'];
      if (!groupedPatients.containsKey(date)) {
        groupedPatients[date] = [];
      }
      groupedPatients[date]!.add(patient);
    }
    return groupedPatients;
  }

  // Get prediction color
  Color _getPredictionColor(String? prediction) {
    switch (prediction?.toLowerCase()) {
      case 'malignant':
        return Colors.red;
      case 'benign':
        return Colors.green;
      case 'undetermined':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  // Make phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = _dates[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          child: Container(
            height: 420,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assests/doctor_background.jpg'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointment \nManagement',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: 120,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for Month/Year
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(selectedDate), // Dynamic month/year
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 24),
              ],
            ),
            SizedBox(height: 16),

            // Scrollable Row of Days
            SizedBox(
              height: 80, // Fixed height for the scrollable row
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _dates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final date = entry.value;
                    final isSelected = index == _selectedIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[700] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getWeekDay(date),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Patients List for Selected Date
            Text(
              'Recently Appointed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color.fromARGB(31, 25, 118, 210),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _patientsByDate[_formatDate(_dates[_selectedIndex])] == null ||
                      _patientsByDate[_formatDate(_dates[_selectedIndex])]!.isEmpty
                  ? Center(
                      child: Text(
                        'No appointments for this date.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _patientsByDate[_formatDate(_dates[_selectedIndex])]!.length,
                      itemBuilder: (context, index) {
                        final patient =
                            _patientsByDate[_formatDate(_dates[_selectedIndex])]![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientSetAppointment(patient: patient),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: AssetImage(patient['avatar']),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              patient['name'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'AI Predictions:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getPredictionColor(patient['prediction']),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text(
                                                    '${patient['prediction']}',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Row(mainAxisAlignment: MainAxisAlignment.start, 
                                          children: [
                                            Icon(Icons.access_time_filled_sharp, color: Colors.blue[700]),
                                            SizedBox(width: 8),
                                            Text(
                                              "3:00 PM",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ]),
                                          SizedBox(width: 140),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.call, color: Colors.blue[700]),
                                            onPressed: () {
                                              _makePhoneCall(patient['phoneNumber']);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.message, color: Colors.blue[700]),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => MessagingScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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

  // Get weekday name (e.g., "Mon", "Tue")
  String _getWeekDay(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  // Get month name from month number
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}