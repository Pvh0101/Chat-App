import 'dart:io';

import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  MyAppBar({super.key, this.title = const Text(''), this.actions = const []});

  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
            Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios_new),
      ),
      title: title,
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(56);
}
