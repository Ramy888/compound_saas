import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/project_model.dart';
import '../services/project_service.dart';

enum ProjectStatus {
  initial,
  loading,
  success,
  error
}

class ProjectProvider extends ChangeNotifier {
  final ProjectsService _projectsService = ProjectsService();
  ProjectStatus _status = ProjectStatus.initial;
  String? _error;
  List<ProjectModel> _activeProjects = [];
  List<ProjectModel> _removedProjects = [];
  bool _isLoading = false;

  // Getters
  ProjectStatus get status => _status;
  String? get error => _error;
  List<ProjectModel> get activeProjects => _activeProjects;
  List<ProjectModel> get removedProjects => _removedProjects;
  bool get isLoading => _isLoading;

  // Stream subscriptions
  Stream<List<ProjectModel>> getActiveProjects() =>
      _projectsService.getProjects(activeOnly: true);

  Stream<List<ProjectModel>> getRemovedProjects() =>
      _projectsService.getProjects(activeOnly: false)
          .map((projects) => projects.where((p) => !p.isActive).toList());

  // Add Project with Images
  Future<void> addProject(
      ProjectModel project,
      File? coverImage,
      File? logoImage,
      List<File> photosList,
      ) async {
    try {
      _setLoading(true);
      _status = ProjectStatus.loading;
      notifyListeners();

      final storage = FirebaseStorage.instance;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Upload cover image
      String? coverUrl;
      if (coverImage != null) {
        final coverRef = storage.ref('projects/covers/$timestamp.jpg');
        await coverRef.putFile(coverImage);
        coverUrl = await coverRef.getDownloadURL();
      }

      // Upload logo image
      String? logoUrl;
      if (logoImage != null) {
        final logoRef = storage.ref('projects/logos/$timestamp.jpg');
        await logoRef.putFile(logoImage);
        logoUrl = await logoRef.getDownloadURL();
      }

      // Upload project photos
      List<String> photoUrls = [];
      for (var i = 0; i < photosList.length; i++) {
        final photoRef = storage.ref('projects/photos/$timestamp-$i.jpg');
        await photoRef.putFile(photosList[i]);
        final url = await photoRef.getDownloadURL();
        photoUrls.add(url);
      }

      // Create new project with uploaded URLs
      final newProject = project.copyWith(
        projectCover: coverUrl,
        projectLogo: logoUrl,
        projectPhotosList: photoUrls,
        createdAt: DateTime.now(),
        createdBy: 'Ramy888', // Replace with actual current user
        isActive: true,
      );

      await _projectsService.addProject(newProject);
      _status = ProjectStatus.success;

    } catch (e) {
      _error = e.toString();
      _status = ProjectStatus.error;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Remove Project
  Future<void> removeProject(
      String projectId,
      String reason,
      ) async {
    try {
      _setLoading(true);
      await _projectsService.removeProject(
        projectId,
        'Ramy888', // Replace with actual current user
        reason,
      );
      _status = ProjectStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = ProjectStatus.error;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Restore Project
  Future<void> restoreProject(String projectId) async {
    try {
      _setLoading(true);
      await _projectsService.restoreProject(projectId);
      _status = ProjectStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = ProjectStatus.error;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetStatus() {
    _status = ProjectStatus.initial;
    _error = null;
    notifyListeners();
  }
}