import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cycle_model.dart';

class CycleProvider extends ChangeNotifier {
  List<CycleData> _cycles = [];
  int _cycleLength = 28;
  int _periodDays = 5;
  String? _userId;

  List<CycleData> get cycles => _cycles;
  int get cycleLength => _cycleLength;
  int get periodDays => _periodDays;

  CycleProvider();

  /// Call this after a user signs in/out to scope data to that user.
  Future<void> loadForUser(String? userId) async {
    _userId = userId;
    _cycles = [];
    _cycleLength = 28;
    _periodDays = 5;
    notifyListeners();
    if (userId != null) {
      await _loadCycles();
    }
  }

  String get _cyclesKey => 'cycles_${_userId ?? 'guest'}';
  String get _cycleLengthKey => 'cycle_length_${_userId ?? 'guest'}';
  String get _periodDaysKey => 'period_days_${_userId ?? 'guest'}';

  // Load cycles from SharedPreferences
  Future<void> _loadCycles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cyclesJson = prefs.getString(_cyclesKey);
      _cycleLength = prefs.getInt(_cycleLengthKey) ?? 28;
      _periodDays = prefs.getInt(_periodDaysKey) ?? 5;

      if (cyclesJson != null) {
        final List<dynamic> decodedList = jsonDecode(cyclesJson);
        _cycles = decodedList.map((item) => CycleData.fromJson(item)).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cycles: $e');
    }
  }

  // Add cycle
  Future<void> addCycle(DateTime startDate, int duration) async {
    try {
      final newCycle = CycleData(
        id: DateTime.now().toString(),
        startDate: startDate,
        endDate: startDate.add(Duration(days: duration)),
        duration: duration,
        symptoms: [],
        notes: '',
      );

      _cycles.add(newCycle);
      await _saveCycles();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Save (insert new or update existing) a full CycleData object
  Future<void> saveCycle(CycleData cycle) async {
    try {
      final index = _cycles.indexWhere((c) => c.id == cycle.id);
      if (index != -1) {
        _cycles[index] = cycle;
      } else {
        _cycles.add(cycle);
      }
      await _saveCycles();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Update cycle
  Future<void> updateCycle(CycleData cycle) async {
    try {
      final index = _cycles.indexWhere((c) => c.id == cycle.id);
      if (index != -1) {
        _cycles[index] = cycle;
        await _saveCycles();
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete cycle
  Future<void> deleteCycle(String cycleId) async {
    try {
      _cycles.removeWhere((c) => c.id == cycleId);
      await _saveCycles();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Update cycle settings
  Future<void> updateCycleSettings(int cycleLength, int periodDays) async {
    try {
      _cycleLength = cycleLength;
      _periodDays = periodDays;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cycleLengthKey, cycleLength);
      await prefs.setInt(_periodDaysKey, periodDays);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Save cycles to SharedPreferences
  Future<void> _saveCycles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cyclesJson = jsonEncode(
        _cycles.map((cycle) => cycle.toJson()).toList(),
      );
      await prefs.setString(_cyclesKey, cyclesJson);
    } catch (e) {
      debugPrint('Error saving cycles: $e');
    }
  }

  // Get current cycle
  CycleData? getCurrentCycle() {
    final today = DateTime.now();
    try {
      return _cycles.firstWhere(
        (cycle) =>
            (today.isAfter(cycle.startDate) ||
                today.isAtSameMomentAs(cycle.startDate)) &&
            (today.isBefore(cycle.endDate) ||
                today.isAtSameMomentAs(cycle.endDate)),
      );
    } catch (e) {
      return null;
    }
  }

  // Get cycle statistics
  Map<String, dynamic> getCycleStats() {
    if (_cycles.isEmpty) {
      return {
        'averageLength': 0,
        'totalCycles': 0,
        'regularCycles': 0,
      };
    }

    final durations = _cycles.map((c) => c.duration).toList();
    final averageDuration =
        durations.reduce((a, b) => a + b) / durations.length;

    return {
      'averageLength': averageDuration.round(),
      'totalCycles': _cycles.length,
      'regularCycles': _cycles.length,
    };
  }
}
