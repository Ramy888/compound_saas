import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of current user's authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithPhoneAndCode(String phone, String code) async {
    try {
      // Query Firestore for user with matching phone
      final QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .where('isActive', isEqualTo: true)
          .where('isAdmin', isEqualTo: true)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('No admin found with this phone number');
      }

      final userData = userQuery.docs.first;
      final String storedCode = userData.get('accessCode') ?? '';
      final DateTime? codeExpiry = userData.get('accessCodeExpiry') != null
          ? (userData.get('accessCodeExpiry') as Timestamp).toDate()
          : null;

      // Verify code and expiry
      if (storedCode != code) {
        throw Exception('Invalid access code');
      }

      if (codeExpiry == null || codeExpiry.isBefore(DateTime.now())) {
        throw Exception('Access code has expired');
      }

      // Sign in with Firebase Auth
      await _auth.signInWithCustomToken(await _generateCustomToken(userData.id));

      // Update user data
      await _firestore.collection('users').doc(userData.id).update({
        'lastSeen': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'accessCode': null,
        'accessCodeExpiry': null,
      });

      return UserModel.fromFirestore(userData);

    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> requestAccessCode(String phone) async {
    try {
      final QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .where('isActive', isEqualTo: true)
          .where('isAdmin', isEqualTo: true)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('No admin found with this phone number');
      }

      // Generate a 6-digit code
      final String code = (100000 + DateTime.now().microsecond % 900000).toString();

      // Set code expiry to 5 minutes from now
      final DateTime expiry = DateTime.now().add(Duration(minutes: 5));

      // Update user with new code
      await _firestore.collection('users').doc(userQuery.docs.first.id).update({
        'accessCode': code,
        'accessCodeExpiry': Timestamp.fromDate(expiry),
        'codeRequestedAt': FieldValue.serverTimestamp(),
      });

      // TODO: Send SMS with code using your SMS service
      // For development, print the code
      print('Access code for $phone: $code');

    } catch (e) {
      print('Error requesting access code: $e');
      rethrow;
    }
  }

  Future<String> _generateCustomToken(String userId) async {
    // In a production environment, this should be implemented with Firebase Admin SDK
    // For development, you might want to use a Cloud Function
    throw UnimplementedError('Custom token generation needs to be implemented');
  }

  Future<void> signOut() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}