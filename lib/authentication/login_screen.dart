import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _phoneFocusNode = FocusNode();

  final TextEditingController _phoneNumberController = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: '84',
    countryCode: 'VN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Vietnam',
    example: 'Vietnam',
    displayName: 'Vietnam',
    displayNameNoCountryCode: 'VN',
    e164Key: '',
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset(AssetsManager.chatBubbble),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Add your phone number, we will send you a code to verify",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(fontSize: 16),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                focusNode: _phoneFocusNode,
                controller: _phoneNumberController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "Phone Number",
                  hintStyle: GoogleFonts.openSans(fontSize: 16),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            setState(() {
                              selectedCountry = country;
                            });
                          },
                        );
                      },
                      child: Text(
                        "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                        style: GoogleFonts.openSans(fontSize: 16),
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  authProvider.signInWithPhoneNumber(
                    phoneNumber:
                        "+${selectedCountry.phoneCode}${_phoneNumberController.text}",
                    context: context,
                  );
                },
                child: Text(
                  "Send Code",
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
