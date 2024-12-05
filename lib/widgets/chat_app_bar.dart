import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/utilities/global_method.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:timeago/timeago.dart' as timeago;

class ChatAppBar extends StatefulWidget {
  final String contactUID;
  const ChatAppBar({super.key, required this.contactUID});

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context
          .read<AuthenticationProvider>()
          .userStream(userID: widget.contactUID),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userModel =
            UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        // Chuyển đổi lastSeen từ String thành DateTime
        // final lastSeenText = userModel.isOnline ? 'Online' : "Offline";

        return Row(
          children: [
            userImageWidget(
              imageUrl: userModel.image,
              radius: 20,
              onTap: () {
                Navigator.pushNamed(context, Constants.profileScreen,
                    arguments: userModel.uid);
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userModel.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
