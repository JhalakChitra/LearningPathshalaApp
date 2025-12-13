import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding/onboardingscreen.dart';
import 'home/homescreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Apni Pathshala", style: TextStyle(fontSize: 24))),
    );
  }
}
