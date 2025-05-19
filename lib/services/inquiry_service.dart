import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inquiry_model.dart';

class InquiryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'inquiries';

  Stream<List<InquiryModel>> getInquiries({
    required bool isCompleted,
    InquiryType? type,
  }) {
    Query query = _firestore.collection(_collection);

    if (isCompleted) {
      query = query.where('status', isEqualTo: InquiryStatus.completed.toString());
    } else {
      query = query.where('status', whereIn: [
        InquiryStatus.new_inquiry.toString(),
        InquiryStatus.in_progress.toString(),
      ]);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString());
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InquiryModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> respondToInquiry({
    required String inquiryId,
    required String response,
    required ResponseType responseType,
    required String respondedBy,
  }) async {
    await _firestore.collection(_collection).doc(inquiryId).update({
      'status': InquiryStatus.completed.toString(),
      'response': response,
      'responseType': responseType.toString(),
      'respondedAt': Timestamp.now(),
      'respondedBy': respondedBy,
    });
  }

  Future<void> markAsRead(String inquiryId) async {
    await _firestore.collection(_collection).doc(inquiryId).update({
      'isRead': true,
    });
  }
}