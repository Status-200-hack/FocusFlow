import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focusflow/models/focus_session_model.dart';

class FocusService extends ChangeNotifier {
  static const String _keySessions = 'focus_sessions';
  List<FocusSessionModel> _sessions = [];

  List<FocusSessionModel> get sessions => _sessions;

  Future<void> loadSessions(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_keySessions);
      
      if (sessionsJson != null) {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        final allSessions = decoded.map((e) => FocusSessionModel.fromJson(e)).toList();
        _sessions = allSessions.where((s) => s.userId == userId).toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      } else {
        _sessions = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load sessions: $e');
      _sessions = [];
    }
  }

  Future<void> completeSession(String userId, int durationMinutes, {String? taskId}) async {
    try {
      final now = DateTime.now();
      final session = FocusSessionModel(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        durationMinutes: durationMinutes,
        completedAt: now,
        taskId: taskId,
        createdAt: now,
      );
      _sessions.insert(0, session);
      await _saveSessions();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to complete session: $e');
    }
  }

  List<FocusSessionModel> getTodaySessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _sessions.where((session) {
      final sessionDay = DateTime(
        session.completedAt.year,
        session.completedAt.month,
        session.completedAt.day,
      );
      return sessionDay.isAtSameMomentAs(today);
    }).toList();
  }

  int getTodayFocusMinutes() {
    return getTodaySessions().fold(0, (sum, session) => sum + session.durationMinutes);
  }

  int getTotalFocusMinutes() {
    return _sessions.fold(0, (sum, session) => sum + session.durationMinutes);
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_keySessions, encoded);
    } catch (e) {
      debugPrint('Failed to save sessions: $e');
    }
  }
}
