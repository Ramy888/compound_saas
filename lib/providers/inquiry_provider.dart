import 'package:flutter/material.dart';
import '../models/inquiry_model.dart';
import '../services/inquiry_service.dart';

enum InquiryOperationStatus {
  initial,
  loading,
  success,
  error
}

class InquiryProvider extends ChangeNotifier {
  final InquiryService _inquiryService = InquiryService();
  InquiryOperationStatus _status = InquiryOperationStatus.initial;
  String? _error;
  bool _isLoading = false;

  InquiryOperationStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Stream<List<InquiryModel>> getNewInquiries({InquiryType? type}) {
    return _inquiryService.getInquiries(
      isCompleted: false,
      type: type,
    );
  }

  Stream<List<InquiryModel>> getCompletedInquiries({InquiryType? type}) {
    return _inquiryService.getInquiries(
      isCompleted: true,
      type: type,
    );
  }

  Future<void> respondToInquiry({
    required String inquiryId,
    required String response,
    required ResponseType responseType,
    String? currentUserLogin,
  }) async {
    try {
      _setLoading(true);
      _status = InquiryOperationStatus.loading;

      await _inquiryService.respondToInquiry(
        inquiryId: inquiryId,
        response: response,
        responseType: responseType,
        respondedBy: currentUserLogin ?? 'Unknown',
      );

      _status = InquiryOperationStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = InquiryOperationStatus.error;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> markAsRead(String inquiryId) async {
    try {
      await _inquiryService.markAsRead(inquiryId);
    } catch (e) {
      _error = e.toString();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetStatus() {
    _status = InquiryOperationStatus.initial;
    _error = null;
    notifyListeners();
  }
}