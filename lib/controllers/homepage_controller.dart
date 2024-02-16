
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:stylestore/screens/home_pages/home_page.dart';

import '../screens/menu_page.dart';
import 'home_page_controllers/home_controller_mobile.dart';

class HomePageController extends StatefulWidget {
  static String id = 'MenuPageController';

  @override
  State<HomePageController> createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController> {
  @override
  Widget build(BuildContext context) =>

  ZoomDrawer(
      style: DrawerStyle.style1,
      menuScreen: MenuPage(),
      mainScreen: ControlPageMobile()
  );
}
