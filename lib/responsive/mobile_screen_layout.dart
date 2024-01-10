import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sweet_nav_bar/sweet_nav_bar.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  final iconLinearGradiant = List<Color>.from([
    const Color.fromARGB(255, 235, 182, 241),
    const Color.fromARGB(255, 235, 182, 241)
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: homeScreenItems,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: SweetNavBar(
        backgroundColor: mobileBackgroundColor,
        items: [
          SweetNavBarItem(
            sweetIcon: Icon(
              Icons.home,
              color: (_page == 0) ? primaryColor : secondaryColor,
            ),
            iconColors: iconLinearGradiant,
            sweetLabel: '',
            sweetBackground: Color.fromARGB(255, 101, 20, 115),
          ),
          SweetNavBarItem(
              sweetIcon: Icon(
                FontAwesomeIcons.users ,
                color: (_page == 1) ? primaryColor : secondaryColor,
              ),
              iconColors: iconLinearGradiant,
              sweetLabel: '',
              sweetBackground:  Color.fromARGB(255, 101, 20, 115),),
          
          SweetNavBarItem(
            sweetIcon: Icon(
              FontAwesomeIcons.image,
              color: (_page == 2) ? primaryColor : secondaryColor,
            ),
            iconColors: iconLinearGradiant,
            sweetLabel: '',
            sweetBackground:  Color.fromARGB(255, 101, 20, 115),
          ),
          SweetNavBarItem(
            sweetIcon: Icon(
              Icons.person,
              color: (_page == 3) ? primaryColor : secondaryColor,
            ),
            iconColors: iconLinearGradiant,
            sweetLabel: '',
            sweetBackground:  Color.fromARGB(255, 101, 20, 115),
          ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}
