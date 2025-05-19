import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus {
  new_complaint,
  pending,
  closed
}

enum ComplaintPriority {
  low,
  medium,
  high,
  urgent
}

class ComplaintModel {
  final String? id;
  final String title;
  final String description;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final ComplaintStatus status;
  final ComplaintPriority priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? assignedTo;
  final String? closedBy;
  final DateTime? closedAt;
  final String? closureNote;
  final List<String> images;
  final bool isRead;

  ComplaintModel({
    this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    this.assignedTo,
    this.closedBy,
    this.closedAt,
    this.closureNote,
    this.images = const [],
    this.isRead = false,
  });

  factory ComplaintModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ComplaintModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'],
      status: ComplaintStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => ComplaintStatus.new_complaint,
      ),
      priority: ComplaintPriority.values.firstWhere(
        (e) => e.toString() == data['priority'],
        orElse: () => ComplaintPriority.medium,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      assignedTo: data['assignedTo'],
      closedBy: data['closedBy'],
      closedAt: data['closedAt'] != null
          ? (data['closedAt'] as Timestamp).toDate()
          : null,
      closureNote: data['closureNote'],
      images: List<String>.from(data['images'] ?? []),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'status': status.toString(),
      'priority': priority.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'assignedTo': assignedTo,
      'closedBy': closedBy,
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'closureNote': closureNote,
      'images': images,
      'isRead': isRead,
    };
  }

  ComplaintModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    ComplaintStatus? status,
    ComplaintPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedTo,
    String? closedBy,
    DateTime? closedAt,
    String? closureNote,
    List<String>? images,
    bool? isRead,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      closedBy: closedBy ?? this.closedBy,
      closedAt: closedAt ?? this.closedAt,
      closureNote: closureNote ?? this.closureNote,
      images: images ?? this.images,
      isRead: isRead ?? this.isRead,
    );
  }
}