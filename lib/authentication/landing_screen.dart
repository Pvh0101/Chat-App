import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  initState() {
    super.initState();
    checkAuthtication();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SizedBox(
        height: 400,
        width: 200,
        child: Column(
          children: [
            Lottie.asset(AssetsManager.chatBubbble),
            const LinearProgressIndicator(),
          ],
        ),
      )),
    );
  }

  void checkAuthtication() async {
    final authProvider = context.read<AuthenticationProvider>();
    bool isAuthenticated = await authProvider.checkAuthenticationState();

    navigate(isAuthenticated: isAuthenticated);
  }

  void navigate({required bool isAuthenticated}) {
    if (isAuthenticated) {
      //navigate to home screen
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    } else {
      //navigate to login screen
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }
}
