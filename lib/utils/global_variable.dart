import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_app/screens/add_post_screen.dart';
import 'package:gdsc_app/screens/feed_screen.dart';
import 'package:gdsc_app/screens/notification_screen.dart';
import 'package:gdsc_app/screens/profile_screen.dart';
import 'package:gdsc_app/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  NotificationScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
