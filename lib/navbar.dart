import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:Depot/screens/ana_ekran.dart';
import 'package:Depot/screens/notifications_page.dart';
//import 'package:Depot/bildirimler.dart';
import 'package:Depot/favorilerim.dart';
import 'package:Depot/screens/ilan%20verme/ilan_ver.dart';
import 'package:Depot/screens/profil_ekrani.dart';
//import 'package:Depot/sepetim.dart';
import 'package:Depot/styles.dart';
import "package:Depot/screens/search_screen.dart";

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
      SearchPage(id: id),
      IlanVerPage(id: id),
      FavorilerimPage(id: id),
      ProfileScreen(id: id),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.view_list),
        title: ("İlanlar"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search),
        title: ("Arama"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add_circle),
        title: ("Depota Yükle"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        iconSize: 50,
        activeColorSecondary: Colors.blue,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.favorite),
        title: ("Favorilerim"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
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
      animationSettings: const NavBarAnimationSettings(
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
