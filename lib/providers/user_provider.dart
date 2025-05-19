import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

enum UserFilter { newUser, active, removed }

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _error;
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String? get error => _error;

  Stream<List<UserModel>> getUsers({
    UserFilter filter = UserFilter.active,
    String searchQuery = '',
  }) {
    Query query = _firestore.collection('users');

    switch (filter) {
      case UserFilter.newUser:
        final twentyFourHoursAgo = DateTime.now().subtract(Duration(hours: 24));
        query = query
            .where('createdAt', isGreaterThan: twentyFourHoursAgo)
            .where('isActive', isEqualTo: true);
        break;
      case UserFilter.active:
        query = query.where('isActive', isEqualTo: true);
        break;
      case UserFilter.removed:
        query = query.where('isActive', isEqualTo: false);
        break;
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      List<UserModel> users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        users = users.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.phone.contains(query);
        }).toList();
      }

      return users;
    });
  }

  Future<void> createUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  Stream<UserModel?> getCurrentUserStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateLastSeen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateFCMToken(String? token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }
  void handleUserStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        getCurrentUserStream().listen((UserModel? userModel) {
          _currentUser = userModel;
          notifyListeners();
        });
      }
    });
  }
}