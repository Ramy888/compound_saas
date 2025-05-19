import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';

enum ComplaintOperationStatus {
  initial,
  loading,
  success,
  error
}

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();
  ComplaintOperationStatus _status = ComplaintOperationStatus.initial;
  String? _error;
  bool _isLoading = false;

  ComplaintOperationStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Stream<List<ComplaintModel>> getNewComplaints() {
    return _complaintService.getComplaints(ComplaintStatus.new_complaint);
  }

  Stream<List<ComplaintModel>> getPendingComplaints() {
    return _complaintService.getComplaints(ComplaintStatus.pending);
  }

  Stream<List<ComplaintModel>> getClosedComplaints() {
    return _complaintService.getComplaints(ComplaintStatus.closed);
  }

  Future<void> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus newStatus,
    String? closureNote,
    String? assignedTo,
    String? currentUserLogin,
  }) async {
    try {
      _setLoading(true);
      _status = ComplaintOperationStatus.loading;

      await _complaintService.updateComplaintStatus(
        complaintId: complaintId,
        newStatus: newStatus,
        closureNote: closureNote,
        assignedTo: assignedTo,
        closedBy: newStatus == ComplaintStatus.closed ? currentUserLogin : null,
      );

      _status = ComplaintOperationStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = ComplaintOperationStatus.error;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> markAsRead(String complaintId) async {
    try {
      await _complaintService.markAsRead(complaintId);
    } catch (e) {
      _error = e.toString();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetStatus() {
    _status = ComplaintOperationStatus.initial;
    _error = null;
    notifyListeners();
  }
}