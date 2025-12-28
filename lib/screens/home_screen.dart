import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/services/task_service.dart';
import 'package:focusflow/services/ai_service.dart';
import 'package:focusflow/services/focus_service.dart';
import 'package:focusflow/widgets/premium_progress_ring.dart';
import 'package:focusflow/widgets/premium_task_card.dart';
import 'package:focusflow/widgets/glass_card.dart';
import 'package:focusflow/widgets/animated_gradient_border.dart';
import 'package:focusflow/widgets/gradient_container.dart';
import 'package:focusflow/widgets/floating_glass_nav_bar.dart';
import 'package:focusflow/utils/motion_extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final taskService = context.watch<TaskService>();
    final focusService = context.watch<FocusService>();
    final user = userService.currentUser;
    final todayAll = taskService.getTodayTasks();
    final todayTasks = _query.isEmpty
        ? todayAll
        : todayAll.where((t) =>
            t.title.toLowerCase().contains(_query.toLowerCase()) ||
            t.description.toLowerCase().contains(_query.toLowerCase())).toList();
    final completionPercentage = taskService.getTodayCompletionPercentage();
    final completedCount = todayTasks.where((t) => t.isCompleted).length;
    final totalCount = todayTasks.length;
    final focusMinutes = focusService.getTodayFocusMinutes();
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
                    DarkModeColors.darkPrimary.withValues(alpha: 0.05),
                  ]
                : [
                    LightModeColors.lightPrimary.withValues(alpha: 0.03),
                    LightModeColors.lightBackground,
                    LightModeColors.lightSecondary.withValues(alpha: 0.02),
                  ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Hero section with animated background
              _HeroSection(
                greeting: _getGreeting(),
                userName: user?.name ?? 'Guest',
                userInitial: (user?.name ?? 'Guest').substring(0, 1).toUpperCase(),
                isDark: isDark,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.horizontalXl,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // Search bar with glass effect
                      GlassCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v.trim()),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search tasks...',
                            hintStyle: GoogleFonts.inter(
                              color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                                  .withValues(alpha: 0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                                  .withValues(alpha: 0.7),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400))
                          .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                      const SizedBox(height: 32),
                      // Large progress ring with glow
                      PremiumProgressRing(
                        progress: completionPercentage,
                        size: 200,
                        label: 'Complete',
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 150), duration: const Duration(milliseconds: 600))
                          .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 150), duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack),
                      const SizedBox(height: 32),
                      // Focus score / completion stat highlight
                      _StatsRow(
                        completedTasks: completedCount,
                        totalTasks: totalCount,
                        focusMinutes: focusMinutes,
                        isDark: isDark,
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 250), duration: const Duration(milliseconds: 400))
                          .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 250), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                      const SizedBox(height: 32),
                      // AI Optimize card with animated gradient border
                      _PremiumAiCard(isDark: isDark)
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400))
                          .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                      const SizedBox(height: 40),
                      // Section header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today\'s Tasks',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                              letterSpacing: -0.5,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 350), duration: const Duration(milliseconds: 400))
                              .slideX(begin: -0.1, end: 0, delay: const Duration(milliseconds: 350), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                          if (todayTasks.isNotEmpty)
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Filter',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 400))
                                .slideX(begin: 0.1, end: 0, delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            if (taskService.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (todayTasks.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks for today',
                        style: context.textStyles.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add a new task',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: AppSpacing.horizontalXl,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => PremiumTaskCard(
                      task: todayTasks[index],
                      onTap: () => context.push('/task/${todayTasks[index].id}'),
                      onToggle: () => taskService.toggleTaskCompletion(todayTasks[index].id),
                      onDelete: () => taskService.deleteTask(todayTasks[index].id),
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 400 + (index * 50)),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        )
                        .slideX(
                          begin: -0.1,
                          end: 0,
                          delay: Duration(milliseconds: 400 + (index * 50)),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        ),
                    childCount: todayTasks.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/task/new'),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Task',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
        foregroundColor: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
        ),
      )
          .animate()
          .fadeIn(delay: const Duration(milliseconds: 500), duration: const Duration(milliseconds: 400))
          .slideY(
            begin: 0.2,
            end: 0,
            delay: const Duration(milliseconds: 500),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
          ),
      bottomNavigationBar: FloatingGlassNavBar(currentIndex: 0),
    );
  }
}

// Hero section with animated background
class _HeroSection extends StatefulWidget {
  final String greeting;
  final String userName;
  final String userInitial;
  final bool isDark;

  const _HeroSection({
    required this.greeting,
    required this.userName,
    required this.userInitial,
    required this.isDark,
  });

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 200,
        child: Stack(
          children: [
            // Animated gradient background
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        -1 + (_backgroundController.value * 2),
                        -1 + (_backgroundController.value * 2),
                      ),
                      end: Alignment(
                        1 - (_backgroundController.value * 2),
                        1 - (_backgroundController.value * 2),
                      ),
                      colors: widget.isDark
                          ? [
                              DarkModeColors.darkPrimary.withValues(alpha: 0.1),
                              DarkModeColors.darkSecondary.withValues(alpha: 0.05),
                              DarkModeColors.darkTertiary.withValues(alpha: 0.08),
                            ]
                          : [
                              LightModeColors.lightPrimary.withValues(alpha: 0.08),
                              LightModeColors.lightSecondary.withValues(alpha: 0.05),
                              LightModeColors.lightTertiary.withValues(alpha: 0.03),
                            ],
                    ),
                  ),
                );
              },
            ),
            // Content
            Padding(
              padding: AppSpacing.paddingXl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.greeting,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: (widget.isDark
                                        ? DarkModeColors.darkOnSurfaceVariant
                                        : LightModeColors.lightOnSurfaceVariant)
                                    .withValues(alpha: 0.8),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: const Duration(milliseconds: 400))
                                .slideX(begin: -0.1, end: 0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                            const SizedBox(height: 8),
                            Text(
                              widget.userName,
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: widget.isDark
                                    ? DarkModeColors.darkOnSurface
                                    : LightModeColors.lightOnSurface,
                                letterSpacing: -1,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400))
                                .slideX(begin: -0.1, end: 0, delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: CircleAvatar(
                          radius: 28,
                          child: GradientContainer(
                            colors: widget.isDark
                                ? [DarkModeColors.darkPrimary, DarkModeColors.darkSecondary]
                                : [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
                            borderRadius: BorderRadius.circular(28),
                            child: Center(
                              child: Text(
                                widget.userInitial,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400))
                          .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: (widget.isDark
                              ? DarkModeColors.darkOnSurfaceVariant
                              : LightModeColors.lightOnSurfaceVariant)
                          .withValues(alpha: 0.7),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stats row with focus score and completion highlight
class _StatsRow extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final int focusMinutes;
  final bool isDark;

  const _StatsRow({
    required this.completedTasks,
    required this.totalTasks,
    required this.focusMinutes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 32,
                  color: isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  '$completedTasks/$totalTasks',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tasks Done',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 32,
                  color: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                ),
                const SizedBox(height: 12),
                Text(
                  '$focusMinutes',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Focus Min',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Premium AI Optimize card with animated gradient border
class _PremiumAiCard extends StatefulWidget {
  final bool isDark;

  const _PremiumAiCard({required this.isDark});

  @override
  State<_PremiumAiCard> createState() => _PremiumAiCardState();
}

class _PremiumAiCardState extends State<_PremiumAiCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBorder(
      colors: widget.isDark
          ? [
              DarkModeColors.darkPrimary,
              DarkModeColors.darkSecondary,
              DarkModeColors.darkTertiary,
              DarkModeColors.darkPrimary,
            ]
          : [
              LightModeColors.lightPrimary,
              LightModeColors.lightSecondary,
              LightModeColors.lightTertiary,
              LightModeColors.lightPrimary,
            ],
      borderRadius: 24,
      borderWidth: 2,
      child: GlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isDark
                      ? [DarkModeColors.darkPrimary, DarkModeColors.darkSecondary]
                      : [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Optimize',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get smart suggestions',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: (widget.isDark
                              ? DarkModeColors.darkOnSurfaceVariant
                              : LightModeColors.lightOnSurfaceVariant)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ScaleOnTap(
              onTap: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      final ai = context.read<AIService>();
                      final tasks = context.read<TaskService>().getTodayTasks();
                      final tips = await ai.getSmartSuggestions(tasks);
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => GlassCard(
                          borderRadius: 28,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Suggestions',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: widget.isDark
                                      ? DarkModeColors.darkOnSurface
                                      : LightModeColors.lightOnSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (tips.isEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: (widget.isDark
                                            ? DarkModeColors.darkSurfaceVariant
                                            : LightModeColors.lightSurfaceVariant)
                                        .withValues(alpha: 0.3),
                                    border: Border.all(
                                      color: (widget.isDark
                                              ? DarkModeColors.darkOutline
                                              : LightModeColors.lightOutline)
                                          .withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 20,
                                        color: (widget.isDark
                                                ? DarkModeColors.darkOnSurfaceVariant
                                                : LightModeColors.lightOnSurfaceVariant)
                                            .withValues(alpha: 0.9),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          'No suggestions available right now.',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: widget.isDark
                                                ? DarkModeColors.darkOnSurface
                                                : LightModeColors.lightOnSurface,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...tips.map((t) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.bolt_rounded,
                                            size: 20,
                                            color: widget.isDark
                                                ? DarkModeColors.darkTertiary
                                                : LightModeColors.lightTertiary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              t,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: widget.isDark
                                                    ? DarkModeColors.darkOnSurface
                                                    : LightModeColors.lightOnSurface,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: widget.isDark
                                        ? [DarkModeColors.darkPrimary, DarkModeColors.darkSecondary]
                                        : [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (widget.isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      context.pop();
                                      context.push('/ai');
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_rounded,
                                            color: widget.isDark
                                                ? DarkModeColors.darkOnPrimary
                                                : LightModeColors.lightOnPrimary,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Open Assistant',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: widget.isDark
                                                  ? DarkModeColors.darkOnPrimary
                                                  : LightModeColors.lightOnPrimary,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDark
                        ? [DarkModeColors.darkPrimary, DarkModeColors.darkSecondary]
                        : [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
