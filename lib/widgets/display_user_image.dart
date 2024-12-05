import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';

class DisplayUserImage extends StatelessWidget {
  final File? finalFileImage;
  final VoidCallback onPressed;
  final double radius;
  const DisplayUserImage(
      {super.key,
      required this.finalFileImage,
      required this.onPressed,
      required this.radius});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        finalFileImage == null
            ? CircleAvatar(
                radius: radius,
                backgroundImage: const AssetImage(AssetsManager.userImage))
            : CircleAvatar(
                radius: radius,
                backgroundImage: FileImage(File(finalFileImage!.path)),
              ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: onPressed,
            child: const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.camera_alt,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
