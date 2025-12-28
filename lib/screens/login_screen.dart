import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/services/task_service.dart';
import 'package:focusflow/services/focus_service.dart';
import 'package:focusflow/widgets/gradient_container.dart';
import 'package:focusflow/widgets/custom_button.dart';
import 'package:focusflow/widgets/custom_input.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingXl,
          child: Column(
            children: [
              const SizedBox(height: 40),
              GradientContainer(
                colors: isDark
                  ? [DarkModeColors.darkPrimary, DarkModeColors.darkSecondary]
                  : [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  child: const Icon(Icons.lock_person, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome Back',
                style: context.textStyles.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your journey',
                style: context.textStyles.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomInput(
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
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Sign In',
                  icon: Icons.login,
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Skip for now',
                  isOutlined: true,
                  onPressed: _handleSkip,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: context.textStyles.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => context.push('/signup'),
                    child: Text(
                      'Sign Up',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
