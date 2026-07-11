import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api.config.dart';
import '../models/learning_project.dart';

class ProjectService {
  Future<List<LearningProject>> getProjects(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/learning-projects'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List projectsJson = data['data'];
      return projectsJson.map((json) => LearningProject.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil daftar proyek');
    }
  }

  Future<LearningProject> createProject(String token, String title, String description) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/learning-projects'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return LearningProject.fromJson(data['data']);
    } else {
      throw Exception('Gagal membuat proyek baru');
    }
  }

  /// Menghapus proyek
  Future<bool> deleteProject(String token, int projectId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/learning-projects/$projectId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menghapus proyek');
    }
  }
}
