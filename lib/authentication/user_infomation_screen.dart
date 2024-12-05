import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/utilities/global_method.dart';
import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
import 'package:flutter_chat_pro/widgets/display_user_image.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  // final RoundedLoadingButtonController _btnController =
  //     RoundedLoadingButtonController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider authenticationProvider =
        context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('User Information'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            DisplayUserImage(
              finalFileImage: authenticationProvider.finalFileImage,
              radius: 60,
              onPressed: () {
                authenticationProvider.showBottomSheet(context: context);
              },
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                labelText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _aboutController,
              decoration: const InputDecoration(
                hintText: 'Enter your information about yourself',
                labelText: 'Enter your information about yourself',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: MaterialButton(
                onPressed: context.read<AuthenticationProvider>().isLoading
                    ? null
                    : () {
                        if (_nameController.text.isEmpty ||
                            _nameController.text.length < 3) {
                          showSnackBar(context, 'Please enter your name');
                          return;
                        }
                        // save user data to firestore
                        saveUserDataToFireStore();
                      },
                child: context.watch<AuthenticationProvider>().isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Continue',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5),
                      ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  // save user data to firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      token: '',
      aboutMe: _aboutController.text,
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequestsUIDs: [],
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      // fileImage: finalFileImage,
      onSuccess: () async {
        // save user data to shared preferences
        await authProvider.saveUserDataToSharedPreferences();

        navigateToHomeScreen();
      },
      onFail: () async {
        showSnackBar(context, 'Failed to save user data');
      },
    );
  }

  void navigateToHomeScreen() {
    // navigate to home screen and remove all previous screens
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }
}
