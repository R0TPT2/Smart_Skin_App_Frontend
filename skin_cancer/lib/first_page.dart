import 'package:flutter/material.dart';
import 'doctor_login.dart';
import 'patient_login_page.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assests/f_image.png',
                height: 400,
                width: 400,
              ),
              Text(
                'Welcome to \n Skin Cancer App',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifText(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
              ),
              const SizedBox(height: 40),
              Container(
                margin: EdgeInsets.all(22),
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PatientLoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.person, 
                            size: 24,
                            color: Color.fromARGB(255, 36, 117, 210),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Patient',
                            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 36, 117, 210)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DoctorLoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.medical_services, 
                            size: 24,
                            color: Color.fromARGB(255, 36, 117, 210),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Doctor',
                            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 36, 117, 210)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}