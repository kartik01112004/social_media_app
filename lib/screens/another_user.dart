import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_app/resources/auth_methods.dart';
import 'package:gdsc_app/resources/firestore_methods.dart';
import 'package:gdsc_app/screens/add_post_screen.dart';
import 'package:gdsc_app/screens/login_screen.dart';
import 'package:gdsc_app/screens/profile_screen.dart';
import 'package:gdsc_app/utils/colors.dart';
import 'package:gdsc_app/utils/utils.dart';
import 'package:gdsc_app/widgets/follow_button.dart';

class Profilescreen2 extends StatefulWidget {
  final String uid;
  const Profilescreen2({Key? key, required this.uid}) : super(key: key);

  @override
  State<Profilescreen2> createState() => _Profilescreen2State();
}

class _Profilescreen2State extends State<Profilescreen2> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  final CollectionReference collectionRef = FirebaseFirestore.instance.collection('notification');

 
  @override

  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;


    return isLoading
    ? const Center(
      child: CircularProgressIndicator(),
      )
      : Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(userData['photoUrl'],),
                    fit: BoxFit.contain,
                  ),
                ),
            ),
      Positioned(
        bottom: 1,
        right: 1,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1,sigmaY: 1),
            child: Container(
              width: width*0.8,
              height: height*0.6,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.transparent.withOpacity(0.2),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height*0.02,),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Text(
                      userData['username'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                         fontWeight: FontWeight.w700,
                        ),
                    ),
                  ),
                  SizedBox(height: height*0.01,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: const Divider(
                      color: Colors.white,
                      thickness: 0.8,
                    ),
                  ),
                  SizedBox(height: height*0.01,),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildStatColumn(followers, "followers"),
                                  const VerticalDivider( color: Colors.white,thickness: 1,),
                                  buildStatColumn(postLen, "posts"),
                                  const VerticalDivider( color: Colors.white,thickness: 1,),
                                  buildStatColumn(following, "following"),
                                  ],
                                ),
                              ),
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                .collection('posts').where('uid', isEqualTo: widget.uid).get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                      );
                                      }
                                      return Container(
                                        width: 200,
                                        height: 120,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: (snapshot.data! as dynamic).docs.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20.0),
                                                child: Container(
                                                  width: 100,
                                                  height: 100,
                                                  child: Image(
                                                    image: NetworkImage(snap['profImage']),
                                                    fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          ),
                                        );
                                      },
                                    ),
                            Row(
                              mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FirebaseAuth.instance.currentUser!.uid ==
                                widget.uid
                                ? FollowButton(
                                  text: 'Go to profile',
                                  backgroundColor:
                                  mobileBackgroundColor,
                                  textColor: primaryColor,
                                  borderColor: Colors.grey,
                                  function: () async {
                                    Navigator.of(context)
                                    .push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
                                      ),
                                    );
                                  },
                                )
                                : isFollowing
                                ? FollowButton(
                                  text: 'Unfollow',
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  borderColor: Colors.grey,
                                  function: () async {
                                    await FireStoreMethods()
                                    .followUser(
                                      FirebaseAuth.instance
                                      .currentUser!.uid,
                                      userData['uid'],
                                      );
                                      setState(() {
                                        isFollowing = false;
                                        followers--;
                                      });
                                    },
                                  )
                                  : FollowButton(
                                                text: 'Follow',
                                                backgroundColor: Colors.blue,
                                                textColor: Colors.white,
                                                borderColor: Colors.blue,
                                                function: () async {
                                  await FireStoreMethods()
                                      .followUser(
                                    FirebaseAuth.instance
                                        .currentUser!.uid,
                                    userData['uid'],
                                  );
                                  await collectionRef.add({
                                      'user_id': await FirebaseFirestore.instance.collection('users').doc(widget.uid).get().then((snapshot) => snapshot.get('username')),
                                      'follow_notification': " Started following you ",
                                      });
                                  setState(() {
                                    isFollowing = true;
                                    followers++;
                                  });
                                                },
                                              )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    ],
)

      )
    ;
  }
  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}