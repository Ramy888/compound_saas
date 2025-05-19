import 'package:flutter/material.dart';
import '../../models/inquiry_model.dart';

class RespondInquiryDialog extends StatefulWidget {
  final InquiryModel inquiry;

  const RespondInquiryDialog({
    super.key,
    required this.inquiry,
  });

  @override
  _RespondInquiryDialogState createState() => _RespondInquiryDialogState();
}

class _RespondInquiryDialogState extends State<RespondInquiryDialog> {
  final _responseController = TextEditingController();
  ResponseType _selectedType = ResponseType.email;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Respond to Inquiry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select response method:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildResponseTypeChip(ResponseType.email),
              _buildResponseTypeChip(ResponseType.notification),
              _buildResponseTypeChip(ResponseType.call),
              if (widget.inquiry.type == InquiryType.registered)
                _buildResponseTypeChip(ResponseType.chat),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _responseController,
            decoration: InputDecoration(
              labelText: 'Response',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_responseController.text.isNotEmpty) {
              Navigator.pop(context, {
                'response': _responseController.text,
                'responseType': _selectedType,
              });
            }
          },
          child: Text('Send'),
        ),
      ],
    );
  }

  Widget _buildResponseTypeChip(ResponseType type) {
    bool isSelected = _selectedType == type;

    IconData icon;
    String label;
    Color color;

    switch (type) {
      case ResponseType.email:
        icon = Icons.email;
        label = 'Email';
        color = Colors.blue;
        break;
      case ResponseType.notification:
        icon = Icons.notifications;
        label = 'Notification';
        color = Colors.orange;
        break;
      case ResponseType.call:
        icon = Icons.phone;
        label = 'Call';
        color = Colors.green;
        break;
      case ResponseType.chat:
        icon = Icons.chat;
        label = 'Chat';
        color = Colors.purple;
        break;
    }

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
            ),
          ),
        ],
      ),
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      onSelected: (selected) {
        setState(() => _selectedType = type);
      },
    );
  }
}