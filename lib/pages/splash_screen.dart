import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );

    scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );

    animationController.forward();

    // Open Login Page after 3 seconds
    Timer(
      const Duration(seconds: 3),
          () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1565C0),
              Color(0xFF00897B),
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: FadeTransition(
            opacity: fadeAnimation,

            child: ScaleTransition(
              scale: scaleAnimation,

              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  // ==========================
                  // LOGO
                  // ==========================

                  Container(
                    width: 150,
                    height: 150,

                    padding:
                    const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(35),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.15),

                          blurRadius: 30,

                          offset:
                          const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Image.asset(
                      'assets/images/civic_logo.png',

                      fit: BoxFit.contain,

                      errorBuilder:
                          (context, error, stackTrace) {
                        return const Icon(
                          Icons.location_city_rounded,
                          size: 70,
                          color: Color(0xFF1565C0),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==========================
                  // APP NAME
                  // ==========================

                  const Text(
                    'SMART CIVIC',

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 30,

                      fontWeight:
                      FontWeight.w800,

                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Smart Civic Issue Reporting',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white70,

                      fontSize: 15,

                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ==========================
                  // LOADING
                  // ==========================

                  const SizedBox(
                    width: 28,
                    height: 28,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.5,

                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
