import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../providers/user_provider.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _chatsCollection = 'chats';
  final String _messagesCollection = 'messages';
  final UserProvider _userProvider;

  // Add UserProvider through constructor
  ChatService(this._userProvider);

  // Helper method to get current DateTime in UTC
  DateTime get currentUtcTime => DateTime.now();

  // Helper method to ensure we have a current user
  void _ensureCurrentUser() {
    if (_userProvider.currentUser == null) {
      throw Exception('No authenticated user found');
    }
  }

  // Helper getters for current user info
  String get currentUserId => _userProvider.currentUser?.id ?? '';
  String get currentUserName => _userProvider.currentUser?.name ?? '';

  Stream<List<ChatModel>> getChats({ChatStatus? status}) {
    _ensureCurrentUser(); // Check if user is authenticated
    Query query = _firestore.collection(_chatsCollection);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString());
    }

    return query
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatModel.fromFirestore(doc))
        .toList());
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    _ensureCurrentUser(); // Check if user is authenticated
    return _firestore
        .collection(_messagesCollection)
        .where('chatId', isEqualTo: chatId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc))
        .toList());
  }

  Future<ChatModel> createChat({
    required ChatType type,
    required String subject,
  }) async {
    _ensureCurrentUser(); // Check if user is authenticated

    final chatData = ChatModel(
      id: '',
      userId: currentUserId,
      userName: currentUserName,
      type: type,
      status: ChatStatus.active,
      subject: subject,
      createdAt: currentUtcTime,
      lastMessageAt: currentUtcTime,
    ).toFirestore();

    final docRef = await _firestore.collection(_chatsCollection).add(chatData);
    final doc = await docRef.get();
    return ChatModel.fromFirestore(doc);
  }

  Future<MessageModel> sendMessage({
    required String chatId,
    required String message,
    String? attachment,
    String? attachmentType,
    Map<String, dynamic>? fileMetadata,
  }) async {
    _ensureCurrentUser(); // Check if user is authenticated

    final batch = _firestore.batch();

    // Create message
    final messageRef = _firestore.collection(_messagesCollection).doc();
    final messageData = MessageModel(
      id: messageRef.id,
      chatId: chatId,
      senderId: currentUserId,
      senderName: currentUserName,
      message: message,
      sentAt: currentUtcTime,
      attachment: attachment,
      attachmentType: attachmentType,
      fileMetadata: fileMetadata,
    ).toFirestore();

    batch.set(messageRef, messageData);

    // Update chat
    final chatRef = _firestore.collection(_chatsCollection).doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message,
      'lastMessageAt': Timestamp.fromDate(currentUtcTime),
      'unreadCount': FieldValue.increment(1),
    });

    await batch.commit();
    final doc = await messageRef.get();
    return MessageModel.fromFirestore(doc);
  }

  Future<void> closeChat(String chatId) async {
    _ensureCurrentUser(); // Check if user is authenticated

    await _firestore.collection(_chatsCollection).doc(chatId).update({
      'status': ChatStatus.closed.toString(),
      'closedAt': Timestamp.fromDate(currentUtcTime),
      'closedBy': currentUserName,
    });
  }

  Future<void> markChatAsRead(String chatId) async {
    _ensureCurrentUser(); // Check if user is authenticated

    final batch = _firestore.batch();

    // Update chat unread count
    final chatRef = _firestore.collection(_chatsCollection).doc(chatId);
    batch.update(chatRef, {'unreadCount': 0});

    // Mark all messages as read
    final messages = await _firestore
        .collection(_messagesCollection)
        .where('chatId', isEqualTo: chatId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': Timestamp.fromDate(currentUtcTime),
      });
    }

    await batch.commit();
  }
}