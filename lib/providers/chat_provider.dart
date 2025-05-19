import 'package:compound/providers/user_provider.dart';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final UserProvider _userProvider;

  late final ChatService _chatService;
  String? _currentChatId;
  String? _error;

  String? get currentChatId => _currentChatId;
  String? get error => _error;

  ChatProvider(this._userProvider) {
    _chatService = ChatService(_userProvider);
  }


  void setCurrentChat(String? chatId) {
    _currentChatId = chatId;
    if (chatId != null) {
      markChatAsRead(chatId);
    }
    notifyListeners();
  }

  Stream<List<ChatModel>> getChats({ChatStatus? status}) {
    return _chatService.getChats(status: status);
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _chatService.getMessages(chatId);
  }

  Future<void> createChat({
    required String subject,
    required ChatType type,
  }) async {
    try {
      final chat = await _chatService.createChat(
        type: type,
        subject: subject,
      );
      _currentChatId = chat.id;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> sendMessage({
    required String message,
    String? attachment,
    String? attachmentType,
    Map<String, dynamic>? fileMetadata,
  }) async {
    try {
      if (_currentChatId == null) throw 'No chat selected';

      await _chatService.sendMessage(
        chatId: _currentChatId!,
        message: message,
        attachment: attachment,
        attachmentType: attachmentType,
        fileMetadata: fileMetadata,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> closeChat(String chatId) async {
    try {
      await _chatService.closeChat(chatId);
      if (_currentChatId == chatId) {
        _currentChatId = null;
        notifyListeners();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    try {
      await _chatService.markChatAsRead(chatId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}