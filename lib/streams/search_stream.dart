import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/last_message_model.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/widgets/chat_widget.dart';
import 'package:provider/provider.dart';

class SearchStream extends StatelessWidget {
  final String uid;
  final String groupId;
  const SearchStream({super.key, required this.uid, this.groupId = ''});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      return StreamBuilder<QuerySnapshot>(
          stream:
              chatProvider.getLastMessageStream(userId: uid, groupId: groupId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No messages yet'));
            }
            final results = snapshot.data!.docs.where((element) =>
                element[Constants.contactName]
                    .toString()
                    .toLowerCase()
                    .contains(
                      chatProvider.searchQuery.toLowerCase(),
                    ));
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final chat = LastMessageModel.fromMap(
                    results.elementAt(index).data() as Map<String, dynamic>);
                return ChatWidget(
                  onTap: () {
                    Navigator.pushNamed(context, Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: chat.contactUID,
                          Constants.groupId: groupId.isEmpty ? '' : groupId,
                          Constants.contactName: chat.contactName,
                          Constants.contactImage: chat.contactImage,
                        });
                  },
                  isGroup: false,
                  chat: chat,
                );
              },
            );
          });
    });
  }
}
