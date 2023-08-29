import 'package:chat_app_class/encryption/encryption.dart';
import 'package:chat_app_class/pref/shared_pref_controller.dart';
import 'package:chat_app_class/screens/notifications_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../firebase/fb_auth_controller.dart';
import '../firebase/fb_firestore_controller.dart';
import 'login_screen.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

User loggedInUser = _firebaseAuth.currentUser!;
String username = 'User';
String messageText = '';

class ChatScreen extends StatefulWidget {

  static const id = 'ChatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatMsgTextController = TextEditingController();

  String? _userImage;
  List<RemoteNotification?> notifications = [];

  _sendMessage() async {
    chatMsgTextController.clear();
    FbFirestoreController().instance.collection('messages').add({
      'userId': loggedInUser.uid,
      'username': loggedInUser.displayName,
      'SenderEmail': loggedInUser.email,
      'text': Encryption.encryptAES(messageText),
      'time': Timestamp.now()
    });
    // print(userData.asStream()[document]);
  }

  void fetchImage(String userImage) async {
    setState(() {
      _userImage = userImage;
    });
  }

  void getNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        setState((){
          notifications.add(message.notification);
        });
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  @override
  void initState() {
    getNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          Stack(
            children: [
              IconButton(
                  icon: const Icon(Icons.notifications), onPressed: () {
                Navigator.pushNamed(context, Notifications.id,arguments: notifications);

              }),
              notifications.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '${notifications.length == 0 ? '' : notifications.length}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    )
                  : const SizedBox()
            ],
          ),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                //Implement logout functionality
                await FbAuthController().signOut();
                await SharedPrefController().clear();
                Navigator.pushReplacementNamed(context, LoginScreen.id);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      drawer: Drawer(
        child: StreamBuilder<QuerySnapshot>(
            stream: FbFirestoreController()
                .instance
                .collection('users')
                .snapshots(),
            builder: (context, snapShot) {
              if (snapShot.hasData) {
                final docs = snapShot.data!.docs;
                for (var doc in docs) {
                  if (loggedInUser.email == doc['email']) {
                    final userImage = doc['image_url'];
                    fetchImage(userImage);
                  }
                }

                return ListView(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[900],
                      ),
                      accountName: Text('${loggedInUser.displayName}'),
                      accountEmail: Text('${loggedInUser.email}'),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(_userImage!),
                        maxRadius: 50,
                      ),
                      onDetailsPressed: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text("Logout"),
                      subtitle: const Text("Sign out of this account"),
                      onTap: () async {
                        await FbAuthController().signOut();
                        await SharedPrefController().clear();
                        Navigator.pushReplacementNamed(context, LoginScreen.id);
                      },
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.deepPurple),
                );
              }
            }),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChatStream(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Material(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                        child: TextField(
                          onChanged: (value) {
                            messageText = value;
                          },
                          controller: chatMsgTextController,
                          decoration: kMessageTextFieldDecoration,
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                      shape: const CircleBorder(),
                      color: Colors.blue,
                      onPressed: () {
                        chatMsgTextController.text.trim().isEmpty
                            ? null
                            : _sendMessage();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      )
                      // Text(
                      //   'Send',
                      //   style: kSendButtonTextStyle,
                      // ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FbFirestoreController()
          .instance
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapShot) {
        if (snapShot.hasData) {
          final messages = snapShot.data!.docs;
          List<MessageBubble> messageWidgets = [];
          for (var message in messages) {
            final msgText = message['text'];
            final msgSender = message['username'];
            final emailSender = message['SenderEmail'];
            final currentUser = loggedInUser.uid;
            final userId = message['userId'];
            final key = message.id;

            final msgBubble = MessageBubble(
              msgText: Encryption.decryptAES(msgText),
              msgSender: msgSender,
              user: currentUser == userId,
              key: ValueKey(key),
              emailSender: emailSender,
            );
            messageWidgets.add(msgBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              children: messageWidgets,
            ),
          );
        } else {
          return const Center(
            child:
                CircularProgressIndicator(backgroundColor: Colors.deepPurple),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Key key;
  String msgText;
  final String msgSender;
  final String emailSender;
  final bool user;

  MessageBubble(
      {required this.msgText,
      required this.msgSender,
      required this.user,
      required this.key,
      required this.emailSender});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment:
            !user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              msgSender,
              style: const TextStyle(
                  fontSize: 13, fontFamily: 'Poppins', color: Colors.black87),
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              topLeft: !user ? Radius.circular(50) : Radius.circular(0),
              bottomRight: Radius.circular(50),
              topRight: !user ? Radius.circular(0) : Radius.circular(50),
            ),
            color: !user ? Colors.blue : Colors.white,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '${msgText}',
                style: TextStyle(
                  color: !user ? Colors.white : Colors.blue,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
