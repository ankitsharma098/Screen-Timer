import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:untitled4/Timer/setTimer.dart';



import '../CustomTheme/CustomTheme.dart';

class AppLimit extends StatefulWidget {
  const AppLimit({super.key});

  @override
  State<AppLimit> createState() => _AppLimitState();
}

class _AppLimitState extends State<AppLimit> {
  Future<String> getAppName(String packageName) async {
    try {
      Application? app = await DeviceApps.getApp(packageName, false);
      return app?.appName ?? packageName.split('.').last;
    } catch (e) {
      print('Error fetching app name for $packageName: $e');
      return packageName.split('.').last;
    }
  }
  Widget getAppIcon(String packageName) {
    return FutureBuilder<Application?>(
      future: DeviceApps.getApp(packageName, true),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data is ApplicationWithIcon) {
          final app = snapshot.data as ApplicationWithIcon;
          return Image.memory(app.icon, width: 48, height: 48);
        } else {
          return Icon(Icons.apps, size: 48);
        }
      },
    );
  }

  Future<List<Application>> getAllApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    print(apps);
    return apps;
  }
  List<Map<String, dynamic>> data = [
    {
      "logo":Icons.accessibility_new_outlined,
      "name": "YouTube",
    },
    {
      "logo":Icons.accessibility_new_outlined,
      "name": "Instagram",
    },
    {
      "logo":Icons.accessibility_new_outlined,
      "name": "WhatsApp",

    },
    {
      "logo": Icons.camera,
      "name": "SnapChat",
    },
    {
      "logo": Icons.chrome_reader_mode,
      "name": "Chrome",
    },
    {
      "logo": Icons.calculate,
      "name": "Calculator",
    },
    {
      "logo": Icons.no_encryption_gmailerrorred,
      "name": "Gmail",
    },
    {
      "logo": Icons.search,
      "name": "Google",
    },
    {
      "logo": Icons.camera,
      "name": "InterShala",
    },
    {
      "logo": Icons.payment,
      "name": "Google Pay",
    },
    {
      "logo": Icons.camera,
      "name": "SnapChat",
    },
    {
      "logo": Icons.message_rounded,
      "name": "Skype",
    },
    {
      "logo": Icons.camera,
      "name": "Paytm",
    },
    {
      "logo": Icons.phone,
      "name": "Phone",
    },
    {
      "logo": Icons.camera,
      "name": "SnapChat",
    },
    {
      "logo": Icons.camera,
      "name": "SnapChat",
    },
  ];
  Future<void>_addNewResultPopup( BuildContext context ,Size size)async {
    return showDialog(
      context: context,
      builder: (context) {
        return  StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(

                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Column(
                        children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             TextButton(
                               onPressed: (){
                                 Navigator.pop(context);
                               },
                               child:  AutoSizeText("Cancel",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w400,fontSize: size.width*0.045),),
                             ),
                             AutoSizeText("Choose Apps",style: TextStyle(color: themeObj.textBlack,fontWeight: FontWeight.w400,fontSize: size.width*0.045),),
                             TextButton(
                               onPressed: (){
                                 Navigator.push(context, MaterialPageRoute(builder: (context) => SetTimer(appName: "ass",appIcon: SizedBox(),),));
                               },
                               child:  AutoSizeText("Next",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w400,fontSize: size.width*0.045),),
                             ),
                           ],
                         ),
                          SizedBox(height: size.height*0.02,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText("APPS & CATEGORIES",style: TextStyle(color: themeObj.textGrey,fontWeight: FontWeight.w400,fontSize: size.width*0.04),),
                              Divider(color: Colors.grey,thickness: 1,),
                              FutureBuilder<List<Application>>(
                                future: getAllApps(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                      child: LoadingAnimationWidget.threeArchedCircle(
                                        color: themeObj.secondaryColor,
                                        size: 50,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return Center(child: Text('No apps found'));
                                  } else {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        Application app = snapshot.data![index];
                                        return ListTile(
                                            onTap: () {
                                              Navigator.push(context,  MaterialPageRoute(builder: (context) => SetTimer(appName: app.packageName, appIcon: app is ApplicationWithIcon
                                                  ? Image.memory(app.icon, width: 40, height: 40)
                                                  : Icon(Icons.android),),));
                                            },
                                          leading: app is ApplicationWithIcon
                                              ? Image.memory(app.icon, width: 40, height: 40)
                                              : Icon(Icons.android),
                                          title: Text(app.appName),
                                          subtitle: Text(app.packageName),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          )


                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      },);

  }
  bool isSwitched = false;
  var textValue = 'Switch is OFF';
  void toggleSwitch(bool value) {

    if(isSwitched == false)
    {
      setState(() {
        isSwitched = true;
        textValue = 'Switch Button is ON';
      });
      print('Switch Button is ON');
    }
    else
    {
      setState(() {
        isSwitched = false;
        textValue = 'Switch Button is OFF';
      });
      print('Switch Button is OFF');
    }
  }
  CustomTheme themeObj=CustomTheme();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText("App Limit",style: TextStyle(color: themeObj.textBlack,fontWeight: FontWeight.w400,fontSize: size.width*0.045),),
                    Switch(
                      onChanged: toggleSwitch,
                      value: isSwitched,

                      activeColor: Colors.blue,
                      activeTrackColor: Colors.blueAccent[50],
                      inactiveThumbColor: Colors.red,
                      inactiveTrackColor: Colors.redAccent[100],
                    ),

                  ],
                ),
        ),
      ),
          SizedBox(height: size.height*0.02,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: AutoSizeText("Set daily time limits for app categories you want to manage.App limits reset every day at midnight",style: TextStyle(color: themeObj.textGrey,fontWeight: FontWeight.w400,fontSize: size.width*0.035),),
          ),
          SizedBox(height: size.height*0.02,),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                width: size.width,
                child: TextButton(
                  onPressed: () {
                    _addNewResultPopup(context,size);
                  },
                  child:  AutoSizeText("Add Limit",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w400,fontSize: size.width*0.045),),


                ),
              )
            ),
          ),


        ],
      ),
    );
  }
}
