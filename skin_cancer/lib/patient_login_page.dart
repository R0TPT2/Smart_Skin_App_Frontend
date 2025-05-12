import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_signup_page.dart';
import 'reset_password.dart';
import 'patient_page/patient_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PatientLoginPage extends StatefulWidget {
  const PatientLoginPage({super.key});

  @override
  State<PatientLoginPage> createState() => _PatientLoginPageState();
}

class _PatientLoginPageState extends State<PatientLoginPage> {
  final passwordController = TextEditingController();
  final nationalIdController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = Uri.parse('$baseUrl/authentication/patient/login/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'national_id': nationalIdController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String accessToken = data['access'];
        final String refreshToken = data['refresh'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        String patientName = data['name'] ?? 'DEFAULT_NAME';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientPage(
              patientName: patientName,
              patientImage: 'assests/Default.jpg',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to server: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.dmSerifText(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  "Let's Login To Use Our App",
                  style: GoogleFonts.dmSerifText(fontSize: 22),
                ),
                Image.asset(
                  'assests/Mobile login-bro.png',
                  height: 122,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(30, 3, 20, 0),
                        margin: EdgeInsets.only(left: 10, right: 10),
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          cursorColor: Colors.black,
                          controller: nationalIdController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.credit_card,
                              color: Colors.grey,
                            ),
                            hintText: 'National ID',
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(30, 3, 20, 0),
                        margin: EdgeInsets.only(left: 10, right: 10),
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          obscureText: !isPasswordVisible,
                          cursorColor: Colors.black,
                          controller: passwordController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () {
                            if (nationalIdController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('National ID is required')),
                              );
                            } else if (passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Password is required')),
                              );
                            } else {
                              login();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Color.fromARGB(255, 20, 117, 181),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PatientSignupPage()),
                          );
                        },
                        child: const Text(
                          'Don\'t have an account? Create Now',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}