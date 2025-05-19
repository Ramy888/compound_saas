import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/dashboard/action_card.dart';
import '../widgets/dashboard/analytics_card.dart';
import '../widgets/dashboard/chart_card.dart';
import '../widgets/dashboard/dashboard_drawer.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isAnalyticsExpanded = true;
  bool isActionsExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications view
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // TODO: Implement profile view
            },
          ),
        ],
      ),
      drawer: DashboardDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                SizedBox(height: 24),
                _buildAnalyticsSection(),
                SizedBox(height: 24),
                _buildActionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Ramy888',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Last login: ${DateTime.now().toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: isAnalyticsExpanded,
        onExpansionChanged: (expanded) {
          setState(() => isAnalyticsExpanded = expanded);
        },
        title: Text(
          'Analytics Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    AnalyticsCard(
                      title: 'Registered Users',
                      value: '1,234',
                      icon: Icons.people,
                      trend: '+5.2%',
                    ),
                    AnalyticsCard(
                      title: 'Active Complaints',
                      value: '42',
                      icon: Icons.warning,
                      trend: '-2.1%',
                    ),
                    AnalyticsCard(
                      title: 'Pending Inquiries',
                      value: '18',
                      icon: Icons.question_answer,
                      trend: '+1.8%',
                    ),
                    AnalyticsCard(
                      title: 'Active Projects',
                      value: '7',
                      icon: Icons.business,
                      trend: '0%',
                    ),
                  ],
                ),
                SizedBox(height: 24),
                ChartCard(
                  title: 'User Activity',
                  chart: LineChart(
                    // TODO: Implement chart data
                    LineChartData(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: isActionsExpanded,
        onExpansionChanged: (expanded) {
          setState(() => isActionsExpanded = expanded);
        },
        title: Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                ActionCard(
                  title: 'Add Project',
                  icon: Icons.add_business,
                  onTap: () {
                    Navigator.pushNamed(context, '/projects');
                  },
                ),
                ActionCard(
                  title: 'View Inquiries',
                  icon: Icons.question_answer,
                  onTap: () {
                    Navigator.pushNamed(context, '/inquiries');
                  },
                ),
                ActionCard(
                  title: 'View Complaints',
                  icon: Icons.warning,
                  onTap: () {
                    Navigator.pushNamed(context, '/complaint');
                  },
                ),
                ActionCard(
                  title: 'Add News',
                  icon: Icons.newspaper,
                  onTap: () {
                    Navigator.pushNamed(context, '/news');
                  },
                ),
                ActionCard(
                  title: 'Add Video',
                  icon: Icons.video_library,
                  onTap: () {
                    Navigator.pushNamed(context, '/videos');
                  },
                ),
                ActionCard(
                  title: 'Send Notification',
                  icon: Icons.notifications_active,
                  onTap: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                ActionCard(
                  title: 'Manage Users',
                  icon: Icons.people,
                  onTap: () {
                    Navigator.pushNamed(context, '/users');
                  },
                ),
                ActionCard(
                  title: 'Add Offer',
                  icon: Icons.ad_units,
                  onTap: () {
                    Navigator.pushNamed(context, '/offers');
                  },
                ),
                ActionCard(
                  title: 'Chat',
                  icon: Icons.chat,
                  onTap: () {
                    // TODO: Navigate to chat screen
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}