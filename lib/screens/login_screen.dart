import 'package:chat_app_class/models.dart';
import 'package:chat_app_class/pref/shared_pref_controller.dart';
import 'package:flutter/material.dart';

import '../components/main_btn.dart';
import '../constants.dart';
import '../firebase/fb_auth_controller.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  static const id = 'LoginScreen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                height: 200.0,
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
             controller: _emailController,
              decoration:
                  kTextFieldDecoration.copyWith(hintText: 'Enter your Email'),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your Password'),
            ),
            SizedBox(
              height: 24.0,
            ),
            MainBtn(
              color: Colors.lightBlueAccent,
              text: 'Log In',
              onPressed: () async{
                 await performLogin();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> performLogin() async {
    if (checkData()) {
      await login();
    }
  }

  bool checkData() {
    if (
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
  Future<void> login() async {
    await SharedPrefController().save(user: user);
    bool status = await FbAuthController().signIn(context, email: _emailController.text.trim(), password: _passwordController.text);
    if (status) {
      Navigator.pushReplacementNamed(context,ChatScreen.id);
    }
  }

  User get user => User(email: _emailController.text);
}
