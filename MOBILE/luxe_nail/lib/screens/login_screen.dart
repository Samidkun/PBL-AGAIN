import 'package:flutter/material.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  "assets/images/Splas1-HAND.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: height * 0.32),
                  const SizedBox(height: 15),
                  const Column(
                    children: [
                      Text(
                        "Hello Nailist!",
                        style: TextStyle(
                          fontSize: 36,
                          fontFamily: "Georgia",
                          color: Color(0xFF451A2B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Ready to dive in?\nLog in to your account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Poppins",
                          color: Color(0xFF451A2B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF451A2B),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(90),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "LUXE NAIL",
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: "Georgia",
                            color: Color(0xFFFFEAEB),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFFEAEB),
                            hintText: "Username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFFEAEB),
                            hintText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF909D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashboardScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Poppins",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: height * 0.32,
                width: width,
                child: Image.asset(
                  "assets/images/login-Vektor Tangan.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
