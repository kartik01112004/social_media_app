import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_app/resources/auth_methods.dart';
import 'package:gdsc_app/resources/firestore_methods.dart';
import 'package:gdsc_app/screens/add_post_screen.dart';
import 'package:gdsc_app/screens/login_screen.dart';
import 'package:gdsc_app/utils/colors.dart';
import 'package:gdsc_app/utils/utils.dart';
import 'package:gdsc_app/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
          floatingActionButton: FloatingActionButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPostScreen()));
          },child: Icon(Icons.add),shape:BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(8.0)) ,),
            // appBar: AppBar(
            //   backgroundColor: mobileBackgroundColor,
            //   title: Text(
            //     userData['username'],
            //   ),
            //   centerTitle: false,
            // ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                userData['photoUrl'],
                              ),
                              radius: 40,
                            ),
                      ),
                          SizedBox(height: 5.0,),
                        Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          userData['username'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ),
                        SizedBox(height: 5.0,),
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
                                      const VerticalDivider( color: Colors.black,thickness: 1,),
                                      buildStatColumn(postLen, "posts"),
                                      const VerticalDivider( color: Colors.black,thickness: 1,),
                                      buildStatColumn(following, "following"),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            text: 'Sign Out',
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: primaryColor,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await AuthMethods().signOut();
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen(),
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
                                            : Stack(
                                              children: [ 
                                                InkWell(
                                                  child: Container(
                                                    width: 250,
                                                    height: 27,
                                                  ),
                                                  onTap: () async {
                                                    await collectionRef.add({
                                                      'user_id': FirebaseAuth.instance.currentUser!.uid.toString(),
                                                      'follow_notification': "Started following",
});
                                                  },
                                                  ),FollowButton(
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

                                                  setState(() {
                                                    isFollowing = true;
                                                    followers++;
                                                  });
                                                },
                                              )]
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
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 1.5,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          DocumentSnapshot snap =
                              (snapshot.data! as dynamic).docs[index];
                    
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: Container(
                              child: Image(
                                image: NetworkImage(snap['postUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
