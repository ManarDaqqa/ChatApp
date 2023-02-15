import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  static const id = 'notifications_screen';

  const Notifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<RemoteNotification?> notifications =
        ModalRoute.of(context)!.settings.arguments as List<RemoteNotification?>;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'),centerTitle: true),
      body: notifications.isEmpty
          ? const Center(child: Text('There are currently no notifications'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                if (notifications[index] != null) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                      color: Colors.teal,
                      // margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                      child: ListTile(
                        title: Text('${notifications[index]?.title}'),
                        subtitle: Text('${notifications[index]?.body}'),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              }),
    );
  }
}
