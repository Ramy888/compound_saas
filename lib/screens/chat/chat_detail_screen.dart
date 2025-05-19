import 'dart:io';

import 'package:compound/models/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';
import 'package:path/path.dart' as path;

import '../../providers/user_provider.dart';


class ChatDetailScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  File? _selectedImage;
  File? _selectedFile;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserProvider _userProvider = UserProvider();
  UserModel? _currentUser;



  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    _currentUser = _userProvider.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chat.subject),
            Text(
              widget.chat.type.toString().split('.').last.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.chat.status == ChatStatus.active)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _closeChat(context),
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.chat.status == ChatStatus.closed)
            Container(
              color: Colors.red[100],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This chat was closed by ${widget.chat.closedBy} on '
                          '${widget.chat.closedAt.toString().substring(0, 16)}',
                      style: TextStyle(color: Colors.red[900]),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return StreamBuilder<List<MessageModel>>(
                  stream: provider.getMessages(widget.chat.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return Center(child: Text('No messages yet'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == 'Ramy888';
                        return _buildMessageBubble(message, isMe);

                        // return Align(
                        //   alignment: isMe
                        //       ? Alignment.centerRight
                        //       : Alignment.centerLeft,
                        //   child: Container(
                        //     margin: EdgeInsets.only(
                        //       bottom: 8,
                        //       left: isMe ? 48 : 0,
                        //       right: isMe ? 0 : 48,
                        //     ),
                        //     padding: EdgeInsets.symmetric(
                        //       horizontal: 16,
                        //       vertical: 10,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: isMe
                        //           ? Theme.of(context).primaryColor
                        //           : Colors.grey[300],
                        //       borderRadius: BorderRadius.circular(20),
                        //     ),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         if (!isMe)
                        //           Text(
                        //             message.senderName,
                        //             style: TextStyle(
                        //               fontSize: 12,
                        //               color: Colors.grey[600],
                        //             ),
                        //           ),
                        //         Text(
                        //           message.message,
                        //           style: TextStyle(
                        //             color: isMe ? Colors.white : Colors.black,
                        //           ),
                        //         ),
                        //         Text(
                        //           message.sentAt
                        //               .toString()
                        //               .substring(11, 16),
                        //           style: TextStyle(
                        //             fontSize: 10,
                        //             color: isMe
                        //                 ? Colors.white70
                        //                 : Colors.grey[600],
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // );
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (widget.chat.status == ChatStatus.active)
            Column(
              children: [
                if (_selectedImage != null || _selectedFile != null)
                  Container(
                    height: 100,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_selectedImage != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedImage = null),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.close, size: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_selectedFile != null)
                          Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.description, size: 32),
                                    SizedBox(height: 4),
                                    Text(
                                      _selectedFile!.path.split('/').last,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedFile = null),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.close, size: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(Icons.attach_file),
                        onSelected: (value) {
                          switch (value) {
                            case 'image':
                              _pickImage();
                              break;
                            case 'file':
                              _pickFile();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'image',
                            child: ListTile(
                              leading: Icon(Icons.image),
                              title: Text('Image'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'file',
                            child: ListTile(
                              leading: Icon(Icons.description),
                              title: Text('Document'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: _selectedImage != null
                                ? 'Add a caption...'
                                : _selectedFile != null
                                ? 'Add a message...'
                                : 'Type a message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _isLoading ? null : _sendMessage,
                        ),
                      ),
                      IconButton(
                        icon: _isLoading
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Icon(Icons.send),
                        onPressed: _isLoading
                            ? null
                            : () => _sendMessage(_messageController.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 48 : 0,
          right: isMe ? 0 : 48,
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (message.attachment != null) ...[
                    if (message.attachmentType == 'image')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.attachment!,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (message.attachmentType == 'file')
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                message.attachment!.split('/').last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 8),
                  ],
                  if (message.message.isNotEmpty)
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4, right: 8),
              child: Text(
                message.sentAt.toString().substring(11, 16),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty && _selectedImage == null && _selectedFile == null) return;

    setState(() => _isLoading = true);
    try {
      final provider = context.read<ChatProvider>();
      String? attachment;
      String? attachmentType;

      // Handle file uploads
      if (_selectedImage != null || _selectedFile != null) {
        final File fileToUpload = _selectedImage ?? _selectedFile!;
        final String timestamp = DateTime.now()
            .millisecondsSinceEpoch
            .toString();
        final String fileName = path.basename(fileToUpload.path);
        final String fileExtension = path.extension(fileName);

        // Determine file type and storage path
        final String storageFolder = _selectedImage != null ? 'chat_images' : 'chat_files';
        final String uniqueFileName = '${_currentUser!.email}_${timestamp}_$fileName';

        // Create storage reference
        final Reference storageRef = _storage
            .ref()
            .child('chats/${widget.chat.id}/$storageFolder/$uniqueFileName');

        // Upload file
        try {
          // Set content type for images
          SettableMetadata? metadata;
          if (_selectedImage != null) {
            metadata = SettableMetadata(
              contentType: 'image/${fileExtension.replaceAll('.', '')}',
            );
          }

          // Upload with metadata if it's an image
          final UploadTask uploadTask = metadata != null
              ? storageRef.putFile(fileToUpload, metadata)
              : storageRef.putFile(fileToUpload);

          // Wait for upload to complete and get download URL
          final TaskSnapshot snapshot = await uploadTask;
          attachment = await snapshot.ref.getDownloadURL();

          // Set attachment type
          attachmentType = _selectedImage != null ? 'image' : 'file';

          // Add file metadata to message
          final Map<String, dynamic> fileMetadata = {
            'name': fileName,
            'size': await fileToUpload.length(),
            'type': fileExtension,
            'uploadedAt': DateTime.now(),
            'uploadedBy': _currentUser!.id,
          };

          // Update message text if empty
          if (text.trim().isEmpty) {
            text = _selectedImage != null ? '📸 Image' : '📎 File: $fileName';
          }

        } catch (e) {
          print('Error uploading file: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading file. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Send message with attachments if any
      await provider.sendMessage(
        message: text.trim(),
        attachment: attachment,
        attachmentType: attachmentType,
      );

      // Clear input and selected files
      _messageController.clear();
      setState(() {
        _selectedImage = null;
        _selectedFile = null;
      });

      // Scroll to bottom of chat
      _scrollToBottom();

    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
      _sendMessage(''); // Send message with image
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
      _sendMessage(''); // Send message with file
    }
  }

  void _closeChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Close Chat'),
        content: Text('Are you sure you want to close this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<ChatProvider>()
                  .closeChat(widget.chat.id);
              Navigator.pop(context);
            },
            child: Text(
              'Close',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}