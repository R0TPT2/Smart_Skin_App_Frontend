import 'package:flutter/material.dart';
import 'doctor_appointment_page.dart'; 
import 'doctor_info_screen.dart'; 
import 'doctor_homepage.dart'; 

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  int _selectedIndex = 0; 

  static final List _screens = [
    DoctorHomePage(), 
    AppointmentManagementScreen(), 
    DoctorInformationSettingsScreen(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 20, 117, 181), 
        unselectedItemColor: Colors.grey, 
        onTap: _onItemTapped, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}