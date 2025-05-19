import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String title;
  final String titleAr;
  final String body;
  final String bodyAr;
  final String topic; // 'all', 'users', 'admins', etc.
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? sentAt;
  final int recipientsCount;
  final Map<String, dynamic>? data; // Additional data for deep linking

  NotificationModel({
    this.id,
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    required this.topic,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    this.scheduledFor,
    this.sentAt,
    this.recipientsCount = 0,
    this.data,
  });

  factory NotificationModel.empty() {
    return NotificationModel(
      title: '',
      titleAr: '',
      body: '',
      bodyAr: '',
      topic: 'all',
      createdBy: 'Ramy888',
      createdAt: DateTime.now(),
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleAr: data['titleAr'] ?? '',
      body: data['body'] ?? '',
      bodyAr: data['bodyAr'] ?? '',
      topic: data['topic'] ?? 'all',
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      scheduledFor: data['scheduledFor'] != null
          ? (data['scheduledFor'] as Timestamp).toDate()
          : null,
      sentAt: data['sentAt'] != null
          ? (data['sentAt'] as Timestamp).toDate()
          : null,
      recipientsCount: data['recipientsCount'] ?? 0,
      data: data['data'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleAr': titleAr,
      'body': body,
      'bodyAr': bodyAr,
      'topic': topic,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledFor': scheduledFor != null ? Timestamp.fromDate(scheduledFor!) : null,
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'recipientsCount': recipientsCount,
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? body,
    String? bodyAr,
    String? topic,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? scheduledFor,
    DateTime? sentAt,
    int? recipientsCount,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      body: body ?? this.body,
      bodyAr: bodyAr ?? this.bodyAr,
      topic: topic ?? this.topic,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      sentAt: sentAt ?? this.sentAt,
      recipientsCount: recipientsCount ?? this.recipientsCount,
      data: data ?? this.data,
    );
  }
}