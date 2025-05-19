import 'package:compound/providers/chat_provider.dart';
import 'package:compound/providers/complaint_provider.dart';
import 'package:compound/providers/inquiry_provider.dart';
import 'package:compound/providers/news_provider.dart';
import 'package:compound/providers/notification_provider.dart';
import 'package:compound/providers/offers_provider.dart';
import 'package:compound/providers/project_provider.dart';
import 'package:compound/providers/user_provider.dart';
import 'package:compound/providers/video_provider.dart';
import 'package:compound/screens/chat/chats_screen.dart';
import 'package:compound/screens/complaints/complaints_screen.dart';
import 'package:compound/screens/dashboard_screen.dart';
import 'package:compound/screens/inquiry/inquiry_screen.dart';
import 'package:compound/screens/login_screen.dart';
import 'package:compound/screens/news/add_news_screen.dart';
import 'package:compound/screens/news/news_screen.dart';
import 'package:compound/screens/notifications/notifications_screen.dart';
import 'package:compound/screens/offers/offers_screen.dart';
import 'package:compound/screens/projects/add_project_screen.dart';
import 'package:compound/screens/projects/projects_screen.dart';
import 'package:compound/screens/users/users_screen.dart';
import 'package:compound/screens/videos/videos_screen.dart';
import 'package:compound/test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..handleUserStatus(), // Initialize user status
        ),
        ChangeNotifierProxyProvider<UserProvider, ChatProvider>(
          create: (context) => ChatProvider(context.read<UserProvider>()),
          update: (context, userProvider, previous) =>
          previous ?? ChatProvider(userProvider),
        ),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => InquiryProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        // ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compound Management',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // Or ThemeMode.light/dark based on user preference
      home: Parentwidget(),
      // initialRoute: '/login',
      // routes: {
      //   '/login': (context) => LoginScreen(),
      //   '/dashboard': (context) => DashboardScreen(),
      //   '/add_project': (context) => AddProjectScreen(),
      //   '/projects': (context) => ProjectsScreen(),
      //   '/inquiries': (context) => InquiriesScreen(),
      //   '/complaint': (context) => ComplaintsScreen(),
      //   '/news': (context) => NewsScreen(),
      //   '/add-news': (context) => AddNewsScreen(),
      //   '/videos': (context) => VideosScreen(),
      //   '/notifications': (context) => NotificationsScreen(),
      //   '/users': (context) => UsersScreen(),
      //   '/offers': (context) => OffersScreen(),
      //   '/chats': (context) => ChatsScreen(),
      // },
    );
  }
}
