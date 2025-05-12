import 'package:flutter/material.dart';
import 'first_page.dart';
void main() {
  runApp(const SkinCancerApp());
}

class SkinCancerApp extends StatelessWidget {
  const SkinCancerApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstPage()
    );
  }
}

