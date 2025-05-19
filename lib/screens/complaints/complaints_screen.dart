import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint_model.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/complaints/complaint_detail_sheet.dart';
import '../../widgets/complaints/complaints_list_view.dart';


class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  _ComplaintsScreenState createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Complaints'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'New'),
                Tab(text: 'Pending'),
                Tab(text: 'Closed'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // New Complaints Tab
              StreamBuilder<List<ComplaintModel>>(
                stream: provider.getNewComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ComplaintListView(
                    complaints: snapshot.data!,
                    onComplaintTap: (complaint) => _handleComplaintTap(
                      context,
                      complaint,
                      provider,
                    ),
                  );
                },
              ),
              // Pending Complaints Tab
              StreamBuilder<List<ComplaintModel>>(
                stream: provider.getPendingComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ComplaintListView(
                    complaints: snapshot.data!,
                    onComplaintTap: (complaint) => _handleComplaintTap(
                      context,
                      complaint,
                      provider,
                    ),
                  );
                },
              ),
              // Closed Complaints Tab
              StreamBuilder<List<ComplaintModel>>(
                stream: provider.getClosedComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ComplaintListView(
                    complaints: snapshot.data!,
                    onComplaintTap: (complaint) => _handleComplaintTap(
                      context,
                      complaint,
                      provider,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleComplaintTap(
      BuildContext context,
      ComplaintModel complaint,
      ComplaintProvider provider,
      ) async {
    if (!complaint.isRead) {
      provider.markAsRead(complaint.id!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ComplaintDetailsSheet(
        complaint: complaint,
        onStatusUpdate: (newStatus, note) async {
          await provider.updateComplaintStatus(
            complaintId: complaint.id!,
            newStatus: newStatus,
            closureNote: note,
            currentUserLogin: 'Ramy888',
            assignedTo: 'Ramy888',
          );

          if (provider.status == ComplaintOperationStatus.success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Complaint status updated successfully')),
            );
          } else if (provider.status == ComplaintOperationStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${provider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}