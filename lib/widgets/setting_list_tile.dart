import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconContainerColor;
  final Function() onTap;
  final Widget? trailing;

  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconContainerColor,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Leading icon container with padding and circular border
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconContainerColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
      // Main title text with custom styling
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      // Optional subtitle text if provided
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            )
          : null,
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
      onTap: onTap, // Action when the tile is tapped
    );
  }
}
