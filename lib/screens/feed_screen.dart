import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_app/utils/colors.dart';
import 'package:gdsc_app/utils/global_variable.dart';
import 'package:gdsc_app/widgets/post_card.dart';
import 'package:gdsc_app/widgets/text_field_input.dart';


class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {

    final TextEditingController textEditingController = TextEditingController();
    void dispose() {
    super.dispose();
    textEditingController.dispose();
  }
  

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: Text("Feed",style: TextStyle(color: Color.fromARGB(255, 78, 18, 88)),),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.messenger_outline,
                    color: primaryColor,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('datePublished', descending: true).snapshots(),
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
                    
                    PostCard(
                      uid: (snapshot.data! as dynamic).docs[index]['uid'],
                      snap: snapshot.data!.docs[index].data(),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(left: width*0.2),
                      child: ClipRRect(borderRadius: BorderRadius.circular(20.0),child: TextFieldInput(textEditingController: textEditingController, hintText: "  comment", textInputType: TextInputType.emailAddress)),
                    )
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
