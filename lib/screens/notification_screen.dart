import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_app/utils/colors.dart';
import 'package:gdsc_app/utils/global_variable.dart';
import '../widgets/notification_card.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {


    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: Text("Notifications",style: TextStyle(color: Color.fromARGB(255, 78, 18, 88)),),
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: width > webScreenSize ? width * 0.3 : 0,
                vertical: width > webScreenSize ? 15 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Column(
                  children: [
                    NotificationCard(
                      uid: (snapshot.data! as dynamic).docs[index]['user_id'],
                      snap: snapshot.data!.docs[index].data(),
                    ),
                    
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
