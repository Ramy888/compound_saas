import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/complaint_model.dart';

class ComplaintDetailsSheet extends StatelessWidget {
  final ComplaintModel complaint;
  final Function(ComplaintStatus, String?) onStatusUpdate;

  const ComplaintDetailsSheet({
    super.key,
    required this.complaint,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Complaint Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildUserInfoSection(context),
                    Divider(),
                    _buildComplaintInfoSection(context),
                    if (complaint.images.isNotEmpty) ...[
                      Divider(),
                      _buildImagesSection(context),
                    ],
                    if (complaint.status != ComplaintStatus.closed) ...[
                      Divider(),
                      _buildActionsSection(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(complaint.userName),
                  subtitle: Text('User Name'),
                  dense: true,
                ),
                if (complaint.userPhone != null)
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(complaint.userPhone!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.phone),
                          onPressed: () => _launchUrl('tel:${complaint.userPhone}'),
                        ),
                        IconButton(
                          icon: Icon(Icons.message),
                          onPressed: () => _launchUrl('sms:${complaint.userPhone}'),
                        ),
                      ],
                    ),
                    dense: true,
                  ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text(complaint.userEmail),
                  trailing: IconButton(
                    icon: Icon(Icons.email),
                    onPressed: () => _launchUrl('mailto:${complaint.userEmail}'),
                  ),
                  dense: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complaint Information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Text(complaint.description),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      'Priority',
                      complaint.priority.toString().split('.').last,
                      _getPriorityColor(complaint.priority),
                    ),
                    SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      'Status',
                      complaint.status.toString().split('.').last,
                      _getStatusColor(complaint.status),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attached Images',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: complaint.images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    _openMaximizedCarousel(context, index);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      complaint.images[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (complaint.status == ComplaintStatus.new_complaint)
                  ElevatedButton(
                    onPressed: () => _showStatusUpdateDialog(
                      context,
                      ComplaintStatus.pending,
                    ),
                    child: Text('Mark as In Progress'),
                  ),
                if (complaint.status == ComplaintStatus.pending)
                  ElevatedButton(
                    onPressed: () => _showStatusUpdateDialog(
                      context,
                      ComplaintStatus.closed,
                    ),
                    child: Text('Close Complaint'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
      BuildContext context,
      String label,
      String value,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Colors.green;
      case ComplaintPriority.medium:
        return Colors.orange;
      case ComplaintPriority.high:
        return Colors.red;
      case ComplaintPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.new_complaint:
        return Colors.blue;
      case ComplaintStatus.pending:
        return Colors.orange;
      case ComplaintStatus.closed:
        return Colors.green;
    }
  }

  void _showStatusUpdateDialog(
      BuildContext context,
      ComplaintStatus newStatus,
      ) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newStatus == ComplaintStatus.pending
              ? 'Mark as In Progress'
              : 'Close Complaint',
        ),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: 'Add a note',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onStatusUpdate(newStatus, noteController.text);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
  void _openMaximizedCarousel(BuildContext context, int initialIndex) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: complaint.images.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider:
                    CachedNetworkImageProvider(complaint.images[index]),
                    minScale: PhotoViewComputedScale.covered * 0.2,
                    maxScale: PhotoViewComputedScale.covered,
                  );
                },
                scrollPhysics: BouncingScrollPhysics(),
                backgroundDecoration: BoxDecoration(color: Colors.black),
                pageController: PageController(initialPage: initialIndex),
                onPageChanged: (index) {
                  // setModalState(() {
                  //   _current = index;
                  // });
                },
              ),
              Positioned(
                top: 40,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.grey.shade300, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
      isScrollControlled: true,
    );
  }
}