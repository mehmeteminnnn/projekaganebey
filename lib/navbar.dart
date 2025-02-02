import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:projekaganebey/screens/ana_ekran.dart';
import 'package:projekaganebey/screens/notifications_page.dart';
//import 'package:projekaganebey/bildirimler.dart';
import 'package:projekaganebey/favorilerim.dart';
import 'package:projekaganebey/ilan_ver.dart';
import 'package:projekaganebey/screens/profil_ekrani.dart';
//import 'package:projekaganebey/sepetim.dart';
import 'package:projekaganebey/styles.dart';
import "package:projekaganebey/screens/search_screen.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  String? id;

  MainScreen({this.id});
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    debugPrint("MainScreen id: $id");
    return [
      AdsMDFLamPage(id: id),
      SearchPage(id:id),
      IlanVerPage(id: id),
      FavorilerimPage(id: id),
      ProfileScreen(id: id),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.view_list),
        title: ("İlanlar"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        title: ("Arama"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add_circle),
        title: ("Depota Yükle"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        iconSize: 50,
        activeColorSecondary: Colors.blue,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.favorite),
        title: ("Favorilerim"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: ("Profil"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      handleAndroidBackButtonPress: true,
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarHeight: 55,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(15.0),
        colorBehindNavBar: Colors.white,
      ),
      animationSettings: NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            animateTabTransition: true,
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 200),
          )),

      navBarStyle: NavBarStyle.style15, // Enhanced visual style
    );
  }
}
