import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/video_model.dart';
import '../../providers/video_provider.dart';
import '../../widgets/videos/video_player_floating.dart';
import 'add_video_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  _VideosScreenState createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  OverlayEntry? _videoOverlay;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _videoOverlay?.remove();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Videos'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Active Videos'),
                Tab(text: 'Removed Videos'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildVideosList(
                context: context,
                provider: provider,
                activeOnly: true,
              ),
              _buildVideosList(
                context: context,
                provider: provider,
                activeOnly: false,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddVideoScreen()),
            ),
            label: Text('Add Video'),
            icon: Icon(Icons.video_library),
          ),
        );
      },
    );
  }

  Widget _buildVideosList({
    required BuildContext context,
    required VideoProvider provider,
    required bool activeOnly,
  }) {
    return StreamBuilder<List<VideoModel>>(
      stream: provider.getVideos(activeOnly: activeOnly),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final videos = snapshot.data!;
        if (videos.isEmpty) {
          return Center(
            child: Text(
              activeOnly ? 'No active videos' : 'No removed videos',
            ),
          );
        }

        return ListView.builder(
          itemCount: videos.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) => _buildVideoCard(
            context,
            videos[index],
            provider,
          ),
        );
      },
    );
  }

  Widget _buildVideoCard(
      BuildContext context,
      VideoModel video,
      VideoProvider provider,
      ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Image not available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _launchVideo(context, video),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
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
                            video.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (video.titleAr.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Text(
                              video.titleAr,
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
                        video,
                        provider,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: video.isActive ? 'remove' : 'restore',
                          child: ListTile(
                            leading: Icon(
                              video.isActive
                                  ? Icons.delete_outline
                                  : Icons.restore,
                            ),
                            title: Text(
                              video.isActive ? 'Remove' : 'Restore',
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${video.views} views',
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
                      timeago.format(video.createdAt),
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
    );
  }

  void _handleMenuAction(
      String action,
      VideoModel video,
      VideoProvider provider,
      ) async {
    switch (action) {
      case 'remove':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Remove Video'),
            content: Text('Are you sure you want to remove this video?'),
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
          await provider.toggleVideoStatus(video.id!, false);
          if (provider.status == VideoOperationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Video removed successfully')),
            );
          } else if (provider.status == VideoOperationStatus.error) {
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
        await provider.toggleVideoStatus(video.id!, true);
        if (provider.status == VideoOperationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video restored successfully')),
          );
        } else if (provider.status == VideoOperationStatus.error) {
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

  void _launchVideo(BuildContext context, VideoModel video) {
    _videoOverlay?.remove();
    _videoOverlay = OverlayEntry(
      builder: (context) => FloatingVideoPlayer(
        video: video,
        onClose: () {
          _videoOverlay?.remove();
          _videoOverlay = null;
        },
      ),
    );

    Overlay.of(context).insert(_videoOverlay!);
  }


}