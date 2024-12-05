import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/widgets/audio_player_widget.dart';
import 'package:flutter_chat_pro/widgets/video_player_widget.dart';

class DisplayMessageType extends StatelessWidget {
  final String message;
  final MessageEnum type;
  final Color color;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isReply;
  final bool viewOnly;

  const DisplayMessageType({
    super.key,
    required this.message,
    required this.type,
    required this.color,
    this.maxLines,
    this.overflow,
    required this.viewOnly,
    required this.isReply,
  });

  @override
  Widget build(BuildContext context) {
    Widget messageToShow() {
      switch (type) {
        case MessageEnum.text:
          return Text(
            message,
            maxLines: maxLines,
            overflow: overflow,
            style: TextStyle(
              color: color,
              fontSize: 16,
            ),
          );
        case MessageEnum.image:
          return isReply
              ? const Row(children: [
                  Icon(Icons.image_outlined),
                  SizedBox(width: 5),
                  Text("Image")
                ])
              : CachedNetworkImage(
                  imageUrl: message,
                  fit: BoxFit.cover,
                );

        case MessageEnum.audio:
          return isReply
              ? const Row(children: [
                  Icon(Icons.audiotrack_outlined),
                  SizedBox(width: 5),
                  Text("Audio")
                ])
              : AudioPlayerWidget(
                  audioUrl: message,
                  color: color,
                  viewOnly: viewOnly,
                );

        case MessageEnum.video:
          return isReply
              ? const Row(children: [
                  Icon(Icons.video_collection_outlined),
                  SizedBox(width: 5),
                  Text("Video")
                ])
              : VideoPlayerWidget(
                  videoUrl: message, // URL của video
                  color: color,
                  viewOnly: viewOnly,
                );

        default:
          return Text(
            message,
            maxLines: maxLines,
            overflow: overflow,
            style: TextStyle(
              color: color,
              fontSize: 16,
            ),
          );
      }
    }

    return messageToShow();
  }
}
