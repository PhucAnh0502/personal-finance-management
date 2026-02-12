import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/presentation/features/auth/login_screen.dart';
import 'package:pmf_app/presentation/features/auth/register_screen.dart';
import 'package:pmf_app/presentation/features/auth/forgot_password_screen.dart';
import 'package:pmf_app/presentation/features/auth/reset_password_screen.dart';
import 'package:pmf_app/presentation/features/setup/setup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:pmf_app/data/repositories/auth_repository.dart';
import 'package:pmf_app/data/repositories/setup_repository.dart';
import 'package:pmf_app/data/repositories/budget_repository.dart';
import 'package:pmf_app/data/repositories/transaction_repository.dart';
import 'package:pmf_app/data/repositories/user_repository.dart';
import 'package:pmf_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:pmf_app/bloc/setup_bloc/setup_bloc.dart';
import 'package:pmf_app/bloc/budget_bloc/budget_bloc.dart';
import 'package:pmf_app/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:pmf_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:pmf_app/presentation/features/budget/budget_screen.dart';
import 'package:pmf_app/presentation/features/home/main_home_screen.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri?>? _linkSubscription;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleIncomingUri(initialUri);
      }
    } catch (_) {}

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingUri(uri);
    });
  }

  void _handleIncomingUri(Uri uri) {
    final params = _extractParams(uri);
    final type = params['type'];
    final accessToken = params['access_token'];
    final refreshToken = params['refresh_token'];
    if (type == 'recovery' && accessToken != null && refreshToken != null) {
      _navigatorKey.currentState?.pushNamed(
        '/reset-password',
        arguments: ResetPasswordArgs(accessToken: accessToken, refreshToken: refreshToken),
      );
    }
  }

  Map<String, String> _extractParams(Uri uri) {
    final params = <String, String>{};
    params.addAll(uri.queryParameters);
    if (uri.fragment.isNotEmpty) {
      try {
        params.addAll(Uri.splitQueryString(uri.fragment));
      } catch (_) {}
    }
    return params;
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => SetupRepository()),
        RepositoryProvider(create: (context) => BudgetRepository()),
        RepositoryProvider(create: (context) => TransactionRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>())..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => SetupBloc(setupRepository: context.read<SetupRepository>()),
          ),
          BlocProvider(
            create: (context) => BudgetBloc(budgetRepository: context.read<BudgetRepository>()),
          ),
          BlocProvider(
            create: (context) => TransactionBloc(transactionRepository: context.read<TransactionRepository>()),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(userRepository: context.read<UserRepository>()),
          ),
        ],
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'MoneyFlow',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryEmerald,
              brightness: Brightness.light,
              primary: AppColors.primaryEmerald,
              secondary: AppColors.secondaryEmerald,
              background: AppColors.background,
              surface: AppColors.surface,
              error: AppColors.error,
            ),
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryEmerald,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: AppColors.textPrimary,
                displayColor: AppColors.textPrimary,
              ),
            ),
          ),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/forgot-password': (_) => const ForgotPasswordScreen(),
            '/reset-password': (_) => const ResetPasswordScreen(),
            '/setup': (_) => const SetupScreen(),
            '/budget': (_) => const BudgetScreen(),
            '/home': (_) => const MainHomeScreen(),
          },
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                if (state.hasFinishedSetup) {
                  return const MainHomeScreen();
                } else {
                  return const SetupScreen();
                }
              }
              if (state is Unauthenticated || state is AuthFailure) {
                return const LoginScreen();
              }
              return const Scaffold(
                backgroundColor: AppColors.navyDark,
                body: Center(child: CircularProgressIndicator(color: AppColors.primaryEmerald)),
              );
            },
          )
        ),
      ),
    );
  }
}
