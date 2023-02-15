import 'dart:io';

import 'package:chat_app_class/components/user_image_picker.dart';
import 'package:chat_app_class/constants.dart';
import 'package:flutter/material.dart';

import '../components/main_btn.dart';
import '../firebase/fb_auth_controller.dart';

class RegistrationScreen extends StatefulWidget {
  static const id = 'RegistrationScreen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _userNameController;
  bool showIndcitor=false;
  File? _userImageFile;

  void _pickedImage(File pickedImage){
    _userImageFile = pickedImage;
  }


  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _userNameController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: showIndcitor ? const Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Flexible(
              child: Container(
                height: 200.0,
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            UserImagePicker(_pickedImage),
            const SizedBox(height: 10),
            TextField(
              controller: _userNameController,
              decoration:
              kTextFieldDecoration.copyWith(hintText: 'Enter your name'),
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextField(
              controller: _emailController,
              decoration:
              kTextFieldDecoration.copyWith(hintText: 'Enter your Email'),
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password'),
            ),
            const SizedBox(
              height: 24.0,
            ),
            MainBtn(
              color: Colors.blueAccent,
              text: 'Register',
              onPressed: () {
                performRegister();
              },
            ),
          ],
        ),
      )
    );
  }

  Future<void> performRegister() async {
    if (checkData()) {
      await register();
    }
  }

  bool checkData() {
    if ( _userImageFile != null &&
        _userNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty
    ) {
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enter required data'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
  Future<void> register() async {
    bool status = await FbAuthController().signUp(context, email: _emailController.text.trim(), password: _passwordController.text, image: _userImageFile!, username: _userNameController.text);
    FocusScope.of(context).unfocus();
    if (status) {
      Navigator.pop(context);
    }
  }
}
