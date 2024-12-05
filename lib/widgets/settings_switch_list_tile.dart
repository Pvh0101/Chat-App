// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SettingsSwitchListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color containerColor;
  final bool value;
  final Function(bool) onChanged;
  const SettingsSwitchListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: (value) {
          onChanged(value);
        },
        secondary: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
