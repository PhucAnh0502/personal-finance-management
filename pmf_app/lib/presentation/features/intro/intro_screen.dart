import 'package:flutter/material.dart';
import 'package:pmf_app/core/constants/app_colors.dart';

class IntroScreen extends StatefulWidget{
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.02)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _navigateToNext();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3), (){});
    if(!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 260,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: AppColors.primaryEmerald,
              )
            ],
          ),
        ),
      ),
    );
  }
}