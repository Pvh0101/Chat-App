import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/main_screen/group_settings_screen.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';

import 'package:flutter_chat_pro/utilities/global_method.dart';
import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
import 'package:flutter_chat_pro/widgets/display_user_image.dart';
import 'package:flutter_chat_pro/widgets/friends_list.dart';
import 'package:flutter_chat_pro/widgets/group_type_list_tile.dart';
import 'package:flutter_chat_pro/widgets/setting_list_tile.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  //group name controoller
  final TextEditingController groupNameController = TextEditingController();
  // group description controller
  final TextEditingController groupDescriptionController =
      TextEditingController();
  GroupType groupValue = GroupType.private;
  String userImage = '';
  File? finalFileImage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //dispose controller
  @override
  void dispose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    super.dispose();
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );
    //crop image
    await cropImage(finalFileImage?.path);
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    //crop image
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        compressQuality: 90,
        maxWidth: 800,
        maxHeight: 800,
      );
      // Navigator.of(context).pop();
      if (croppedFile != null) {
        setState(() {
          userImage = croppedFile.path;
        });
      } else {
        // Navigator.pop(context);
      }
    }
  }

  void showBottonSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  selectImage(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
                onTap: () {
                  selectImage(false);
                },
              ),
            ],
          );
        });
  }

  void createGroup() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final groupProvider = context.read<GroupProvider>();

    ///check if group name is empty and name is less than 3 characters
    if (groupNameController.text.isEmpty ||
        groupNameController.text.length < 3) {
      showSnackBar(context, 'Group name must be at least 3 characters long');
      return;
    }

    ///check if group description is empty
    if (groupDescriptionController.text.isEmpty) {
      showSnackBar(context, 'Group description is required');
      return;
    }

    // ///check if group image is empty
    // if (userImage.isEmpty) {
    //   showSnackBar(context, 'Group image is required');
    //   return;
    // }

    ///create group
    GroupModel groupModel = GroupModel(
      creatorUID: uid,
      groupName: groupNameController.text,
      groupDescription: groupDescriptionController.text,
      groupImage: '',
      groupId: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageId: '',
      timeSent: DateTime.now(),
      createdAt: DateTime.now(),
      isPrivate: groupValue == GroupType.private ? true : false,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoing: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );
    groupProvider.createGroup(
      newGroupModel: groupModel,
      fileImage: finalFileImage,
      onSuccess: () {
        showSnackBar(context, 'Group created successfully');
        Navigator.pop(context);
      },
      onFail: (String error) {
        showSnackBar(context, error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child:
                  // context.watch<GroupProvider>().isLoading
                  //     ? const CircularProgressIndicator()
                  //     :
                  IconButton(
                onPressed: () {
                  createGroup();
                },
                icon: const Icon(Icons.done),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DisplayUserImage(
                    finalFileImage: finalFileImage,
                    onPressed: () {
                      showBottonSheet();
                    },
                    radius: 60),
                buildGroupType(),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            //textfield for group name
            TextField(
              controller: groupNameController,
              maxLength: 25,
              decoration: const InputDecoration(
                hintText: 'Group Name',
                border: OutlineInputBorder(),
                label: Text('Group Name'),
                counterText: '',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            //textfield for group description
            TextField(
              controller: groupDescriptionController,
              maxLength: 100,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Group Description',
                border: OutlineInputBorder(),
                label: Text('Group Description'),
                counterText: '',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              child: SettingsListTile(
                  title: "Group Settings",
                  icon: Icons.settings,
                  iconContainerColor: Colors.deepPurple,
                  onTap: () {
                    // navigate to group settings screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GroupSettingsScreen()));
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Select Group Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            CupertinoSearchTextField(
              placeholder: "Search",
              onChanged: (value) {
                // search user
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const Expanded(
              child: FriendsList(
                viewType: FriendViewType.groupView,
              ),
            )
          ],
        ),
      ),
    );
  }

  Column buildGroupType() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.private.name,
            value: GroupType.private,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.public.name,
            value: GroupType.public,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
      ],
    );
  }
}
