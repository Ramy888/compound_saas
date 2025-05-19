import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/noifications/send_notifications_sheet.dart';
import '../../widgets/users/cached_circle_avatar.dart';
import 'add_user_sheet.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Users Management'),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(96),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'New'),
                      Tab(text: 'Active'),
                      Tab(text: 'Removed'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildUserList(context, provider, UserFilter.newUser),
              _buildUserList(context, provider, UserFilter.active),
              _buildUserList(context, provider, UserFilter.removed),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddUserSheet(context),
            icon: Icon(Icons.person_add),
            label: Text('Add User'),
          ),
        );
      },
    );
  }

  Widget _buildUserList(
      BuildContext context,
      UserProvider provider,
      UserFilter filter,
      ) {
    return StreamBuilder<List<UserModel>>(
      stream: provider.getUsers(
        filter: filter,
        searchQuery: _searchQuery,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;
        if (users.isEmpty) {
          return Center(
            child: Text(
              _getEmptyMessage(filter),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) => _buildUserCard(
            context,
            users[index],
            provider,
          ),
        );
      },
    );
  }

  String _getEmptyMessage(UserFilter filter) {
    switch (filter) {
      case UserFilter.newUser:
        return 'No new users';
      case UserFilter.active:
        return 'No active users';
      case UserFilter.removed:
        return 'No removed users';
    }
  }

  Widget _buildUserCard(
      BuildContext context,
      UserModel user,
      UserProvider provider,
      ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: Hero(
              tag: 'user-${user.id}',
              child: CachedCircleAvatar(
                imageUrl: user.photoUrl,
                radius: 25,
                name: user.name,
              ),
            ),
            title: Text(
              user.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(user.email),
                SizedBox(height: 2),
                Text(
                  user.lastSeen != null
                      ? 'Last seen ${timeago.format(user.lastSeen!)}'
                      : 'Never seen',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleAction(action, user, provider),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: user.isActive ? 'remove' : 'restore',
                  child: ListTile(
                    leading: Icon(
                      user.isActive ? Icons.person_off : Icons.person,
                      color: user.isActive ? Colors.red : Colors.green,
                    ),
                    title: Text(
                      user.isActive ? 'Remove User' : 'Restore User',
                      style: TextStyle(
                        color: user.isActive ? Colors.red : Colors.green,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (user.isActive) ...[
                  PopupMenuItem(
                    value: 'notification',
                    child: ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text('Send Notification'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'call',
                    child: ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Call'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'email',
                    child: ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Send Email'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'chat',
                    child: ListTile(
                      leading: Icon(Icons.chat),
                      title: Text('Start Chat'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (user.isActive)
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () => _handleAction('notification', user, provider),
                  tooltip: 'Send Notification',
                ),
                IconButton(
                  icon: Icon(Icons.phone),
                  onPressed: () => _handleAction('call', user, provider),
                  tooltip: 'Call',
                ),
                IconButton(
                  icon: Icon(Icons.email),
                  onPressed: () => _handleAction('email', user, provider),
                  tooltip: 'Send Email',
                ),
                IconButton(
                  icon: Icon(Icons.chat),
                  onPressed: () => _handleAction('chat', user, provider),
                  tooltip: 'Start Chat',
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _handleAction(String action, UserModel user, UserProvider provider) async {
    switch (action) {
      case 'remove':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Remove User'),
            content: Text('Are you sure you want to remove ${user.name}?'),
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
          await provider.toggleUserStatus(user.id, false);
        }
        break;

      case 'restore':
        await provider.toggleUserStatus(user.id, true);
        break;

      case 'notification':
        _showSendNotificationSheet(context);
        break;

      case 'call':
        final url = Uri.parse('tel:${user.phone}');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
        break;

      case 'email':
        final url = Uri.parse('mailto:${user.email}');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
        break;

      case 'chat':
      // TODO: Implement chat feature
        break;
    }
  }

  void _showAddUserSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddUserSheet(),
    );
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