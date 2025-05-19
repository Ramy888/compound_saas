import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/noifications/send_notifications_sheet.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Notifications'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Active'),
                Tab(text: 'Removed'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsList(
                context: context,
                provider: provider,
                activeOnly: true,
              ),
              _buildNotificationsList(
                context: context,
                provider: provider,
                activeOnly: false,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showSendNotificationSheet(context),
            icon: Icon(Icons.notification_add),
            label: Text('Send Notification'),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsList({
    required BuildContext context,
    required NotificationProvider provider,
    required bool activeOnly,
  }) {
    return StreamBuilder<List<NotificationModel>>(
      stream: provider.getNotifications(activeOnly: activeOnly),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final notifications = snapshot.data!;
        if (notifications.isEmpty) {
          return Center(
            child: Text(
              activeOnly ? 'No active notifications' : 'No removed notifications',
            ),
          );
        }

        return ListView.builder(
          itemCount: notifications.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) => _buildNotificationCard(
            context,
            notifications[index],
            provider,
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(
      BuildContext context,
      NotificationModel notification,
      NotificationProvider provider,
      ) {
    final bool isSent = notification.sentAt != null;
    final bool isScheduled = notification.scheduledFor != null;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              children: [
                Icon(
                  isScheduled ? Icons.schedule : Icons.notification_important,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  notification.topic.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(
                    value,
                    notification,
                    provider,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: notification.isActive ? 'remove' : 'restore',
                      child: ListTile(
                        leading: Icon(
                          notification.isActive
                              ? Icons.delete_outline
                              : Icons.restore,
                        ),
                        title: Text(
                          notification.isActive ? 'Remove' : 'Restore',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (notification.titleAr.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    notification.titleAr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Arial',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
                SizedBox(height: 8),
                Text(
                  notification.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (notification.bodyAr.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    notification.bodyAr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Arial',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
                SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  children: [
                    _buildInfoChip(
                      context,
                      icon: Icons.person,
                      label: notification.createdBy,
                    ),
                    _buildInfoChip(
                      context,
                      icon: Icons.access_time,
                      label: timeago.format(notification.createdAt),
                    ),
                    if (isSent)
                      _buildInfoChip(
                        context,
                        icon: Icons.people,
                        label: '${notification.recipientsCount} recipients',
                      ),
                    if (isScheduled)
                      _buildInfoChip(
                        context,
                        icon: Icons.event,
                        label: 'Scheduled for ${notification.scheduledFor!.toString().substring(0, 16)}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      BuildContext context, {
        required IconData icon,
        required String label,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
      String action,
      NotificationModel notification,
      NotificationProvider provider,
      ) async {
    switch (action) {
      case 'remove':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Remove Notification'),
            content: Text('Are you sure you want to remove this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await provider.toggleNotificationStatus(notification.id!, false);
          if (provider.status == NotificationOperationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notification removed')),
            );
          } else if (provider.status == NotificationOperationStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${provider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
      case 'restore':
        await provider.toggleNotificationStatus(notification.id!, true);
        if (provider.status == NotificationOperationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification restored')),
          );
        } else if (provider.status == NotificationOperationStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
    }
  }

  void _showSendNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SendNotificationSheet(),
    );
  }
}