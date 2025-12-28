import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/services/ai_service.dart';
import 'package:focusflow/widgets/glass_chat_bubble.dart';
import 'package:focusflow/widgets/typing_indicator.dart';
import 'package:focusflow/widgets/ai_avatar.dart';
import 'package:focusflow/widgets/thinking_shimmer.dart';
import 'package:focusflow/widgets/glass_card.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _hasError = false;
  bool _isUnavailable = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    // Check if AI is configured by trying to detect availability
    try {
      // This will be checked when user tries to send a message
      setState(() => _isUnavailable = false);
    } catch (e) {
      setState(() => _isUnavailable = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _hasError = false);
    
    try {
      await context.read<AIService>().sendMessage(text);
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isUnavailable = e.toString().contains('not configured') || 
                        e.toString().contains('unavailable');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AIService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasMessages = ai.messages.isNotEmpty;

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
          child: Column(
            children: [
              // Premium header
              _PremiumHeader(isDark: isDark)
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 300))
                  .slideY(begin: -0.1, end: 0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic),
              Expanded(
                child: _isUnavailable && !hasMessages
                    ? _UnavailableState(isDark: isDark)
                    : hasMessages
                        ? _ChatList(
                            messages: ai.messages,
                            isLoading: ai.isLoading,
                            isDark: isDark,
                            scrollController: _scrollController,
                          )
                        : _EmptyState(
                            isDark: isDark,
                            onSuggestionTap: (text) async {
                              _controller.text = text;
                              await _send();
                            },
                          ),
              ),
              // Typing indicator with shimmer
              if (ai.isLoading)
                ThinkingShimmer(
                  isActive: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AiAvatar(size: 40, isThinking: true),
                        const SizedBox(width: 12),
                        GlassCard(
                          borderRadius: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: TypingIndicator(isDark: isDark),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 300))
                    .slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic),
              // Error fallback
              if (_hasError && !_isUnavailable)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: (isDark ? DarkModeColors.darkError : LightModeColors.lightError)
                        .withValues(alpha: 0.1),
                    border: Border.all(
                      color: (isDark ? DarkModeColors.darkError : LightModeColors.lightError)
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: isDark ? DarkModeColors.darkError : LightModeColors.lightError,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI service is temporarily unavailable. Please try again later.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? DarkModeColors.darkError : LightModeColors.lightError,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 300))
                    .slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic),
              // Premium input field
              _PremiumInputField(
                controller: _controller,
                onSend: _send,
                isLoading: ai.isLoading,
                isDark: isDark,
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400))
                  .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }
}

// Premium header with AI avatar
class _PremiumHeader extends StatelessWidget {
  final bool isDark;

  const _PremiumHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingLg,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),
          AiAvatar(size: 48, isThinking: false),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Always here to help',
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
          IconButton(
            icon: Icon(
              Icons.auto_awesome_rounded,
              color: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '💡 Tip: Ask for summaries or task ideas!',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Chat list with glass bubbles
class _ChatList extends StatelessWidget {
  final List messages;
  final bool isLoading;
  final bool isDark;
  final ScrollController scrollController;

  const _ChatList({
    required this.messages,
    required this.isLoading,
    required this.isDark,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final m = messages[index];
        final isUser = m.role == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: GlassChatBubble(
                message: m.content,
                isUser: isUser,
                isAnimated: true,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Beautiful empty state
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Function(String) onSuggestionTap;

  const _EmptyState({
    required this.isDark,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                        .withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 100,
                color: (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                    .withValues(alpha: 0.3),
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 600))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack),
            const SizedBox(height: 40),
            Text(
              'Your AI Assistant',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                letterSpacing: -1,
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 500))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
            const SizedBox(height: 16),
            Text(
              'Ask me anything about your tasks,\nproductivity tips, or get smart suggestions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                    .withValues(alpha: 0.8),
                height: 1.5,
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 500))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  text: '💡 Task ideas',
                  isDark: isDark,
                  onTap: () => onSuggestionTap('Give me some task ideas for today'),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 500), duration: const Duration(milliseconds: 400))
                    .slideX(begin: -0.1, end: 0, delay: const Duration(milliseconds: 500), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                _SuggestionChip(
                  text: '📊 Daily summary',
                  isDark: isDark,
                  onTap: () => onSuggestionTap('Give me a summary of my day'),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 400))
                    .slideX(begin: -0.1, end: 0, delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                _SuggestionChip(
                  text: '🎯 Focus tips',
                  isDark: isDark,
                  onTap: () => onSuggestionTap('Share some focus and productivity tips'),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 700), duration: const Duration(milliseconds: 400))
                    .slideX(begin: -0.1, end: 0, delay: const Duration(milliseconds: 700), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final bool isDark;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.text,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// Graceful fallback UI when AI is unavailable
class _UnavailableState extends StatelessWidget {
  final bool isDark;

  const _UnavailableState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? DarkModeColors.darkSurfaceVariant : LightModeColors.lightSurfaceVariant)
                    .withValues(alpha: 0.3),
                border: Border.all(
                  color: (isDark ? DarkModeColors.darkOutline : LightModeColors.lightOutline)
                      .withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 80,
                color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                    .withValues(alpha: 0.5),
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 600))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic),
            const SizedBox(height: 40),
            Text(
              'AI Assistant\nUnavailable',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                letterSpacing: -0.5,
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 500))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
            const SizedBox(height: 16),
            Text(
              'The AI assistant is currently not configured.\nPlease set up your API keys to use this feature.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                    .withValues(alpha: 0.7),
                height: 1.5,
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 500))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}

// Premium input field
class _PremiumInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final bool isDark;

  const _PremiumInputField({
    required this.controller,
    required this.onSend,
    required this.isLoading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: GlassCard(
              borderRadius: 28,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                enabled: !isLoading,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  hintStyle: GoogleFonts.inter(
                    color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                        .withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                        .withValues(alpha: 0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                  isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                      .withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onSend,
                borderRadius: BorderRadius.circular(28),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
                          size: 24,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
