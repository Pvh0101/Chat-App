import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/main_screen/my_chats_screen.dart';
import 'package:flutter_chat_pro/main_screen/groups_screen.dart';
import 'package:flutter_chat_pro/main_screen/people_screen.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/push_notification/notification_services.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/utilities/global_method.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  List<Widget> pages = const [
    MyChatsScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initClouldMessaging();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  //initialize cloud messaging
  void initClouldMessaging() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //1. generate a token
      await context.read<AuthenticationProvider>().generateNewToken();
      //2. initialize the messaging
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          NotificationServices.displayNotification(message);
        }
      });
    });

    //3. setup onmessage handler
    setupInteractedMessage();
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data[Constants.notificationType] ==
        Constants.chatNotification) {
      //navigate to chat screen
      Navigator.pushNamed(
        context,
        Constants.chatScreen,
        arguments: {
          Constants.contactUID: message.data[Constants.contactUID],
          Constants.contactName: message.data[Constants.contactName],
          Constants.contactImage: message.data[Constants.contactImage],
          Constants.groupId: '',
        },
      );
    }
    if (message.data[Constants.notificationType] ==
        Constants.groupChatNotification) {
      //navigate to group chat screen
      // Navigator.pushNamed(
      //   context,
      //   Constants.groupChatScreen,
      //   arguments: {
      //     Constants.groupId: message.data[Constants.groupId],
      //     Constants.groupName: message.data[Constants.groupName],
      //     Constants.groupImage: message.data[Constants.groupImage],
      //   },
      // );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;

    final authProvider = context.read<AuthenticationProvider>();
    switch (state) {
      case AppLifecycleState.resumed:
        authProvider.updateUserStatus(value: true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        authProvider.updateUserStatus(value: false);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
        floatingActionButton: currentIndex == 1
            ? FloatingActionButton(
                onPressed: () async {
                  await context
                      .read<GroupProvider>()
                      .clearGroupMembersList()
                      .whenComplete(() {
                    Navigator.pushNamed(
                      context,
                      Constants.createGroupScreen,
                    );
                  });
                },
                child: const Icon(CupertinoIcons.add),
              )
            : null,
        appBar: AppBar(
          title: const Text('Flutter Chat Pro'),
          actions: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: userImageWidget(
                    imageUrl: authProvider.userModel!.image,
                    radius: 20,
                    onTap: () {
                      //Navigate to profile screen
                      Navigator.pushNamed(context, Constants.profileScreen,
                          arguments: authProvider.userModel!.uid);
                    })),
          ],
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.group),
              label: 'Group',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.globe),
              label: 'People',
            ),
          ],
          currentIndex: currentIndex,
          onTap: (index) {
            pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ));
  }
}
