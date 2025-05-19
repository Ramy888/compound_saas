import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime sentAt;
  final bool isRead;
  final String? attachment;
  final String? attachmentType;
  final Map<String, dynamic>? fileMetadata;


  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.sentAt,
    this.isRead = false,
    this.attachment,
    this.attachmentType,
    this.fileMetadata,

  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      message: data['message'] ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      attachment: data['attachment'],
      attachmentType: data['attachmentType'],
      fileMetadata: data['fileMetadata'],

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
      'attachment': attachment,
      'attachmentType': attachmentType,
      'fileMetadata': fileMetadata,
    };
  }
}