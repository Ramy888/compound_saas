import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'notifications';

  // Replace with your PHP backend URL
  final String _apiUrl = 'https://your-domain.com/api/notifications';

  Stream<List<NotificationModel>> getNotifications({bool activeOnly = true}) {
    Query query = _firestore.collection(_collection);

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> sendNotification(NotificationModel notification) async {
    try {
      // Get current user's ID token
      final String? idToken = await _auth.currentUser?.getIdToken();

      if (idToken == null) {
        throw 'User not authenticated';
      }

      // First save to Firestore
      final docRef = await _firestore.collection(_collection).add(notification.toFirestore());

      // Prepare request data
      final Map<String, dynamic> requestData = {
        'notificationId': docRef.id,
        'title': notification.title,
        'titleAr': notification.titleAr,
        'body': notification.body,
        'bodyAr': notification.bodyAr,
        'topic': notification.topic,
        'data': notification.data,
      };

      // Send request to PHP backend
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode != 200) {
        throw 'Server error: ${response.statusCode}';
      }

      final responseData = json.decode(response.body);

      if (responseData['success'] != true) {
        throw responseData['message'] ?? 'Unknown error';
      }

      // Update the notification with sent status
      await docRef.update({
        'sentAt': FieldValue.serverTimestamp(),
        'recipientsCount': responseData['recipientsCount'] ?? 0,
        'isActive': true,
      });

    } catch (e) {
      throw 'Failed to send notification: $e';
    }
  }

  Future<void> scheduleNotification(NotificationModel notification) async {
    if (notification.scheduledFor == null) {
      throw 'Scheduled time is required';
    }

    try {
      // Get current user's ID token
      final String? idToken = await _auth.currentUser?.getIdToken();

      if (idToken == null) {
        throw 'User not authenticated';
      }

      // First save to Firestore
      final docRef = await _firestore.collection(_collection).add(notification.toFirestore());

      // Prepare request data
      final Map<String, dynamic> requestData = {
        'notificationId': docRef.id,
        'title': notification.title,
        'titleAr': notification.titleAr,
        'body': notification.body,
        'bodyAr': notification.bodyAr,
        'topic': notification.topic,
        'data': notification.data,
        'scheduledFor': notification.scheduledFor!.toIso8601String(),
      };

      // Send request to PHP backend
      final response = await http.post(
        Uri.parse('$_apiUrl/schedule'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode != 200) {
        throw 'Server error: ${response.statusCode}';
      }

      final responseData = json.decode(response.body);

      if (responseData['success'] != true) {
        throw responseData['message'] ?? 'Unknown error';
      }

    } catch (e) {
      throw 'Failed to schedule notification: $e';
    }
  }

  Future<void> toggleNotificationStatus(String notificationId, bool isActive) async {
    await _firestore.collection(_collection).doc(notificationId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}