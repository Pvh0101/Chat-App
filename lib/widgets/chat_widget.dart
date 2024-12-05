import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/models/last_message_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/global_method.dart';
import 'package:flutter_chat_pro/widgets/display_message_type.dart';
import 'package:flutter_chat_pro/widgets/unread_message_counter.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    this.chat,
    required this.onTap,
    this.group,
    required this.isGroup,
  });

  final LastMessageModel? chat;
  final GroupModel? group;
  final Function() onTap;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    // get the last message
    final lastMessage = chat != null ? chat!.message : group!.lastMessage;
    //get the senderuid
    final senderUID = chat != null ? chat!.senderUID : group!.senderUID;
    // get the date time
    final timeSent = chat != null ? chat!.timeSent : group!.timeSent;
    final dateTime = formatDate(timeSent, [hh, ':', nn, ' ', am]);
    // final time = formatDate(timeSent, [hh, ':', nn]);
    //get the image url
    final imageUrl = chat != null ? chat!.contactImage : group!.groupImage;
    //get the name
    final name = chat != null ? chat!.contactName : group!.groupName;
    //get the message type
    final messageType = chat != null ? chat!.messageType : group!.messageType;
    //get the contactUID
    final contactUID = chat != null ? chat!.contactUID : group!.groupId;

    return ListTile(
      contentPadding: const EdgeInsets.only(right: 10),
      leading: userImageWidget(
        imageUrl: imageUrl,
        radius: 40,
        onTap: () {},
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          uid == senderUID
              ? const Text('You: ',
                  style: TextStyle(fontWeight: FontWeight.w500))
              : const SizedBox(),
          DisplayMessageType(
            type: messageType,
            message: lastMessage,
            color: Theme.of(context).colorScheme.secondary,
            viewOnly: true,
            isReply: true,
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Text(
              dateTime,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            UnreadMessageCounter(
                uid: uid, contactUID: contactUID, isGroup: isGroup),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
