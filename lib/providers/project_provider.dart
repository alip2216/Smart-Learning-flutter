import 'package:flutter/material.dart';
import '../data/models/learning_project.dart';
import '../data/services/project_service.dart';

class ProjectProvider with ChangeNotifier {
  final _projectService = ProjectService();
  
  bool _isLoading = false;
  List<LearningProject> _projects = [];

  bool get isLoading => _isLoading;
  List<LearningProject> get projects => _projects;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadProjects(String token) async {
    _setLoading(true);
    try {
      _projects = await _projectService.getProjects(token);
    } catch (e) {
      debugPrint("Load projects error: $e");
    }
    _setLoading(false);
  }

  Future<bool> createProject(String token, String title, String description) async {
    _setLoading(true);
    try {
      final newProject = await _projectService.createProject(token, title, description);
      _projects.insert(0, newProject); // Add to the top of the list
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Create project error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject(String token, int projectId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _projectService.deleteProject(token, projectId);
      if (success) {
        _projects.removeWhere((p) => p.id == projectId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint("Delete project error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
