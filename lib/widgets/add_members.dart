import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';

class AddMembers extends StatelessWidget {
  const AddMembers({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
    required this.onPressed,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Members',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        !isAdmin
            ? const SizedBox()
            : Row(
                children: [
                  IconButton(
                    onPressed: onPressed,
                    icon: const Icon(Icons.add,
                        size: 30, color: Colors.deepPurple),
                  ),
                ],
              ),
      ],
    );
  }
}
