import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:pmf_app/presentation/shared/neumorphic_container.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
} 

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            final targetRoute = state.hasFinishedSetup ? '/home' : '/setup';
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: AppTheme.getBackgroundGradient(context),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -80,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mint.withOpacity(0.45),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -140,
                  left: -60,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryEmerald.withOpacity(0.6),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: AppTheme.getModalBackgroundColor(context).withOpacity(0.9),
                            border: Border.all(
                              color: AppTheme.getSurfaceColor(context).withOpacity(0.6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                width: 220,
                              ),
                              const SizedBox(height: 20),
                              NeumorphicContainer(
                                child: TextField(
                                  controller: _emailController,
                                  style: TextStyle(
                                    color: AppTheme.getTextPrimaryColor(context),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Email",
                                    hintStyle: TextStyle(
                                      color: AppTheme.getSubtitleStyle(context).color,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: AppTheme.getTextPrimaryColor(context),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              NeumorphicContainer(
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  style: TextStyle(
                                    color: AppTheme.getTextPrimaryColor(context),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                      color: AppTheme.getSubtitleStyle(context).color,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: AppTheme.getTextPrimaryColor(context),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
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
                                                "Login",
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
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: AppTheme.getSubtitleStyle(context).color,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/register',
                                ),
                                child: Text(
                                  'Create an account',
                                  style: TextStyle(
                                    color: AppTheme.getSubtitleStyle(context).color,
                                  ),
                                ),
                              ),
                            ],
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
      )
    );
  }
}
