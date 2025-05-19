import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String? id;
  final String title;
  final String titleAr;
  final String body;
  final String bodyAr;
  final List<String> images;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? updatedBy;
  final bool isActive;
  final int views;

  NewsModel({
    this.id,
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    required this.images,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.updatedBy,
    this.isActive = true,
    this.views = 0,
  });

  factory NewsModel.empty() {
    return NewsModel(
      title: '',
      titleAr: '',
      body: '',
      bodyAr: '',
      images: [],
      createdBy: 'Ramy888',
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  factory NewsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewsModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleAr: data['titleAr'] ?? '',
      body: data['body'] ?? '',
      bodyAr: data['bodyAr'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      updatedBy: data['updatedBy'],
      isActive: data['isActive'] ?? true,
      views: data['views'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleAr': titleAr,
      'body': body,
      'bodyAr': bodyAr,
      'images': images,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'updatedBy': updatedBy,
      'isActive': isActive,
      'views': views,
    };
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? body,
    String? bodyAr,
    List<String>? images,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
    bool? isActive,
    int? views,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      body: body ?? this.body,
      bodyAr: bodyAr ?? this.bodyAr,
      images: images ?? this.images,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      isActive: isActive ?? this.isActive,
      views: views ?? this.views,
    );
  }
}