import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class ProjectsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'projects';

  Stream<List<ProjectModel>> getProjects({bool activeOnly = true}) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: activeOnly)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProjectModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addProject(ProjectModel project) async {
    await _firestore.collection(_collection).add(project.toFirestore());
  }

  Future<void> updateProject(ProjectModel project) async {
    await _firestore
        .collection(_collection)
        .doc(project.projectId)
        .update(project.toFirestore());
  }

  Future<void> removeProject(
      String projectId,
      String removedBy,
      String reason,
      ) async {
    await _firestore.collection(_collection).doc(projectId).update({
      'isActive': false,
      'removedAt': Timestamp.now(),
      'removedBy': removedBy,
      'removalReason': reason,
    });
  }

  Future<void> restoreProject(String projectId) async {
    await _firestore.collection(_collection).doc(projectId).update({
      'isActive': true,
      'removedAt': null,
      'removedBy': null,
      'removalReason': null,
    });
  }
}