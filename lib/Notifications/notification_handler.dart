import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../providers/user_provider.dart';
import 'firebase_options.dart';




// This needs to be defined at the top level (outside any class) as required by Firebase
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  dev.log('Handling a background message: ${message.messageId}');
}

// This needs to be defined at the top level for background notification handling
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle notification tap in background
  dev.log('Notification tapped in background: ${notificationResponse.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FirebaseMessaging _messaging;
  AndroidNotificationChannel? _channel;
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  final StreamController<String?> selectNotificationStream =
  StreamController<String?>.broadcast();
  final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
  StreamController<ReceivedNotification>.broadcast();

  bool _isInitialized = false;
  final UserProvider _userProvider = UserProvider();
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeFirebase();
    _messaging = FirebaseMessaging.instance;

    // Set up notification channels and permissions
    await _setupNotificationChannel();

    // Set up notification handlers
    _setupNotificationHandlers();

    // Add token refresh listener
    setupTokenRefreshListener();

    _isInitialized = true;
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (e.toString().contains('already exists')) {
        // Firebase already initialized
        return;
      }
      rethrow;
    }
  }

  //for older versions of ios
  void _onDidReceiveLocalNotification(
      int id,
      String? title,
      String? body,
      String? payload,
      ) {
    dev.log('Received local notification: $id, $title, $body, $payload');
    didReceiveLocalNotificationStream.add(
      ReceivedNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    dev.log('Notification response received: ${response.payload}');
    selectNotificationStream.add(response.payload);
  }

  Future<void> _setupNotificationChannel() async {
    if (!_isWeb) {
      _channel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true,
      );

      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await _flutterLocalNotificationsPlugin?.initialize(
        InitializationSettings(
          android: const AndroidInitializationSettings('logo'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
          ),
        ),
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Create the Android notification channel
      await _flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel!);
    }
  }

  Future<bool> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<bool> setupNotificationPermissions() async {
    final bool permissionGranted = await requestPermission();

    if (permissionGranted) {
      final fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        final _jwtToken = await getToken();
        // Store or update FCM token as needed
        if(_jwtToken != null) {
          await _updateFcmToken(fcmToken);
          await _messaging.subscribeToTopic("ya3niLoggedInUsers");
        }else{
          await _updateGuestFcmToken(fcmToken);
        }
      }
      return permissionGranted;
    }
    return false;
  }

  void _setupNotificationHandlers() {
    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Message open handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // Check for initial message
    _checkInitialMessage();
  }


  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {

      await _flutterLocalNotificationsPlugin?.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel!.id,
            _channel!.name,
            icon: 'logo',
            priority: Priority.high,
            importance: Importance.max,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<void> _handleMessageOpened(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationTapped', true);
    _handleNotificationAction(message.data);
  }

  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationAction(initialMessage.data);
    }
  }

  void _handleNotificationAction(Map<String, dynamic> data) {
    dev.log('Handling notification action with data: $data');
    selectNotificationStream.add(jsonEncode(data));

    if (data['access_code'] != null) {

      navigateToChat(data['access_code']);

    }else if (data['news'] != null){
      //go to show news
    }else if(data['fromUser'] != null){
      navigateToDeveloperNotifications();
    }
  }

  void navigateToChat(String code) async {
    // final context = navigatorKey.currentContext;
    // if (context == null) return;
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ChatPage()),
    // );

  }


  void navigateToDeveloperNotifications() async {
    // final context = navigatorKey.currentContext;
    // if (context != null) {
    //   try {
    //     final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    //     if (renderBox == null) return;
    //
    //     // Get the size and position of the VideoCard
    //     final Size size = renderBox.size;
    //     final Offset position = renderBox.localToGlobal(Offset.zero);
    //     final Rect sourceRect = Rect.fromLTWH(
    //       position.dx,
    //       position.dy,
    //       size.width,
    //       size.height,
    //     );
    //
    //     Navigator.of(context).push(
    //       VideoPageRoute(
    //         page: const NotificationsFromUsersScreen(),
    //         sourceRect: sourceRect,
    //         screenSize: MediaQuery.of(context).size,
    //       ),
    //     );
    //
    //   } catch (e) {
    //     dev.log('Error navigating to video: $e');
    //   }
    // }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      dev.log('Error reading token: $e');
      return null;
    }
  }

  Future<void> _updateFcmToken(String token) async {
    try {
      // Save token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      await _messaging.subscribeToTopic("ya3niNews");

      // Get current user email
      final jwtToken = await getToken();

      // Update token in backend
      // final success = await _fcmTokenService.updateFCMToken(
      //   token: jwtToken!,
      //   fcmToken: token,
      // );
      _userProvider.updateFCMToken(jwtToken);

      // if (success) {
      //   dev.log('FCM token updated successfully');
      // } else {
      //   dev.log('Failed to update FCM token in backend');
      // }
    } catch (e) {
      dev.log('Error updating FCM token: $e');
    }
  }

  Future<void> _updateGuestFcmToken(String token) async {
    try {
      // Save token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final oldToken = prefs.getString('fcm_token');

      // Only update if token is different
      if (oldToken != token) {
        await prefs.setString('fcm_token', token);

        // Subscribe to topic for guests
        await _messaging.subscribeToTopic("CompoundAdminNews");

        // Update token in backend
        // final success = await _guestFCMService.updateGuestFCMToken(
        //   fcmToken: token,
        // );

        // if (success) {
        //   dev.log('Guest FCM token updated successfully: $token');
        // } else {
        //   dev.log('Failed to update guest FCM token in backend');
        // }
      }
    } catch (e) {
      dev.log('Error updating guest FCM token: $e');
    }
  }

  void setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((fcmToken) async {
      final _jwtToken = await getToken();
      // Store or update FCM token as needed
      if(_jwtToken != null) {
        await _updateFcmToken(fcmToken);
        await _messaging.subscribeToTopic("ya3niLoggedInUsers");
      }else{
        await _updateGuestFcmToken(fcmToken);
      }
    }).onError((err) {
      dev.log('Error getting new FCM token: $err');
    });
  }


  Future<String> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token') ?? '';
  }

  void dispose() {
    selectNotificationStream.close();
    didReceiveLocalNotificationStream.close();
  }

  bool get _isWeb => identical(0, 0.0);
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}