import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'complaints';

  Stream<List<ComplaintModel>> getComplaints(ComplaintStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.toString())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ComplaintModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus newStatus,
    String? closureNote,
    String? assignedTo,
    String? closedBy,
  }) async {
    final Map<String, dynamic> updateData = {
      'status': newStatus.toString(),
      'updatedAt': Timestamp.now(),
    };

    if (newStatus == ComplaintStatus.pending) {
      updateData['assignedTo'] = assignedTo;
    } else if (newStatus == ComplaintStatus.closed) {
      updateData['closedBy'] = closedBy;
      updateData['closedAt'] = Timestamp.now();
      updateData['closureNote'] = closureNote;
    }

    await _firestore
        .collection(_collection)
        .doc(complaintId)
        .update(updateData);
  }

  Future<void> markAsRead(String complaintId) async {
    await _firestore
        .collection(_collection)
        .doc(complaintId)
        .update({'isRead': true});
  }
}