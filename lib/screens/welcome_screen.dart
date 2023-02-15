import 'package:chat_app_class/components/main_btn.dart';
import 'package:chat_app_class/pref/shared_pref_controller.dart';
import 'package:chat_app_class/screens/chat_screen.dart';
import 'package:chat_app_class/screens/login_screen.dart';
import 'package:chat_app_class/screens/registration_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  static const id = 'welcomeScreen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Duration duration = Duration(seconds: 1);
  late Animation animation;
  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: duration);

    controller.forward();
    animation =
        ColorTween(begin: Colors.grey, end: Colors.white).animate(controller);
    animation.addListener(() {
      setState(() {});
      print(animation.value);
    });

    if(SharedPrefController().loggedIn){
      Navigator.pushReplacementNamed(context, ChatScreen.id);
    }

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('assets/images/logo.png'),
                    height: controller.value * 100,
                  ),
                ),
                Text(
                  'Chat App',
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            MainBtn(
              color: Colors.lightBlueAccent,
              text: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            MainBtn(
              color: Colors.blueAccent,
              text: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
