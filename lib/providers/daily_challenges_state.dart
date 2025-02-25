import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_challenge.dart';

class DailyChallengesState extends ChangeNotifier {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedDay;
  final Set<String> completedDays = {};
  SharedPreferences? _prefs;

  DailyChallengesState() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  void previousMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    notifyListeners();
  }

  int getDaysInMonth() {
    return DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
  }

  int getCompletedDaysCount() {
    if (_prefs == null) return 0;

    int count = 0;
    final daysInMonth = getDaysInMonth();

    for (int day = 1; day <= daysInMonth; day++) {
      final key = 'challenge_${currentMonth.year}_${currentMonth.month}_$day';
      final challengeJson = _prefs!.getString(key);
      if (challengeJson != null) {
        final challenge = DailyChallenge.fromJson(jsonDecode(challengeJson));
        if (challenge.isCompleted) {
          count++;
        }
      }
    }

    return count;
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isPastDay(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  Future<bool> isCompleted(DateTime date) async {
    if (_prefs == null) return false;

    final key = 'challenge_${date.year}_${date.month}_${date.day}';
    final challengeJson = _prefs!.getString(key);
    if (challengeJson == null) return false;

    final challenge = DailyChallenge.fromJson(jsonDecode(challengeJson));
    return challenge.isCompleted;
  }

  bool isSelectedDay(DateTime date) {
    return selectedDay?.year == date.year &&
        selectedDay?.month == date.month &&
        selectedDay?.day == date.day;
  }

  void selectDay(DateTime date) {
    selectedDay = date;
    notifyListeners();
  }

  void markDayAsCompleted(DateTime date) {
    completedDays.add(date.toIso8601String().split('T')[0]);
    notifyListeners();
  }

  Future<void> markChallengeAsCompleted(DateTime date) async {
    if (_prefs == null) return;

    final key = 'challenge_${date.year}_${date.month}_${date.day}';
    final challenge = DailyChallenge(
      date: date,
      isCompleted: true,
    );

    await _prefs!.setString(key, jsonEncode(challenge.toJson()));
    completedDays.add(date.toIso8601String().split('T')[0]);
    notifyListeners();
  }
}
