import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {

  final emailOrPhoneController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  int currentStep = 0;

  
  final String oldPassword = 'OldPassword123!';

  
  bool isValidPassword(String password) {
    
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    final hasMinLength = password.length >= 8;

    
    return hasUppercase && hasLowercase && hasNumber && hasSpecialChar && hasMinLength;
  }

  
  void sendCode() {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code sent to ${emailOrPhoneController.text}')),
    );

    
    setState(() {
      currentStep = 1;
    });
  }

  
  void verifyCode() {
    if (codeController.text == '123456') { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code verified successfully')),
      );

      
      setState(() {
        currentStep = 2;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid code. Please try again.')),
      );
    }
  }

  
  void resetPassword() {
    if (newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New password is required')),
      );
    } else if (!isValidPassword(newPasswordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character')),
      );
    } else if (newPasswordController.text == oldPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New password cannot be the same as the old password')),
      );
    } else if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset successfully')),
      );

      Navigator.pop(context);
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
                  'Reset Password',
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
                      // Step 1: Send Code
                      if (currentStep == 0) ...[
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
                            controller: emailOrPhoneController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey,
                              ),
                              hintText: 'Email or Phone Number',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: ElevatedButton(
                            onPressed: sendCode,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Color.fromARGB(255, 20, 117, 181),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Send Code',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],

                      
                      if (currentStep == 1) ...[
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
                            controller: codeController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.code,
                                color: Colors.grey,
                              ),
                              hintText: 'Enter Code',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: ElevatedButton(
                            onPressed: verifyCode,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Color.fromARGB(255, 20, 117, 181),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Verify Code',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],

                      
                      if (currentStep == 2) ...[
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
                            obscureText: !isNewPasswordVisible,
                            cursorColor: Colors.black,
                            controller: newPasswordController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isNewPasswordVisible = !isNewPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                              hintText: 'New Password',
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
                            obscureText: !isConfirmPasswordVisible,
                            cursorColor: Colors.black,
                            controller: confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isConfirmPasswordVisible = !isConfirmPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: ElevatedButton(
                            onPressed: resetPassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Color.fromARGB(255, 20, 117, 181),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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