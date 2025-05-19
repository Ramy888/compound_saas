import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String? id;
  final String title;
  final String titleAr;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String videoId;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? updatedBy;
  final int views;

  VideoModel({
    this.id,
    required this.title,
    required this.titleAr,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.videoId,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.updatedBy,
    this.views = 0,
  });

  factory VideoModel.empty() {
    return VideoModel(
      title: '',
      titleAr: '',
      youtubeUrl: '',
      thumbnailUrl: '',
      videoId: '',
      createdBy: 'Ramy888',
      createdAt: DateTime.now(),
    );
  }

  factory VideoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleAr: data['titleAr'] ?? '',
      youtubeUrl: data['youtubeUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoId: data['videoId'] ?? '',
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      updatedBy: data['updatedBy'],
      views: data['views'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleAr': titleAr,
      'youtubeUrl': youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'videoId': videoId,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'updatedBy': updatedBy,
      'views': views,
    };
  }

  VideoModel copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? youtubeUrl,
    String? thumbnailUrl,
    String? videoId,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
    int? views,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoId: videoId ?? this.videoId,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      views: views ?? this.views,
    );
  }
}