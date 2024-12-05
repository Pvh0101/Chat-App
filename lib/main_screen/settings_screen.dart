import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      setState(() {
        isDarkMode = true;
      });
    } else {
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    final currentUser = authProvider.userModel!;
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Settings'),
        actions: [
          currentUser.uid == uid
              // logout button
              ? IconButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () async {
                                    await context
                                        .read<AuthenticationProvider>()
                                        .logout()
                                        .whenComplete(() {
                                      Navigator.pop(context);
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        Constants.loginScreen,
                                        (route) => false,
                                      );
                                    });
                                  },
                                  child: const Text('Logout')),
                            ],
                          );
                        });
                  },
                  icon: const Icon(Icons.logout))
              : const SizedBox(),
        ],
      ),
      body: Center(
          child: Card(
        child: SwitchListTile(
          value: isDarkMode,
          onChanged: (value) {
            setState(() {
              isDarkMode = value;
            });
            if (isDarkMode) {
              AdaptiveTheme.of(context).setDark();
            } else {
              AdaptiveTheme.of(context).setLight();
            }
          },
          title: const Text('Change Theme'),
          secondary: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      )),
    );
  }
}
