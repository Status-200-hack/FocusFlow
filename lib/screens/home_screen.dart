import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/services/task_service.dart';
import 'package:focusflow/services/ai_service.dart';
import 'package:focusflow/widgets/progress_ring.dart';
import 'package:focusflow/widgets/task_card.dart';
import 'package:focusflow/widgets/gradient_container.dart';

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
    final user = userService.currentUser;
    final todayAll = taskService.getTodayTasks();
    final todayTasks = _query.isEmpty
      ? todayAll
      : todayAll.where((t) => t.title.toLowerCase().contains(_query.toLowerCase()) || (t.description?.toLowerCase().contains(_query.toLowerCase()) ?? false)).toList();
    final completionPercentage = taskService.getTodayCompletionPercentage();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
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
                                  _getGreeting(),
                                  style: context.textStyles.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.name ?? 'Guest',
                                  style: context.textStyles.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/profile'),
                            child: CircleAvatar(
                              radius: 24,
                              child: GradientContainer(
                                colors: isDark
                                  ? [DarkModeColors.darkPrimary, DarkModeColors.darkSecondary]
                                  : [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
                                borderRadius: BorderRadius.circular(24),
                                child: Center(
                                  child: Text(
                                    user?.name.substring(0, 1).toUpperCase() ?? 'G',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.horizontalXl,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Search bar
                    TextField(
                      onChanged: (v) => setState(() => _query = v.trim()),
                      decoration: const InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: AppSpacing.paddingLg,
                        child: Column(
                          children: [
                            ProgressRing(progress: completionPercentage),
                            const SizedBox(height: 16),
                            Text(
                              'Today\'s Progress',
                              style: context.textStyles.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${todayTasks.where((t) => t.isCompleted).length} of ${todayTasks.length} tasks completed',
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // AI suggestions panel
                    _AiSuggestionPanel(isDark: isDark),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Tasks',
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (todayTasks.isNotEmpty)
                          TextButton(
                            onPressed: () {},
                            child: const Text('Filter'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    (context, index) => TaskCard(
                      task: todayTasks[index],
                      onTap: () => context.push('/task/${todayTasks[index].id}'),
                      onToggle: () => taskService.toggleTaskCompletion(todayTasks[index].id),
                      onDelete: () => taskService.deleteTask(todayTasks[index].id),
                    ),
                    childCount: todayTasks.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/task/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      bottomNavigationBar: _BottomNavBar(currentIndex: 0),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: currentIndex == 0,
              onTap: () => context.go('/home'),
            ),
            _NavItem(
              icon: Icons.timer_rounded,
              label: 'Focus',
              isSelected: currentIndex == 1,
              onTap: () => context.go('/focus'),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: currentIndex == 2,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AiSuggestionPanel extends StatelessWidget {
  final bool isDark;
  const _AiSuggestionPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary).withValues(alpha: 0.15),
              child: Icon(Icons.auto_awesome,
                color: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Get smart suggestions', style: context.textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Use AI to optimize your plan for today.',
                    style: context.textStyles.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () async {
                final ai = context.read<AIService>();
                final tasks = context.read<TaskService>().getTodayTasks();
                final tips = await ai.getSmartSuggestions(tasks);
                if (!context.mounted) return;
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder: (ctx) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Suggestions', style: context.textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (tips.isEmpty)
                          Text('No suggestions available right now.', style: context.textStyles.bodyMedium)
                        else
                          ...tips.map((t) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.bolt, color: Theme.of(context).colorScheme.tertiary),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(t, style: context.textStyles.bodyLarge)),
                                  ],
                                ),
                              )),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => context.push('/ai'),
                            icon: const Icon(Icons.chat),
                            label: const Text('Open Assistant'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bolt),
              label: const Text('AI Optimize'),
            ),
          ],
        ),
      ),
    );
  }
}
