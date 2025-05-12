import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PatientSignupPage extends StatefulWidget {
  const PatientSignupPage({super.key});

  @override
  State<PatientSignupPage> createState() => _PatientSignupPageState();
}

class _PatientSignupPageState extends State<PatientSignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalIdController = TextEditingController();
  
  String selectedGender = 'Male';
  final genderOptions = ['Male', 'Female', 'Other'];

  bool isPasswordVisible = false;
  bool isLoading = false;

  bool isValidEmail(String email) {
    final allowedDomains = ['gmail.com', 'yahoo.com', 'outlook.com'];
    final emailParts = email.split('@');
    return emailParts.length == 2 && allowedDomains.contains(emailParts[1]);
  }

  bool isValidPassword(String password) {
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    final hasMinLength = password.length >= 8;
    return hasUppercase && hasLowercase && hasNumber && hasSpecialChar && hasMinLength;
  }

  Future<void> _registerUser() async {
    setState(() => isLoading = true);
    try {
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/authentication/patient/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'national_id': nationalIdController.text,
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'phone': phoneController.text,
          'gender': selectedGender,

          'current_medical_conditions': ['None'],
          'allergies': ['None'],
          'past_surgeries': ['None'],
          'family_medical_history': ['None'],
          'current_medications': ['None'],
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.body}')),
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
                  'Create Account',
                  style: GoogleFonts.dmSerifText(
                    color: Color.fromARGB(255, 20, 117, 181),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 9),
                Image.asset(
                  'assests/Mobile login-bro.png',
                  height: 122,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Full Name Field
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
                          keyboardType: TextInputType.name,
                          cursorColor: Colors.black,
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.grey,
                            ),
                            hintText: 'Full Name',
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Gender Dropdown
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
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedGender,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                            style: TextStyle(color: Colors.black),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedGender = newValue!;
                              });
                            },
                            items: genderOptions.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      value == 'Male' ? Icons.male : value == 'Female' ? Icons.female : Icons.person,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 10),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email Field
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
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.black,
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                            ),
                            hintText: 'Email Address',
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Password Field
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
                          textInputAction: TextInputAction.next,
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
                      const SizedBox(height: 20),
                      // Phone Number Field
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
                          keyboardType: TextInputType.phone,
                          cursorColor: Colors.black,
                          controller: phoneController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.phone,
                              color: Colors.grey,
                            ),
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // National ID Field
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
                          textInputAction: TextInputAction.done,
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
                      // Signup Button
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () {
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Name is required')),
                              );
                            } else if (emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Email is required')),
                              );
                            } else if (!isValidEmail(emailController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Email must end with gmail.com, yahoo.com, or outlook.com')),
                              );
                            } else if (passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Password is required')),
                              );
                            } else if (!isValidPassword(passwordController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character')),
                              );
                            } else if (phoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Phone number is required')),
                              );
                            } else if (nationalIdController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('National ID is required')),
                              );
                            } else {
                              _registerUser();
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
                            'Signup',
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
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Already have an account? Login',
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