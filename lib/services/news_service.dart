import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/news_model.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'news';

  Stream<List<NewsModel>> getNews({bool activeOnly = true}) {
    Query query = _firestore.collection(_collection);

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NewsModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<String> uploadNewsImage(File imageFile, String fileName) async {
    final ref = _storage.ref('news/images/$fileName');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<List<String>> uploadNewsImages(List<File> images) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    List<String> urls = [];

    for (var i = 0; i < images.length; i++) {
      final fileName = 'news_${timestamp}_$i.jpg';
      final url = await uploadNewsImage(images[i], fileName);
      urls.add(url);
    }

    return urls;
  }

  Future<void> addNews(NewsModel news, List<File> imageFiles) async {
    final List<String> imageUrls = await uploadNewsImages(imageFiles);
    final newsWithImages = news.copyWith(images: imageUrls);
    await _firestore.collection(_collection).add(newsWithImages.toFirestore());
  }

  Future<void> updateNews(NewsModel news) async {
    await _firestore
        .collection(_collection)
        .doc(news.id)
        .update(news.toFirestore());
  }

  Future<void> toggleNewsStatus(String newsId, bool isActive) async {
    await _firestore.collection(_collection).doc(newsId).update({
      'isActive': isActive,
      'updatedAt': Timestamp.now(),
      'updatedBy': 'Ramy888',
    });
  }

  Future<void> incrementViews(String newsId) async {
    await _firestore.collection(_collection).doc(newsId).update({
      'views': FieldValue.increment(1),
    });
  }
}