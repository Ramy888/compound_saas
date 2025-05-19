import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/inquiry_model.dart';

class InquiryListView extends StatelessWidget {
  final List<InquiryModel> inquiries;
  final Function(InquiryModel) onInquiryTap;
  final bool isCompleted;

  const InquiryListView({
    super.key,
    required this.inquiries,
    required this.onInquiryTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (inquiries.isEmpty) {
      return Center(
        child: Text(
          isCompleted ? 'No completed inquiries' : 'No new inquiries',
        ),
      );
    }

    return ListView.builder(
      itemCount: inquiries.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final inquiry = inquiries[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => onInquiryTap(inquiry),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        inquiry.type == InquiryType.registered
                            ? Icons.person
                            : Icons.person_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inquiry.userName ?? inquiry.userEmail,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (!inquiry.isRead && !isCompleted)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'New',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    inquiry.subject,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    inquiry.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        timeago.format(inquiry.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Spacer(),
                      if (isCompleted && inquiry.responseType != null)
                        _buildResponseTypeChip(inquiry.responseType!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponseTypeChip(ResponseType type) {
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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}