import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/news_model.dart';
import '../../providers/news_provider.dart';
import '../../widgets/news/news_details_sheet.dart';
import 'add_news_screen.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
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
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('News Management'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Active News'),
                Tab(text: 'Removed News'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Active News Tab
              _buildNewsList(
                context: context,
                provider: newsProvider,
                activeOnly: true,
              ),
              // Removed News Tab
              _buildNewsList(
                context: context,
                provider: newsProvider,
                activeOnly: false,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewsScreen()),
            ),
            label: Text('Add News'),
            icon: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildNewsList({
    required BuildContext context,
    required NewsProvider provider,
    required bool activeOnly,
  }) {
    return StreamBuilder<List<NewsModel>>(
      stream: provider.getNews(activeOnly: activeOnly),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final news = snapshot.data!;
        if (news.isEmpty) {
          return Center(
            child: Text(
              activeOnly ? 'No active news found' : 'No removed news found',
            ),
          );
        }

        return ListView.builder(
          itemCount: news.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            return _buildNewsCard(
              context: context,
              news: news[index],
              provider: provider,
            );
          },
        );
      },
    );
  }

  Widget _buildNewsCard({
    required BuildContext context,
    required NewsModel news,
    required NewsProvider provider,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showNewsDetails(context, news),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.images.isNotEmpty)
              Stack(
                children: [
                  Image.network(
                    news.images.first,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                  if (news.images.length > 1)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${news.images.length - 1} more',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.title,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (news.titleAr.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(
                                news.titleAr,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontFamily: 'Arial',
                                ),
                                textDirection: TextDirection.rtl,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleMenuAction(
                          value,
                          news,
                          provider,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: news.isActive ? 'remove' : 'restore',
                            child: ListTile(
                              leading: Icon(
                                news.isActive
                                    ? Icons.delete_outline
                                    : Icons.restore,
                              ),
                              title: Text(
                                news.isActive ? 'Remove' : 'Restore',
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    news.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${news.views} views',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        timeago.format(news.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
      String action,
      NewsModel news,
      NewsProvider provider,
      ) async {
    switch (action) {
      case 'edit':
      // TODO: Implement edit functionality
        break;
      case 'remove':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Remove News'),
            content: Text('Are you sure you want to remove this news article?'),
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
          await provider.toggleNewsStatus(news.id!, false);
          if (provider.status == NewsOperationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('News removed successfully')),
            );
          } else if (provider.status == NewsOperationStatus.error) {
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
        await provider.toggleNewsStatus(news.id!, true);
        if (provider.status == NewsOperationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('News restored successfully')),
          );
        } else if (provider.status == NewsOperationStatus.error) {
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

  void _showNewsDetails(BuildContext context, NewsModel news) {
    showDialog(
      context: context,
      builder: (context) => NewsDetailsSheet(news: news),
    );
  }
}