import 'package:flutter/material.dart';
import '../data/models/learning_log.dart';
import '../data/services/log_service.dart';

class LogProvider with ChangeNotifier {
  final _logService = LogService();
  
  bool _isLoading = false;
  List<LearningLog> _logs = [];

  bool get isLoading => _isLoading;
  List<LearningLog> get logs => _logs;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadLogs(String token, int projectId) async {
    _logs = []; // Bersihkan state lama agar tidak ada delay visual
    _setLoading(true);
    try {
      _logs = await _logService.getLogs(token, projectId);
    } catch (e) {
      debugPrint("Load logs error: $e");
    }
    _setLoading(false);
  }

  // Mengembalikan pesan AI jika sukses, atau null jika gagal
  Future<String?> createLog(String token, int projectId, String note, String date) async {
    _setLoading(true);
    try {
      final result = await _logService.createLog(token, projectId, note, date);
      _logs.insert(0, result['log'] as LearningLog);
      _setLoading(false);
      return result['ai_message'] as String;
    } catch (e) {
      debugPrint("Create log error: $e");
      _setLoading(false);
      return null;
    }
  }

  Future<bool> updateLog(String token, int projectId, int logId, String note, String date) async {
    _setLoading(true);
    try {
      final updatedLog = await _logService.updateLog(token, projectId, logId, note, date);
      final index = _logs.indexWhere((l) => l.id == logId);
      if (index != -1) {
        _logs[index] = updatedLog;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint("Update log error: $e");
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteLog(String token, int projectId, int logId) async {
    _setLoading(true);
    try {
      final success = await _logService.deleteLog(token, projectId, logId);
      if (success) {
        _logs.removeWhere((l) => l.id == logId);
      }
      _setLoading(false);
      return success;
    } catch (e) {
      debugPrint("Delete log error: $e");
      _setLoading(false);
      return false;
    }
  }
}
