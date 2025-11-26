import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_navigated) {
        _navigated = true;
        _goToLogin();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: w,
        height: h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFECEF), Color(0xFFFFDDE6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              SizedBox(
                width: w * 0.7,
                child: Lottie.asset(
                  'assets/lottie/manicure_treatment.json',
                  controller: _lottieController,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    _lottieController
                      ..duration = composition.duration
                      ..forward(from: 0);
                  },
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'LUXE NAIL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia',
                  color: Color(0xFF8B4B62),
                  letterSpacing: 1.6,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Manicure • Pedicure • Beauty Care',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFB47C93),
                  letterSpacing: 1.1,
                ),
              ),

              const Spacer(),

              const Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Relax. Shine. Repeat.',
                  style: TextStyle(fontSize: 11, color: Color(0xFFB8899E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
