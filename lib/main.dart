import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/authentication/landing_screen.dart';
import 'package:flutter_chat_pro/authentication/login_screen.dart';
import 'package:flutter_chat_pro/authentication/otp_screen.dart';
import 'package:flutter_chat_pro/authentication/user_infomation_screen.dart';
import 'package:flutter_chat_pro/firebase_options.dart';
import 'package:flutter_chat_pro/main_screen/chat_screen.dart';
import 'package:flutter_chat_pro/main_screen/create_group_screen.dart';
import 'package:flutter_chat_pro/main_screen/friend_requests_screen.dart';
import 'package:flutter_chat_pro/main_screen/friends_screen.dart';
import 'package:flutter_chat_pro/main_screen/group_information_screen.dart';
import 'package:flutter_chat_pro/main_screen/group_settings_screen.dart';
import 'package:flutter_chat_pro/main_screen/home_screen.dart';
import 'package:flutter_chat_pro/main_screen/profile_screen.dart';

import 'package:flutter_chat_pro/main_screen/settings_screen.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/push_notification/notification_services.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,

  print("Handling a background message: ${message.messageId}");
  print("Handling a background message: ${message.notification?.title}");
  print("Handling a background message: ${message.notification?.body}");
  print("Handling a background message: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Platform.isAndroid
      ? NotificationServices.createNotificationChannelAndinitialize()
      : null;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => GroupProvider()),
  ], child: MyApp(savedThemeMode: savedThemeMode)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode});
  final AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.deepPurple,
        ),
        dark: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.deepPurple,
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Flutter Chat Pro',
                theme: theme,
                darkTheme: darkTheme,
                initialRoute: Constants.landingScreen,
                routes: {
                  Constants.landingScreen: (context) => const LandingScreen(),
                  Constants.loginScreen: (context) => const LoginScreen(),
                  Constants.otpScreen: (context) => const OTPScreen(),
                  Constants.userInformationScreen: (context) =>
                      const UserInformationScreen(),
                  Constants.homeScreen: (context) => const HomeScreen(),
                  Constants.chatScreen: (context) => const ChatScreen(),
                  Constants.profileScreen: (context) => const ProfileScreen(),
                  Constants.settingsScreen: (context) => const SettingsScreen(),
                  Constants.friendsScreen: (context) => const FriendsScreen(),
                  Constants.friendRequestsScreen: (context) =>
                      const FriendRequestScreens(),
                  Constants.groupSettingsScreen: (context) =>
                      const GroupSettingsScreen(),
                  Constants.createGroupScreen: (context) =>
                      const CreateGroupScreen(),
                  Constants.groupInformationScreen: (context) =>
                      const GroupInformationScreen(),
                }));
  }
}
