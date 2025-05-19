import 'package:compound/screens/inquiry/respond_inquiry_dialog_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inquiry_model.dart';
import '../../providers/inquiry_provider.dart';
import '../../widgets/inquiries/inquiry_list_view.dart';


class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  _InquiriesScreenState createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen>
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
    return Consumer<InquiryProvider>(
      builder: (context, provider, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Inquiries'),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'New'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                StreamBuilder<List<InquiryModel>>(
                  stream: provider.getNewInquiries(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return InquiryListView(
                      inquiries: snapshot.data!,
                      onInquiryTap: (inquiry) => _handleInquiryTap(context, inquiry),
                    );
                  },
                ),
                StreamBuilder<List<InquiryModel>>(
                  stream: provider.getCompletedInquiries(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return InquiryListView(
                      inquiries: snapshot.data!,
                      onInquiryTap: (inquiry) => _handleInquiryTap(context, inquiry),
                      isCompleted: true,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleInquiryTap(BuildContext context, InquiryModel inquiry) async {
    if (!inquiry.isRead) {
      context.read<InquiryProvider>().markAsRead(inquiry.id!);
    }

    if (inquiry.status != InquiryStatus.completed) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => RespondInquiryDialog(inquiry: inquiry),
      );

      if (result != null) {
        final provider = context.read<InquiryProvider>();
        await provider.respondToInquiry(
          inquiryId: inquiry.id!,
          response: result['response'],
          responseType: result['responseType'],
          currentUserLogin: 'Ramy888',
        );

        if (provider.status == InquiryOperationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Response sent successfully')),
          );

          // Handle different response types
          switch (result['responseType']) {
            case ResponseType.chat:
              if (inquiry.type == InquiryType.registered) {
                Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: {'userId': inquiry.userId},
                );
              }
              break;
            case ResponseType.call:
            // Implement call functionality
              break;
            case ResponseType.email:
            // Implement email functionality
              break;
            case ResponseType.notification:
            // Implement notification functionality
              break;
          }
        } else if (provider.status == InquiryOperationStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}