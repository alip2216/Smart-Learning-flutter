import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api.config.dart';
import '../models/learning_log.dart';

class LogService {
  Future<List<LearningLog>> getLogs(String token, int projectId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/learning-projects/$projectId/logs'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List logsJson = data['data'];
      return logsJson.map((json) => LearningLog.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil daftar catatan');
    }
  }

  Future<Map<String, dynamic>> createLog(String token, int projectId, String note, String date) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/learning-projects/$projectId/logs'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'note': note,
        'progress_date': date,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final log = LearningLog.fromJson(data['data']['log']);
      final aiMessage = data['data']['ai_response'] != null 
          ? data['data']['ai_response']['message'] 
          : 'AI tidak merespons.';
      
      return {
        'log': log,
        'ai_message': aiMessage,
      };
    } else {
      throw Exception('Gagal membuat catatan baru');
    }
  }

  Future<LearningLog> updateLog(String token, int projectId, int logId, String note, String date) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/learning-projects/$projectId/logs/$logId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'note': note,
        'progress_date': date,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LearningLog.fromJson(data['data']);
    } else {
      throw Exception('Gagal mengubah catatan');
    }
  }

  Future<bool> deleteLog(String token, int projectId, int logId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/learning-projects/$projectId/logs/$logId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}
