import 'package:flutter/material.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/core/theme/app_theme.dart';

class IntroScreen extends StatefulWidget{
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  @override
  void dispose() {
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
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(context),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 260,
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