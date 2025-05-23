import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/utilities/global_method.dart';
import 'package:flutter_chat_pro/widgets/profile_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InfoDetailsCard extends StatelessWidget {
  const InfoDetailsCard({
    super.key,
    this.groupProvider,
    this.isAdmin,
    this.userModel,
  });

  final GroupProvider? groupProvider;
  final bool? isAdmin;
  final UserModel? userModel;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final uid = authProvider.userModel!.uid;
    final phoneNumber = authProvider.userModel!.phoneNumber;

    // get profile image
    final profileImage = userModel != null
        ? userModel!.image
        : groupProvider!.groupModel.groupImage;
    // get profile name
    final profileName = userModel != null
        ? userModel!.name
        : groupProvider!.groupModel.groupName;

    // get group description
    final aboutMe = userModel != null
        ? userModel!.aboutMe
        : groupProvider!.groupModel.groupDescription;
    // get group id
    final isGroup = userModel != null ? false : true;
    Widget getEditWidget(String title, String content) {
      if (isGroup) {
        if (isAdmin!) {
          return InkWell(
            onTap: () {
              showMyAnimatedDialog(
                context: context,
                title: "Change Name",
                content: content,
                textAction: 'Change',
                onActionTap: (value) {
                  if (value) {
                    if (content == Constants.changeName) {
                      authProvider.updateName(
                        isGroup: isGroup,
                        id: isGroup ? groupProvider!.groupModel.groupId : uid,
                        oldName: profileName,
                      );
                    }
                  } else if (content == Constants.changeDesc) {
                    authProvider.updateStatus(
                      isGroup: isGroup,
                      id: isGroup ? groupProvider!.groupModel.groupId : uid,
                      oldDesc: aboutMe,
                    );
                  }
                },
                editable: true,
                hintText:
                    content == Constants.changeName ? profileName : aboutMe,
              );
            },
            child: const Icon(
              Icons.edit_rounded,
            ),
          );
        } else {
          return const SizedBox();
        }
      } else {
        return InkWell(
          onTap: () {
            showMyAnimatedDialog(
              context: context,
              title: title,
              content: content,
              textAction: 'Change',
              onActionTap: (value) async {
                if (value) {
                  if (content == Constants.changeName) {
                    final name = await authProvider.updateName(
                      isGroup: isGroup,
                      id: isGroup ? groupProvider!.groupModel.groupId : uid,
                      oldName: profileName,
                    );
                    if (isGroup) {
                      if (name == "Invalid Name") return;
                      groupProvider!.setGroupName(name);
                    }
                  } else if (content == Constants.changeDesc) {
                    final desc = await authProvider.updateStatus(
                      isGroup: isGroup,
                      id: isGroup ? groupProvider!.groupModel.groupId : uid,
                      oldDesc: aboutMe,
                    );
                    if (isGroup) {
                      if (desc == "Invalid Description") return;
                      groupProvider!.setGroupDescription(desc);
                    }
                  }
                }
              },
              editable: true,
              hintText: content == Constants.changeName ? profileName : aboutMe,
            );
          },
          child: const Icon(
            Icons.edit_rounded,
          ),
        );
      }
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                userImageWidget(
                  imageUrl: profileImage,
                  fileImage: authProvider.finalFileImage,
                  radius: 50.0,
                  onTap: () {
                    authProvider.showBottomSheet(
                        context: context,
                        onSuccess: () async {
                          if (isGroup) {
                            groupProvider!.setIsSloading(value: true);
                          }
                          String imageUrl = await authProvider.updateImage(
                              id: isGroup
                                  ? groupProvider!.groupModel.groupId
                                  : uid,
                              isGroup: isGroup);
                          if (isGroup) {
                            groupProvider!.setIsSloading(value: false);
                            if (imageUrl == "Error") return;
                            groupProvider!.setGroupImage(imageUrl);
                          }
                        });
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          profileName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        getEditWidget("Change Name", Constants.changeName),
                      ],
                    ),
                    // display phone number
                    userModel != null && uid == userModel!.uid
                        ? Text(
                            phoneNumber,
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 5),
                    userModel != null
                        ? ProfileStatusWidget(
                            userModel: userModel!,
                            currentUser: authProvider.userModel!,
                          )
                        : GroupStatusWidget(
                            isAdmin: isAdmin!,
                            groupProvider: groupProvider!,
                          ),

                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(userModel != null ? 'About Me' : 'Group Description',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(width: 5),
                getEditWidget("Change Description", Constants.changeDesc),
              ],
            ),
            Text(
              aboutMe,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
