import 'package:flutter/material.dart';
import 'package:luxe_nail/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luxe Nail',
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Poppins'),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
