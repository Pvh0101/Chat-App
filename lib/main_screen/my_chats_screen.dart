import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/streams/chats_stream.dart';
import 'package:flutter_chat_pro/streams/search_stream.dart';
import 'package:flutter_chat_pro/widgets/search_widget.dart';
import 'package:provider/provider.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return Scaffold(
        body: Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      return Column(
        children: [
          // Cupertino search bar
          SearchWidget(onChanged: (value) {
            chatProvider.setSearchQuery(value);
          }),

          Expanded(
            child: chatProvider.searchQuery.isEmpty
                ? ChatsStream(uid: uid)
                : SearchStream(uid: uid),
          ),
        ],
      );
    }));
  }
}
