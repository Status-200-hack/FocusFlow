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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userService = context.read<UserService>();
    final user = await userService.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    if (!mounted) return;

    if (user != null) {
      await userService.setFirstLaunchComplete();
      await context.read<TaskService>().loadTasks(user.id);
      await context.read<FocusService>().loadSessions(user.id);
      if (mounted) context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed. Please try again.')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingXl,
          child: Column(
            children: [
              const SizedBox(height: 20),
              GradientContainer(
                colors: isDark
                  ? [DarkModeColors.darkPrimary, DarkModeColors.darkTertiary]
                  : [LightModeColors.lightPrimary, LightModeColors.lightTertiary],
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  child: const Icon(Icons.person_add, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Create Account',
                style: context.textStyles.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Start your productivity journey today',
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
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.person_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                      hint: 'At least 6 characters',
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
                  text: 'Create Account',
                  icon: Icons.rocket_launch,
                  isLoading: _isLoading,
                  onPressed: _handleSignUp,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: context.textStyles.bodyMedium),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Sign In',
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
