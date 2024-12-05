import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';

import 'package:flutter_chat_pro/widgets/friend_widget.dart';
import 'package:flutter_chat_pro/widgets/search_widget.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const SizedBox(height: 10),

          // cupertino seearch bar
          SearchWidget(onChanged: (value) {}),

          // list of users
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: context
                  .read<AuthenticationProvider>()
                  .getAllUsersStream(userID: currentUser.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    final data = UserModel.fromMap(
                        document.data()! as Map<String, dynamic>);
                    return FriendWidget(
                      friend: data,
                      viewType: FriendViewType.allUsers,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
