import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/firebase_service.dart';

/// Provider for managing projects state with Firebase
class ProjectsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<ProjectModel> _allProjects = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _error;

  List<ProjectModel> get allProjects => _allProjects;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Filtered projects based on selected category
  List<ProjectModel> get filteredProjects {
    if (_selectedCategory == 'All') return _allProjects;
    return _allProjects.where((p) => p.category == _selectedCategory).toList();
  }

  ProjectsProvider() {
    _listenToProjects();
  }

  /// Subscribe to real-time project updates from Firestore
  void _listenToProjects() {
    _firebaseService.getProjectsStream().listen(
      (projects) async {
        if (projects.isEmpty) {
          debugPrint('Projects collection empty. Seeding sample projects to Firebase...');
          await _firebaseService.seedSampleProjects();
          _allProjects = sampleProjects; // Use temporarily until stream updates
        } else {
          _allProjects = projects;
        }
        
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _allProjects = sampleProjects;
        _isLoading = false;
        _error = null; // Silently fall back to sample data
        notifyListeners();
      },
    );
  }

  /// Set active category filter
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  /// Add project (admin)
  Future<void> addProject(ProjectModel project) async {
    await _firebaseService.addProject(project);
  }

  /// Update project (admin)
  Future<void> updateProject(ProjectModel project) async {
    await _firebaseService.updateProject(project);
  }

  /// Delete project (admin)
  Future<void> deleteProject(String id) async {
    await _firebaseService.deleteProject(id);
  }
}
