import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/last_message_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/widgets/chat_widget.dart';
import 'package:provider/provider.dart';

class ChatsStream extends StatelessWidget {
  final String uid;
  final String groupId;
  const ChatsStream({super.key, required this.uid, this.groupId = ''});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return StreamBuilder<List<LastMessageModel>>(
      stream: context.read<ChatProvider>().getChatListStream(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No chats found'));
        }

        List<LastMessageModel> chatsList = snapshot.data!;

        return ListView.builder(
          itemCount: chatsList.length,
          itemBuilder: (context, index) {
            final chat = chatsList[index];
            return ChatWidget(
              isGroup: false,
              chat: chat,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Constants.chatScreen,
                  arguments: {
                    Constants.contactUID: chat.contactUID,
                    Constants.contactName: chat.contactName,
                    Constants.contactImage: chat.contactImage,
                    Constants.groupId: '',
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
