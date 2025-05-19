import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/auth_service.dart';

class DashboardDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();
  final DateTime currentLoginTime = DateTime.parse('2025-05-08 12:15:52');

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavigationItems(context),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Text(
          'R',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      accountName: Text(
        'Ramy888',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        'Last login: ${timeago.format(currentLoginTime)}',
      ),
      otherAccountsPictures: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    return Column(
      children: [
        _buildSection(
          context,
          'Analytics',
          [
            _buildNavItem(
              context,
              'Dashboard Overview',
              Icons.dashboard,
              '/dashboard',
            ),
            _buildNavItem(
              context,
              'User Analytics',
              Icons.people,
              '/analytics/users',
            ),
            _buildNavItem(
              context,
              'Performance Metrics',
              Icons.analytics,
              '/analytics/performance',
            ),
          ],
        ),
        Divider(),
        _buildSection(
          context,
          'Management',
          [
            _buildNavItem(
              context,
              'Projects',
              Icons.business,
              '/projects',
            ),
            _buildNavItem(
              context,
              'Users',
              Icons.group,
              '/users',
            ),
            _buildNavItem(
              context,
              'Complaints',
              Icons.warning,
              '/complaints',
            ),
            _buildNavItem(
              context,
              'Inquiries',
              Icons.help,
              '/inquiries',
            ),
          ],
        ),
        Divider(),
        _buildSection(
          context,
          'Content',
          [
            _buildNavItem(
              context,
              'News',
              Icons.newspaper,
              '/news',
            ),
            _buildNavItem(
              context,
              'Videos',
              Icons.video_library,
              '/videos',
            ),
            _buildNavItem(
              context,
              'Advertisements',
              Icons.ad_units,
              '/advertisements',
            ),
            _buildNavItem(
              context,
              'Offers',
              Icons.local_offer,
              '/offers',
            ),
          ],
        ),
        Divider(),
        _buildSection(
          context,
          'Communication',
          [
            _buildNavItem(
              context,
              'Notifications',
              Icons.notifications,
              '/notifications',
            ),
            _buildNavItem(
              context,
              'Chat',
              Icons.chat,
              '/chat',
            ),
            _buildNavItem(
              context,
              'Broadcast Messages',
              Icons.campaign,
              '/broadcast',
            ),
          ],
        ),
        Divider(),
        _buildSection(
          context,
          'System',
          [
            _buildNavItem(
              context,
              'Settings',
              Icons.settings,
              '/settings',
            ),
            _buildNavItem(
              context,
              'Audit Logs',
              Icons.history,
              '/audit-logs',
            ),
            _buildNavItem(
              context,
              'Help & Support',
              Icons.help_center,
              '/support',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
      BuildContext context,
      String title,
      List<Widget> items,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      String title,
      IconData icon,
      String route,
      ) {
    final isCurrentRoute = ModalRoute.of(context)?.settings.name == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isCurrentRoute
            ? Theme.of(context).primaryColor
            : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isCurrentRoute
              ? Theme.of(context).primaryColor
              : null,
          fontWeight: isCurrentRoute
              ? FontWeight.bold
              : null,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isCurrentRoute) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.exit_to_app),
        title: Text('Logout'),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Confirm Logout'),
              content: Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Logout'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await _authService.signOut();
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
      ),
    );
  }
}