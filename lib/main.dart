import 'package:chat_app_class/firebase_options.dart';
import 'package:chat_app_class/pref/shared_pref_controller.dart';
import 'package:chat_app_class/screens/chat_screen.dart';
import 'package:chat_app_class/screens/login_screen.dart';
import 'package:chat_app_class/screens/notifications_screen.dart';
import 'package:chat_app_class/screens/registration_screen.dart';
import 'package:chat_app_class/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefController().initPreferences();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging fbm = FirebaseMessaging.instance;
  NotificationSettings settings = await fbm.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );



  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const FlashChat());
  }


class FlashChat extends StatelessWidget {
  const FlashChat({super.key});


  void getFcm() async{
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('fcmToken: $fcmToken');
  }

  @override
  Widget build(BuildContext context) {
    getFcm();
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id : (context) => ChatScreen(),
        Notifications.id : (context) => const Notifications()
      },
    );
  }
}
