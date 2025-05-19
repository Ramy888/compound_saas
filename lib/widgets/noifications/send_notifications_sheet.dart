import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class SendNotificationSheet extends StatefulWidget {
  const SendNotificationSheet({super.key});

  @override
  _SendNotificationSheetState createState() => _SendNotificationSheetState();
}

class _SendNotificationSheetState extends State<SendNotificationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _titleArController = TextEditingController();
  final _bodyController = TextEditingController();
  final _bodyArController = TextEditingController();
  String _selectedTopic = 'all';
  DateTime? _scheduledFor;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _topics = [
    {'value': 'all', 'label': 'All Users', 'icon': Icons.public},
    {'value': 'users', 'label': 'Regular Users', 'icon': Icons.person},
    {'value': 'admins', 'label': 'Admins', 'icon': Icons.admin_panel_settings},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _titleArController.dispose();
    _bodyController.dispose();
    _bodyArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    children: [
                      _buildTopicSelector(),
                      SizedBox(height: 24),
                      _buildTitleSection(),
                      SizedBox(height: 24),
                      _buildBodySection(),
                      SizedBox(height: 24),
                      _buildScheduleSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.notification_add,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Notification',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Create and send a new notification',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _isLoading ? null : _handleSubmit,
                icon: _isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                )
                    : Icon(Icons.send),
                label: Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipients',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: _topics.map((topic) {
              return RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(topic['icon'] as IconData),
                    SizedBox(width: 12),
                    Text(topic['label'] as String),
                  ],
                ),
                value: topic['value'] as String,
                groupValue: _selectedTopic,
                onChanged: (value) {
                  setState(() => _selectedTopic = value!);
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title (English)',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
          value?.isEmpty == true ? 'Title is required' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _titleArController,
          decoration: InputDecoration(
            labelText: 'Title (Arabic)',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
          validator: (value) =>
          value?.isEmpty == true ? 'Arabic title is required' : null,
        ),
      ],
    );
  }

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _bodyController,
          decoration: InputDecoration(
            labelText: 'Message (English)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          validator: (value) =>
          value?.isEmpty == true ? 'Message is required' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _bodyArController,
          decoration: InputDecoration(
            labelText: 'Message (Arabic)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          textDirection: TextDirection.rtl,
          validator: (value) =>
          value?.isEmpty == true ? 'Arabic message is required' : null,
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        ListTile(
          title: Text(_scheduledFor == null
              ? 'Send immediately'
              : 'Scheduled for ${_scheduledFor.toString().substring(0, 16)}'),
          subtitle: Text(
            _scheduledFor == null
                ? 'Tap to schedule for later'
                : 'Tap to change or remove schedule',
          ),
          leading: Icon(
            _scheduledFor == null ? Icons.send : Icons.schedule,
          ),
          trailing: _scheduledFor != null
              ? IconButton(
            icon: Icon(Icons.close),
            onPressed: () => setState(() => _scheduledFor = null),
          )
              : null,
          onTap: _showDateTimePicker,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ],
    );
  }

  Future<void> _showDateTimePicker() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledFor ?? now.add(Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledFor ?? now),
      );

      if (time != null) {
        setState(() {
          _scheduledFor = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<NotificationProvider>();

      final notification = NotificationModel(
        title: _titleController.text,
        titleAr: _titleArController.text,
        body: _bodyController.text,
        bodyAr: _bodyArController.text,
        topic: _selectedTopic,
        createdBy: 'Ramy888',
        createdAt: DateTime.now(),
        scheduledFor: _scheduledFor,
      );

      if (_scheduledFor != null) {
        await provider.scheduleNotification(notification);
      } else {
        await provider.sendNotification(notification);
      }

      if (provider.status == NotificationOperationStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _scheduledFor != null
                  ? 'Notification scheduled successfully'
                  : 'Notification sent successfully',
            ),
          ),
        );
        Navigator.pop(context);
      } else if (provider.status == NotificationOperationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}