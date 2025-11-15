import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Navigate to login screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFFFFECEF)),
            child: Stack(
              children: [
                // Background with opacity
                Positioned(
                  left: 0,
                  top: 0,
                  child: Opacity(
                    opacity: 0.10 * _animation.value,
                    child: Container(
                      width: 412,
                      height: 917,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage("https://placehold.co/412x917"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),

                // Animated elements from your designs
                Positioned(
                  left: 156,
                  top: 490 * _animation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: ShapeDecoration(
                      color: const Color(0x00451A2B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 156,
                  top: 409 * _animation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: ShapeDecoration(
                      color: const Color(
                        0xFF451A2B,
                      ).withOpacity(_animation.value),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),

                // Main title with fade-in effect
                Positioned(
                  left: 55,
                  top: 435,
                  child: Opacity(
                    opacity: _animation.value,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'LUXE NAIL',
                            style: TextStyle(
                              color: Color(0xFF975B73),
                              fontSize: 42,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
