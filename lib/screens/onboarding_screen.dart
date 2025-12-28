import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _glowController;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.task_alt_rounded,
      title: 'Organize',
      subtitle: 'Everything in one place',
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    _OnboardingPageData(
      icon: Icons.timer_rounded,
      title: 'Focus',
      subtitle: 'Deep work, zero distractions',
      gradient: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
    ),
    _OnboardingPageData(
      icon: Icons.emoji_events_rounded,
      title: 'Achieve',
      subtitle: 'Your goals, your way',
      gradient: [Color(0xFFF97316), Color(0xFFEC4899)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen gradient background
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) => _OnboardingPage(
              data: _pages[index],
              pageIndex: index,
              currentPage: _currentPage,
            ),
          ),
          // Skip button (top right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Skip',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom controls
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xl + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated page indicators
                    _AnimatedPageIndicators(
                      currentPage: _currentPage,
                      totalPages: _pages.length,
                    ),
                    const SizedBox(height: 40),
                    // Primary CTA with animated glow
                    _GlowButton(
                      glowController: _glowController,
                      text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                      icon: _currentPage == _pages.length - 1
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          context.go('/login');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  final int pageIndex;
  final int currentPage;

  const _OnboardingPage({
    required this.data,
    required this.pageIndex,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final offset = (currentPage - pageIndex).toDouble();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingXl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large icon with parallax effect
              Transform.translate(
                offset: Offset(0, offset * 30),
                child: Opacity(
                  opacity: (1 - offset.abs()).clamp(0.0, 1.0),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      data.icon,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 80),
              // Large, confident title
              Transform.translate(
                offset: Offset(offset * 20, 0),
                child: Opacity(
                  opacity: (1 - offset.abs()).clamp(0.0, 1.0),
                  child: Text(
                    data.title,
                    style: GoogleFonts.inter(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 16),
              // Minimal subtitle
              Transform.translate(
                offset: Offset(offset * 20, 0),
                child: Opacity(
                  opacity: (1 - offset.abs()).clamp(0.0, 1.0),
                  child: Text(
                    data.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 600.ms, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedPageIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _AnimatedPageIndicators({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentPage ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentPage
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
            boxShadow: index == currentPage
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final AnimationController glowController;
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _GlowButton({
    required this.glowController,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        final glowValue = glowController.value;
        return Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: AppRadius.xlAll,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3 + (glowValue * 0.2)),
                blurRadius: 20 + (glowValue * 10),
                spreadRadius: 2 + (glowValue * 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: LightModeColors.lightPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.xlAll,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(icon, size: 24),
              ],
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}
