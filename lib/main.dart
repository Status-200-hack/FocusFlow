import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/nav.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/services/task_service.dart';
import 'package:focusflow/services/focus_service.dart';
import 'package:focusflow/services/ai_service.dart';
import 'package:focusflow/providers/theme_provider.dart';
import 'package:focusflow/providers/focus_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserService()),
      ChangeNotifierProvider(create: (_) => TaskService()),
      ChangeNotifierProvider(create: (_) => FocusService()),
      ChangeNotifierProvider(create: (_) => AIService()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => FocusProvider()),
    ],
    child: const _AppWithRouter(),
  );
}

class _AppWithRouter extends StatefulWidget {
  const _AppWithRouter();

  @override
  State<_AppWithRouter> createState() => _AppWithRouterState();
}

class _AppWithRouterState extends State<_AppWithRouter> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final userService = context.read<UserService>();
    final themeProvider = context.read<ThemeProvider>();
    
    await Future.wait([
      userService.initialize(),
      themeProvider.initialize(),
    ]);

    if (mounted && userService.currentUser != null) {
      final taskService = context.read<TaskService>();
      final focusService = context.read<FocusService>();
      await Future.wait([
        taskService.loadTasks(userService.currentUser!.id),
        focusService.loadSessions(userService.currentUser!.id),
      ]);
    }

    if (mounted) setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
