import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/utilities/global_method.dart';
import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
import 'package:flutter_chat_pro/widgets/info_details_card.dart';
import 'package:flutter_chat_pro/widgets/setting_list_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  // get the saved theme mode
  void getThemeMode() async {
    // get the saved theme mode
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    // check if the saved theme mode is dark
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      // set the isDarkMode to true
      setState(() {
        isDarkMode = true;
      });
    } else {
      // set the isDarkMode to false
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
    // get user data from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    final authProvider = context.read<AuthenticationProvider>();
    return authProvider.isLoading
        ? const Scaffold(
            body: Column(children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Saving Image, Please wait...')
            ]),
          )
        : Scaffold(
            appBar: MyAppBar(
              title: const Text('Profile'),
            ),
            body: StreamBuilder(
              stream: context
                  .read<AuthenticationProvider>()
                  .userStream(userID: uid),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userModel = UserModel.fromMap(
                    snapshot.data!.data() as Map<String, dynamic>);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoDetailsCard(
                          userModel: userModel,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Settings',
                            style: GoogleFonts.openSans(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: Column(
                            children: [
                              SettingsListTile(
                                title: 'Change Theme',
                                icon: Icons.dark_mode,
                                iconContainerColor: Colors.deepPurple,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ListTile(
                                            title: const Text('Light Mode',
                                                style: TextStyle(fontSize: 18),
                                                textAlign: TextAlign.center),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              // Set theme to light mode
                                              AdaptiveTheme.of(context)
                                                  .setLight();
                                            },
                                          ),
                                          const Divider(),
                                          ListTile(
                                            title: const Text('Dark Mode',
                                                style: TextStyle(fontSize: 18),
                                                textAlign: TextAlign.center),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              // Set theme to dark mode
                                              AdaptiveTheme.of(context)
                                                  .setDark();
                                            },
                                          ),
                                          const Divider(),
                                          ListTile(
                                            title: const Text('System Default',
                                                style: TextStyle(fontSize: 18),
                                                textAlign: TextAlign.center),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              // Set theme to system default
                                              AdaptiveTheme.of(context)
                                                  .setSystem();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              const Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                              SettingsListTile(
                                title: 'Account',
                                icon: Icons.person,
                                iconContainerColor: Colors.deepPurple,
                                onTap: () {
                                  // navigate to account settings
                                },
                              ),
                              const Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                              SettingsListTile(
                                title: 'My Media',
                                icon: Icons.image,
                                iconContainerColor: Colors.deepPurple,
                                onTap: () {
                                  // navigate to account settings
                                },
                              ),
                              const Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                              SettingsListTile(
                                title: 'Notifications',
                                icon: Icons.notifications,
                                iconContainerColor: Colors.deepPurple,
                                onTap: () {
                                  // navigate to account settings
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: Column(
                            children: [
                              SettingsListTile(
                                title: 'Help',
                                icon: Icons.help,
                                iconContainerColor: Colors.deepPurple,
                                onTap: () {
                                  // navigate to account settings
                                },
                              ),
                              const Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                              SettingsListTile(
                                title: 'Share',
                                icon: Icons.share,
                                iconContainerColor: Colors.deepPurple,
                                onTap: () {
                                  // navigate to account settings
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 10),
                        Card(
                          child: Column(
                            children: [
                              SettingsListTile(
                                title: 'Logout',
                                icon: Icons.logout_outlined,
                                iconContainerColor: Colors.deepPurple,
                                onTap: () {
                                  showMyAnimatedDialog(
                                    context: context,
                                    title: 'Logout',
                                    content: 'Are you sure you want to logout?',
                                    textAction: 'Logout',
                                    onActionTap: (value) {
                                      if (value) {
                                        // logout
                                        context
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
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
