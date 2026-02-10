import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/presentation/shared/neumorphic_container.dart';

class ResetPasswordArgs {
  final String accessToken;
  final String refreshToken;

  const ResetPasswordArgs({
    required this.accessToken,
    required this.refreshToken,
  });
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! ResetPasswordArgs) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reset password')),
        body: const Center(
          child: Text('Missing recovery data. Please open the link again.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
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
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
                            'Set a new password',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your new password must be different from the old one',
                            style: TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          NeumorphicContainer(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'New password',
                                hintStyle: const TextStyle(color: AppColors.textSecondary),
                                prefixIcon: const Icon(Icons.lock, color: AppColors.textPrimary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  }),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          NeumorphicContainer(
                            child: TextField(
                              controller: _confirmController,
                              obscureText: _obscureConfirm,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Confirm password',
                                hintStyle: const TextStyle(color: AppColors.textSecondary),
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textPrimary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(() {
                                    _obscureConfirm = !_obscureConfirm;
                                  }),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                        final password = _passwordController.text.trim();
                                        final confirm = _confirmController.text.trim();
                                        if (password.isEmpty || confirm.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please fill in all fields.'),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        }
                                        if (password != confirm) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Passwords do not match.'),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        }
                                        context.read<AuthBloc>().add(
                                              ResetPasswordSubmitted(
                                                args.accessToken,
                                                args.refreshToken,
                                                password,
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
                                            'Update password',
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
                        ],
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
