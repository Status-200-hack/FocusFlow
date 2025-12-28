import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/models/task_model.dart';
import 'package:focusflow/services/task_service.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/services/ai_service.dart';
import 'package:focusflow/widgets/custom_button.dart';
import 'package:focusflow/widgets/custom_input.dart';
import 'package:focusflow/widgets/priority_chip.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isNewTask = false;
  TaskModel? _existingTask;

  @override
  void initState() {
    super.initState();
    _isNewTask = widget.taskId == 'new';
    
    if (!_isNewTask) {
      final taskService = context.read<TaskService>();
      _existingTask = taskService.getTaskById(widget.taskId);
      
      if (_existingTask != null) {
        _titleController = TextEditingController(text: _existingTask!.title);
        _descriptionController = TextEditingController(text: _existingTask!.description);
        _selectedPriority = _existingTask!.priority;
        _selectedDate = _existingTask!.dueDate;
      } else {
        _titleController = TextEditingController();
        _descriptionController = TextEditingController();
      }
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final taskService = context.read<TaskService>();
    final userService = context.read<UserService>();
    final now = DateTime.now();

    if (_isNewTask) {
      final newTask = TaskModel(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userService.currentUser!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDate,
        createdAt: now,
        updatedAt: now,
      );
      await taskService.createTask(newTask);
    } else if (_existingTask != null) {
      final updated = _existingTask!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDate,
        updatedAt: now,
      );
      await taskService.updateTask(updated);
    }

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isNewTask ? 'Task created!' : 'Task updated!')),
      );
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TaskService>().deleteTask(widget.taskId);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_isNewTask ? 'New Task' : 'Edit Task'),
      actions: [
        if (!_isNewTask)
          IconButton(
            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            onPressed: _deleteTask,
          ),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.paddingXl,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInput(
                controller: _titleController,
                label: 'Task Title',
                hint: 'What needs to be done?',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomInput(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Add more details...',
                icon: Icons.notes,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Text('Smart Assist', style: context.textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true);
                      try {
                        final ai = context.read<AIService>();
                        final result = await ai.suggestForTask(
                          title: _titleController.text,
                          description: _descriptionController.text,
                        );
                        if (!mounted) return;
                        if ((result['title'] as String).isNotEmpty) {
                          _titleController.text = result['title'] as String;
                        }
                        if ((result['description'] as String).isNotEmpty) {
                          _descriptionController.text = result['description'] as String;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✨ AI suggestions applied')));
                      } catch (e) {
                        debugPrint('AI autofill failed: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI is not available right now.')));
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    icon: const Icon(Icons.bolt),
                    label: const Text('AI Autofill'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Priority',
                style: context.textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: TaskPriority.values.map((priority) =>
                  PriorityChip(
                    priority: priority,
                    isSelected: _selectedPriority == priority,
                    onTap: () => setState(() => _selectedPriority = priority),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Due Date',
                style: context.textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _selectedDate != null
                          ? DateFormat('EEEE, MMMM d, y').format(_selectedDate!)
                          : 'Select due date',
                        style: context.textStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isNewTask ? 'Create Task' : 'Save Changes',
                  icon: _isNewTask ? Icons.add_task : Icons.save,
                  isLoading: _isLoading,
                  onPressed: _saveTask,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
