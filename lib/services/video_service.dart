import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_model.dart';

class VideoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'videos';

  Stream<List<VideoModel>> getVideos({bool activeOnly = true}) {
    Query query = _firestore.collection(_collection);

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VideoModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addVideo(VideoModel video) async {
    await _firestore.collection(_collection).add(video.toFirestore());
  }

  Future<void> toggleVideoStatus(String videoId, bool isActive) async {
    await _firestore.collection(_collection).doc(videoId).update({
      'isActive': isActive,
      'updatedAt': Timestamp.now(),
      'updatedBy': 'Ramy888',
    });
  }

  Future<void> incrementViews(String videoId) async {
    await _firestore.collection(_collection).doc(videoId).update({
      'views': FieldValue.increment(1),
    });
  }
}