import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';

import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
import 'package:flutter_chat_pro/widgets/friends_list.dart';

class FriendRequestScreens extends StatefulWidget {
  final String groupId;
  const FriendRequestScreens({super.key, this.groupId = ''});

  @override
  State<FriendRequestScreens> createState() => _FriendRequestScreensState();
}

class _FriendRequestScreensState extends State<FriendRequestScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          title: const Text('Friend Requests'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // cupertino seearch bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: CupertinoSearchTextField(
                  placeholder: 'Search',
                  onChanged: (value) {
                    //  search
                  },
                ),
              ),
              Expanded(
                  child: FriendsList(
                viewType: FriendViewType.friendRequests,
                groupId: widget.groupId,
              )),
            ],
          ),
        ));
  }
}
