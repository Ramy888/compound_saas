import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatType { inquiry, complaint }
enum ChatStatus { active, closed }

class ChatModel {
  final String id;
  final String userId;
  final String userName;
  final ChatType type;
  final ChatStatus status;
  final String subject;
  final DateTime createdAt;
  final DateTime? closedAt;
  final String? closedBy;
  final DateTime lastMessageAt;
  final String? lastMessage;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.status,
    required this.subject,
    required this.createdAt,
    this.closedAt,
    this.closedBy,
    required this.lastMessageAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      type: ChatType.values.firstWhere(
            (e) => e.toString() == data['type'],
        orElse: () => ChatType.inquiry,
      ),
      status: ChatStatus.values.firstWhere(
            (e) => e.toString() == data['status'],
        orElse: () => ChatStatus.active,
      ),
      subject: data['subject'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      closedAt: data['closedAt'] != null
          ? (data['closedAt'] as Timestamp).toDate()
          : null,
      closedBy: data['closedBy'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'],
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'type': type.toString(),
      'status': status.toString(),
      'subject': subject,
      'createdAt': Timestamp.fromDate(createdAt),
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'closedBy': closedBy,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
    };
  }
}