import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/widgets/gradient_container.dart';
import 'package:focusflow/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.task_alt,
      title: 'Organize Your Tasks',
      description: 'Keep track of everything you need to do with a beautiful, intuitive task manager',
      gradient: [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
    ),
    _OnboardingPage(
      icon: Icons.schedule,
      title: 'Stay Focused',
      description: 'Use the Pomodoro timer to maintain deep focus and boost your productivity',
      gradient: [LightModeColors.lightSecondary, LightModeColors.lightTertiary],
    ),
    _OnboardingPage(
      icon: Icons.emoji_events,
      title: 'Achieve Your Goals',
      description: 'Track your progress and celebrate your wins as you complete tasks every day',
      gradient: [LightModeColors.lightTertiary, LightModeColors.lightPrimary],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) => _pages[index],
            ),
          ),
          Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: CustomButton(
                          text: 'Back',
                          isOutlined: true,
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: _currentPage > 0 ? 1 : 1,
                      child: CustomButton(
                        text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        icon: _currentPage == _pages.length - 1 ? Icons.rocket_launch : Icons.arrow_forward,
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            context.go('/login');
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: AppSpacing.paddingXl,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GradientContainer(
          colors: gradient,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Icon(icon, size: 80, color: Colors.white),
          ),
        ),
        const SizedBox(height: 48),
        Text(
          title,
          style: context.textStyles.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: context.textStyles.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
