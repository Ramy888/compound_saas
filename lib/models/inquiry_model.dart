import 'package:cloud_firestore/cloud_firestore.dart';

enum InquiryStatus {
  new_inquiry,
  in_progress,
  completed,
  cancelled
}

enum InquiryType {
  registered,
  guest
}

enum ResponseType {
  email,
  notification,
  call,
  chat
}

class InquiryModel {
  final String? id;
  final String subject;
  final String message;
  final String userEmail;
  final String? userId; // null for guests
  final String? userName;
  final String? userPhone;
  final InquiryType type;
  final InquiryStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? respondedBy;
  final ResponseType? responseType;
  final String? response;
  final bool isRead;

  InquiryModel({
    this.id,
    required this.subject,
    required this.message,
    required this.userEmail,
    this.userId,
    this.userName,
    this.userPhone,
    required this.type,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.respondedBy,
    this.responseType,
    this.response,
    this.isRead = false,
  });

  factory InquiryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InquiryModel(
      id: doc.id,
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userId: data['userId'],
      userName: data['userName'],
      userPhone: data['userPhone'],
      type: InquiryType.values.firstWhere(
            (e) => e.toString() == data['type'],
        orElse: () => InquiryType.guest,
      ),
      status: InquiryStatus.values.firstWhere(
            (e) => e.toString() == data['status'],
        orElse: () => InquiryStatus.new_inquiry,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      respondedBy: data['respondedBy'],
      responseType: data['responseType'] != null
          ? ResponseType.values.firstWhere(
            (e) => e.toString() == data['responseType'],
      )
          : null,
      response: data['response'],
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'message': message,
      'userEmail': userEmail,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'type': type.toString(),
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'respondedBy': respondedBy,
      'responseType': responseType?.toString(),
      'response': response,
      'isRead': isRead,
    };
  }

  InquiryModel copyWith({
    String? id,
    String? subject,
    String? message,
    String? userEmail,
    String? userId,
    String? userName,
    String? userPhone,
    InquiryType? type,
    InquiryStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? respondedBy,
    ResponseType? responseType,
    String? response,
    bool? isRead,
  }) {
    return InquiryModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      userEmail: userEmail ?? this.userEmail,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      respondedBy: respondedBy ?? this.respondedBy,
      responseType: responseType ?? this.responseType,
      response: response ?? this.response,
      isRead: isRead ?? this.isRead,
    );
  }
}