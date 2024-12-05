import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/widgets/align_message_left_widget.dart';
import 'package:flutter_chat_pro/widgets/align_message_right_widget.dart';
import 'package:flutter_chat_pro/widgets/swipe_to_widget.dart';

class MessageWidget extends StatelessWidget {
  final MessageModel message;
  final Function onRightSwipe;
  final bool isViewOnly;
  final bool isMe;
  final bool isGroupChat;

  const MessageWidget(
      {super.key,
      required this.isGroupChat,
      required this.message,
      required this.onRightSwipe,
      required this.isViewOnly,
      required this.isMe});

  @override
  Widget build(BuildContext context) {
    return isMe
        ? isViewOnly
            ? AlignMessageRightWidget(
                message: message, isGroupChat: isGroupChat)
            : SwipeToWidger(
                isGroupChat: isGroupChat,
                onRightSwipe: onRightSwipe,
                message: message,
                isMe: isMe,
              )
        : isViewOnly
            ? AlignMessageLeftWidget(message: message, isGroupChat: isGroupChat)
            : SwipeToWidger(
                onRightSwipe: onRightSwipe,
                message: message,
                isMe: isMe,
                isGroupChat: isGroupChat,
              );
  }
}
