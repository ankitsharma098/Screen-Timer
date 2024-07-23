import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:usage_stats/usage_stats.dart';

import 'CustomTheme/CustomTheme.dart';
import 'Notification/requestPermission.dart';
import 'ScreenTime/screenTime.dart';
import 'Setting/setting.dart';
import 'Timer/timer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  CustomTheme themeObj = CustomTheme();
  List<String> title = ["Screen Time", "App Limit", "Setting"];

  final List<Widget> _screens = [
    ScreenTime(),
    AppLimit(),
    Setting(),
  ];

  NotificationServices requestPermission = NotificationServices();

  @override
  void initState() {
    super.initState();
    requestPermission.requestPermission();
    requestPermission.firebaseInit();
    requestPermission.getAccessToken();

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: themeObj.textBlack),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: AutoSizeText(
          title[_selectedIndex],
          style: TextStyle(
            color: themeObj.textBlack,
            fontWeight: FontWeight.w400,
            fontSize: size.width * 0.06,
          ),
        ),
        backgroundColor: themeObj.primaryColor,
        shape: UnderlineInputBorder(
          borderSide: BorderSide(color: themeObj.textGrey),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notification_add_sharp, color: themeObj.textBlack),
          )
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: themeObj.primaryColor,
        buttonBackgroundColor: themeObj.primaryColor,
        height: 60,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: themeObj.textBlack),
          Icon(Icons.timer, size: 30, color: themeObj.textBlack),
          Icon(Icons.settings, size: 30, color: themeObj.textBlack),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}