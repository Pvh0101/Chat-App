import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/widgets/friends_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

Widget userImageWidget({
  required String imageUrl,
  File? fileImage,
  required double radius,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      radius: radius,
      backgroundImage: getImageToShow(
        imageUrl: imageUrl,
        fileImage: fileImage,
      ),
    ),
  );
}

getImageToShow({required String imageUrl, required File? fileImage}) {
  return fileImage != null
      ? FileImage(File(fileImage.path)) as ImageProvider
      : imageUrl.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl)
          : const AssetImage(AssetsManager.userImage);
}

//pick image from gallery or camera
Future<File?> pickImage({
  required bool fromCamera,
  required Function(String) onFail,
}) async {
  File? fileImage;
  if (fromCamera) {
    //get image from camera
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return null;
      fileImage = File(image.path);
    } catch (e) {
      onFail(
        e.toString(),
      );
    }
  } else {
    //get image from gallery
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      fileImage = File(image.path);
    } catch (e) {
      onFail(
        e.toString(),
      );
    }
  }
  return fileImage;
}

// pick video  from gallery
Future<File?> pickVideo({
  required Function(String) onFail,
}) async {
  try {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      return File(video.path);
    } else {
      onFail("No video selected");
      return null;
    }
  } catch (e) {
    onFail(
      e.toString(),
    );
    return null;
  }
}

SizedBox buildDateTime(MessageModel message) {
  return SizedBox(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 70,
          child: Divider(
            color: Colors.grey,
            thickness: 1.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            formatDate(message.timeSent, [dd, ' ', M, ' ', yyyy]),
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(
          width: 70,
          child: Divider(
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

Widget messageToShow(
    {required MessageEnum type,
    required String message,
    required MessageEnum messageType}) {
  switch (type) {
    case MessageEnum.text:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    case MessageEnum.image:
      return const Row(
        children: [
          Icon(Icons.image_outlined),
          SizedBox(width: 10),
          Text(
            'Image',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.video:
      return const Row(
        children: [
          Icon(Icons.video_library_outlined),
          SizedBox(width: 10),
          Text(
            'Video',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.audio:
      return const Row(
        children: [
          Icon(Icons.audiotrack_outlined),
          SizedBox(width: 10),
          Text(
            'Audio',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    default:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
  }
}

// store file to storage and return file url
Future<String> storeFileToStorage({
  required File file,
  required String reference,
}) async {
  UploadTask uploadTask =
      FirebaseStorage.instance.ref().child(reference).putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask;
  String fileUrl = await taskSnapshot.ref.getDownloadURL();
  return fileUrl;
}

// animated dialog
void showMyAnimatedDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String textAction,
  required Function(bool) onActionTap,
  bool editable = false,
  String hintText = '',
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
          child: AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: editable
                ? Consumer<AuthenticationProvider>(
                    builder: (context, authProvider, child) {
                      return TextField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: hintText,
                        ),
                        onChanged: (value) {
                          print('content: $content'); // Xem giá trị của content
                          if (content == Constants.changeName) {
                            authProvider.setName(value);
                          } else if (content == Constants.changeDesc) {
                            authProvider.setDesc(value);
                            print("$value");
                          }
                        },
                      );
                    },
                  )
                : Text(
                    content,
                    textAlign: TextAlign.center,
                  ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onActionTap(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onActionTap(true);
                },
                child: Text(textAction),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// show bottom sheet with the list of all app users to add them to the group
void showAddMembersBottomSheet({
  required BuildContext context,
  required List<String> groupMembersUIDs,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SizedBox(
        height: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      onChanged: (value) {
                        // search for users
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // close bottom sheet
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.grey,
            ),
            Expanded(
              child: FriendsList(
                viewType: FriendViewType.groupView,
                groupMembersUIDs: groupMembersUIDs,
              ),
            ),
          ],
        ),
      );
    },
  );
}
