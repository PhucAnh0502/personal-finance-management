import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/presentation/shared/neumorphic_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.expense,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryEmerald,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          } else if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: Colors.white.withOpacity(0.82),
                          border: Border.all(color: Colors.white.withOpacity(0.7)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Create your account',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Use your email to get started',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            NeumorphicContainer(
                              child: TextField(
                                controller: _emailController,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: TextStyle(color: AppColors.textSecondary),
                                  prefixIcon: Icon(Icons.email, color: AppColors.textPrimary),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            NeumorphicContainer(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: AppColors.textSecondary),
                                  prefixIcon: Icon(Icons.lock, color: AppColors.textPrimary),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
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
                                          context.read<AuthBloc>().add(
                                                SignUpSubmitted(
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
                                              'Create account',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Back to login',
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
          );
        },
      ),
    );
  }
}
