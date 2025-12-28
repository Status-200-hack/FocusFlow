import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/services/task_service.dart';
import 'package:focusflow/services/focus_service.dart';
import 'package:focusflow/widgets/glass_card.dart';
import 'package:focusflow/widgets/floating_input.dart';
import 'package:focusflow/widgets/morphing_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userService = context.read<UserService>();
    final user = await userService.login(_emailController.text, _passwordController.text);

    if (!mounted) return;

    if (user != null) {
      await userService.setFirstLaunchComplete();
      await context.read<TaskService>().loadTasks(user.id);
      await context.read<FocusService>().loadSessions(user.id);
      if (mounted) context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSkip() async {
    setState(() => _isLoading = true);

    final userService = context.read<UserService>();
    final user = await userService.skipLogin();

    if (!mounted) return;

    if (user != null) {
      await userService.setFirstLaunchComplete();
      await context.read<TaskService>().loadTasks(user.id);
      await context.read<FocusService>().loadSessions(user.id);
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    DarkModeColors.darkBackground,
                    DarkModeColors.darkSurface,
                    DarkModeColors.darkPrimary.withValues(alpha: 0.1),
                  ]
                : [
                    LightModeColors.lightPrimary.withValues(alpha: 0.1),
                    LightModeColors.lightBackground,
                    LightModeColors.lightSecondary.withValues(alpha: 0.05),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: AppSpacing.paddingXl,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Welcome text
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic)
                      .slideY(begin: -0.1, end: 0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in to continue',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                          .withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400))
                      .slideY(begin: -0.1, end: 0, delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                  const SizedBox(height: 60),
                  // Glassmorphism form card
                  GlassCard(
                    borderRadius: 28,
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FloatingInput(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'your.email@example.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email is required';
                              if (!value.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400))
                              .slideX(begin: -0.1, end: 0, delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                          const SizedBox(height: 20),
                          FloatingInput(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outlined,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Password is required';
                              if (value.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400))
                              .slideX(begin: -0.1, end: 0, delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                          const SizedBox(height: 32),
                          MorphingButton(
                            text: 'Sign In',
                            icon: Icons.arrow_forward_rounded,
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 400))
                              .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 150), duration: const Duration(milliseconds: 500))
                      .slideY(begin: 0.05, end: 0, delay: const Duration(milliseconds: 150), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),
                  // Skip button
                  TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 500), duration: const Duration(milliseconds: 400)),
                  const SizedBox(height: 32),
                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 400)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
