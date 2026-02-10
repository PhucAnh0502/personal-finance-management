import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:pmf_app/presentation/shared/neumorphic_container.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
} 

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AnimationController? _entranceController;
  AnimationController? _ambientController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _fadeAnimation;
  Animation<double>? _logoScaleAnimation;
  Animation<Alignment>? _bgAlignmentAnimation;
  Animation<double>? _glowAnimation;
  Animation<double>? _floatAnimation;

  void _ensureControllers() {
    if (_ambientController != null && _entranceController != null) {
      return;
    }

    _entranceController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController!, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entranceController!, curve: Curves.easeOut));
    _logoScaleAnimation = Tween<double>(begin: 0.95, end: 1.0)
        .animate(CurvedAnimation(parent: _entranceController!, curve: Curves.easeOutBack));

    _ambientController ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _bgAlignmentAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _ambientController!, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.55)
        .animate(CurvedAnimation(parent: _ambientController!, curve: Curves.easeInOut));
    _floatAnimation = Tween<double>(begin: -14, end: 14)
        .animate(CurvedAnimation(parent: _ambientController!, curve: Curves.easeInOut));

    _entranceController!.forward();
  }

  @override
  void initState() {
    super.initState();
    _ensureControllers();
  }

  @override
  void reassemble() {
    super.reassemble();
    _ensureControllers();
  }

  @override
  void dispose() {
    _entranceController?.dispose();
    _ambientController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureControllers();
    final ambientController = _ambientController;
    if (ambientController == null || _bgAlignmentAnimation == null || _floatAnimation == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if(state is AuthFailure){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.expense,
                behavior: SnackBarBehavior.floating,
              )
            );
          } else if (state is AuthMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryEmerald,
                behavior: SnackBarBehavior.floating,
              )
            );
          } else if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        },
        builder: (context, state) {
          return AnimatedBuilder(
            animation: ambientController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _bgAlignmentAnimation!.value,
                    end: Alignment.bottomRight,
                    colors: AppColors.backgroundGradient.colors,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -120,
                      right: -80,
                      child: Transform.translate(
                        offset: Offset(0, _floatAnimation!.value),
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.mint.withOpacity(0.45),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -140,
                      left: -60,
                      child: Transform.translate(
                        offset: Offset(0, -_floatAnimation!.value),
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondaryEmerald.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28.0),
                        child: FadeTransition(
                          opacity: _fadeAnimation!,
                          child: SlideTransition(
                            position: _slideAnimation!,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                child: Container(
                                  padding: const EdgeInsets.all(24.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: Colors.white.withOpacity(0.75),
                                    border: Border.all(color: Colors.white.withOpacity(0.7)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF5A6B90).withOpacity(0.15),
                                        blurRadius: 30,
                                        offset: const Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ScaleTransition(
                                        scale: _logoScaleAnimation!,
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          width: 220,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      NeumorphicContainer(
                                        child: TextField(
                                          controller: _emailController,
                                          style: const TextStyle(color: AppColors.textPrimary),
                                          decoration: const InputDecoration(
                                            hintText: "Email",
                                            hintStyle: TextStyle(color: AppColors.textSecondary),
                                            prefixIcon: Icon(Icons.email, color: AppColors.textPrimary),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      NeumorphicContainer(
                                        child: TextField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          style: const TextStyle(color: AppColors.textPrimary),
                                          decoration: const InputDecoration(
                                            hintText: "Password",
                                            hintStyle: TextStyle(color: AppColors.textSecondary),
                                            prefixIcon: Icon(Icons.lock, color: AppColors.textPrimary),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 28),

                                      NeumorphicContainer(
                                        isConvex: true,
                                        padding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(20),
                                        child: AnimatedBuilder(
                                          animation: _glowAnimation!,
                                          builder: (context, child) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primaryEmerald
                                                        .withOpacity(_glowAnimation!.value),
                                                    blurRadius: 24,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: child,
                                            );
                                          },
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: state is! AuthLoading
                                                  ? () {
                                                      context.read<AuthBloc>().add(
                                                        LoginSubmitted(
                                                          _emailController.text,
                                                          _passwordController.text,
                                                        ),
                                                      );
                                                    }
                                                  : null,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  color: AppColors.primaryEmerald,
                                                ),
                                                child: Center(
                                                  child: state is AuthLoading
                                                      ? const CircularProgressIndicator(color: Colors.white)
                                                      : const Text(
                                                          'Login',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      NeumorphicContainer(
                                        isConvex: true,
                                        padding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(20),
                                            onTap: state is! AuthLoading
                                                ? () {
                                                    context.read<AuthBloc>().add(GoogleLoginPressed());
                                                  }
                                                : null,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                color: Colors.white,
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Image.asset('assets/images/google_logo.png', height: 30),
                                                    const SizedBox(width: 10),
                                                    const Text(
                                                      "Login with Google",
                                                      style: TextStyle(
                                                        color: AppColors.textPrimary,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/register');
                                        },
                                        child: const Text(
                                          "Don't have an account? Register now",
                                          style: TextStyle(color: AppColors.textPrimary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/forgot-password');
                                        },
                                        child: const Text(
                                          "Forgot Password?",
                                          style: TextStyle(color: AppColors.textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      )
    );
  }
}
