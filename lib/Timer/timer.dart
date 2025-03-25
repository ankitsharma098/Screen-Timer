import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../CustomTheme/CustomTheme.dart';
import '../Timer/setTimer.dart';

class AppLimit extends StatefulWidget {
  const AppLimit({super.key});

  @override
  State<AppLimit> createState() => _AppLimitState();
}

class _AppLimitState extends State<AppLimit> {
  Future<String> getAppName(String packageName) async {
    try {
      AppInfo? app = await InstalledApps.getAppInfo(packageName);
      return app?.name ?? packageName.split('.').last;
    } catch (e) {
      print('Error fetching app name for $packageName: $e');
      return packageName.split('.').last;
    }
  }

  Widget getAppIcon(String packageName) {
    return FutureBuilder<AppInfo?>(
      future: InstalledApps.getAppInfo(packageName),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.icon != null) {
          return Image.memory(snapshot.data!.icon!, width: 48, height: 48);
        } else {
          return Icon(Icons.apps, size: 48);
        }
      },
    );
  }

  Future<List<AppInfo>> getAllApps() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true,"");

      apps.map((app){ print("app name -- ${app.name}");});
      for(int i=0;i<apps.length;i++){
        print("apps name ${apps[i].name}");
      }

      return apps;
    } catch (e) {
      print('Error fetching apps: $e');
      return [];
    }
  }

  Future<void> _addNewResultPopup(BuildContext context, Size size) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
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
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: AutoSizeText(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w400,
                                      fontSize: size.width * 0.045),
                                ),
                              ),
                              AutoSizeText(
                                "Choose Apps",
                                style: TextStyle(
                                    color: themeObj.textBlack,
                                    fontWeight: FontWeight.w400,
                                    fontSize: size.width * 0.045),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SetTimer(
                                        appName: "ass",
                                        appIcon: SizedBox(),
                                      ),
                                    ),
                                  );
                                },
                                child: AutoSizeText(
                                  "Next",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: size.width * 0.045),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                "APPS & CATEGORIES",
                                style: TextStyle(
                                    color: themeObj.textGrey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: size.width * 0.04),
                              ),
                              Divider(color: Colors.grey, thickness: 1),
                              FutureBuilder<List<AppInfo>>(
                                future: getAllApps(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: LoadingAnimationWidget
                                          .threeArchedCircle(
                                        color: themeObj.secondaryColor,
                                        size: 50,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                        Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('No apps found'));
                                  } else {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        AppInfo app = snapshot.data![index];
                                        return ListTile(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SetTimer(
                                                  appName: app.packageName!,
                                                  appIcon: app.icon != null
                                                      ? Image.memory(
                                                      app.icon!,
                                                      width: 40,
                                                      height: 40)
                                                      : Icon(Icons.android),
                                                ),
                                              ),
                                            );
                                          },
                                          leading: app.icon != null
                                              ? Image.memory(app.icon!,
                                              width: 40, height: 40)
                                              : Icon(Icons.android),
                                          title: Text(app.name ?? "Unknown"),
                                          subtitle:
                                          Text(app.packageName ?? ""),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool isSwitched = false;
  var textValue = 'Switch is OFF';

  void toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
      textValue = value ? 'Switch Button is ON' : 'Switch Button is OFF';
    });
    print(textValue);
  }

  CustomTheme themeObj = CustomTheme();

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
                  AutoSizeText(
                    "App Limit",
                    style: TextStyle(
                        color: themeObj.textBlack,
                        fontWeight: FontWeight.w400,
                        fontSize: size.width * 0.045),
                  ),
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
          SizedBox(height: size.height * 0.02),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: AutoSizeText(
              "Set daily time limits for app categories you want to manage. App limits reset every day at midnight",
              style: TextStyle(
                  color: themeObj.textGrey,
                  fontWeight: FontWeight.w400,
                  fontSize: size.width * 0.035),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                width: size.width,
                child: TextButton(
                  onPressed: () {
                    _addNewResultPopup(context, size);
                  },
                  child: AutoSizeText(
                    "Add Limit",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w400,
                        fontSize: size.width * 0.045),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}