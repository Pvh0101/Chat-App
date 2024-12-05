import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';

// ignore: must_be_immutable
class GroupTypeListTile extends StatelessWidget {
  final String title;
  GroupType value;
  GroupType? groupValue;
  final Function(GroupType?) onChanged;
  GroupTypeListTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final capitalizedTitle = title[0].toUpperCase() + title.substring(1);
    return RadioListTile(
        value: value,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.grey.shade200,
        contentPadding: EdgeInsets.zero,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(capitalizedTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)));
  }
}
