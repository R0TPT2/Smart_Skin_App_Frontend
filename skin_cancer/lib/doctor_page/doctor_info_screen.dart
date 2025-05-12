import 'package:flutter/material.dart';
import 'package:skin_cancer/first_page.dart';

class DoctorInformationSettingsScreen extends StatefulWidget {
  const DoctorInformationSettingsScreen({super.key});

  @override
  _DoctorInformationSettingsScreenState createState() =>
      _DoctorInformationSettingsScreenState();
}

class _DoctorInformationSettingsScreenState
    extends State<DoctorInformationSettingsScreen> {
  // Dummy data for account settings
  final TextEditingController _emailController =
      TextEditingController(text: 'dr.ahmad@example.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '+1234567890');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Static Wave Background
          Positioned.fill(
            child: CustomPaint(
              painter: StaticWavePainter(),
              child: Container(),
            ),
          ),
          // Static Profile Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180, // Fixed height for the profile section
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assests/black_doctor.jpg'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Dr. Ahmad Ramadan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Non-Scrollable Content
          Positioned(
            top: 180, // Start below the profile section
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30), // Space between profile and settings
                  _buildSettingsCategories(),
                  SizedBox(height: 20),
                  _buildLogoutButton(),
                  SizedBox(height: 40), // Additional space under logout button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Settings Categories
  Widget _buildSettingsCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Category
        Container(
          width: double.infinity, // Stretch to full width
          decoration: BoxDecoration(
            color: Colors.blue[700], // Dark blue background
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        _buildSettingItem(Icons.settings, 'Account settings', onTap: () {
          _showAccountSettingsBottomSheet(context);
        }),
        SizedBox(height: 20),

        // Career Category
        Container(
          width: double.infinity, // Stretch to full width
          decoration: BoxDecoration(
            color: Colors.blue[700], // Dark blue background
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Career',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        _buildSettingItem(Icons.school, 'Education', onTap: () {
          _showEducationBottomSheet(context);
        }),
        _buildSettingItem(Icons.work, 'Experience', onTap: () {
          _showExperienceBottomSheet(context);
        }),
        SizedBox(height: 20),

        // Clinic Category
        Container(
          width: double.infinity, // Stretch to full width
          decoration: BoxDecoration(
            color: Colors.blue[700], // Dark blue background
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinic',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        _buildSettingItem(Icons.location_on, 'Clinic Location & Time', onTap: () {
          _showClinicLocationAndTimeBottomSheet(context);
        }),
      ],
    );
  }

  // Setting Item
  Widget _buildSettingItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Logout Button
  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (context) => FirstPage()),
          );},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Log Out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Show Account Settings Bottom Sheet
  void _showAccountSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              _buildEditableField('Email', Icons.email, _emailController),
              SizedBox(height: 16),
              _buildNonEditableField('Gender', Icons.person, 'Male'),
              SizedBox(height: 16),
              _buildNonEditableField('Date of Birth', Icons.calendar_today, '01 Jan 1980'),
              SizedBox(height: 16),
              _buildEditableField('Phone Number', Icons.phone, _phoneController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Save changes logic here
                    print('Email: ${_emailController.text}');
                    print('Phone: ${_phoneController.text}');
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Circular button
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Space at the bottom of the bottom sheet
            ],
          ),
        );
      },
    );
  }

  // Show Education Bottom Sheet
  void _showEducationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Education',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              _buildNonEditableField('University Degree', Icons.school, 'MBBS, XYZ University'),
              SizedBox(height: 16),
              _buildNonEditableField('Year of Graduation', Icons.calendar_today, '2005'),
              SizedBox(height: 20), // Space at the bottom of the bottom sheet
            ],
          ),
        );
      },
    );
  }

  // Show Experience Bottom Sheet
  void _showExperienceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              _buildNonEditableField('Specialization', Icons.medical_services, 'Cardiology'),
              SizedBox(height: 16),
              _buildNonEditableField('Years of Experience', Icons.timelapse, '15 years'),
              SizedBox(height: 20), // Space at the bottom of the bottom sheet
            ],
          ),
        );
      },
    );
  }

  // Show Clinic Location and Time Bottom Sheet
  void _showClinicLocationAndTimeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinic Location & Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              _buildEditableField('Clinic Address', Icons.location_on, TextEditingController(text: '123 Health St, City')),
              SizedBox(height: 16),
              _buildEditableField('Working Hours', Icons.access_time, TextEditingController(text: '9 AM - 5 PM')),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Save changes logic here
                    print('Clinic location and time updated');
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Circular button
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Space at the bottom of the bottom sheet
            ],
          ),
        );
      },
    );
  }

  // Editable Field
  Widget _buildEditableField(String label, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(icon),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }

  // Non-Editable Field
  Widget _buildNonEditableField(String label, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Painter for Static Waves
class StaticWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    paint.color = Colors.blue[700]!;
    Path path = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.3, size.width, size.height * 0.25)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}