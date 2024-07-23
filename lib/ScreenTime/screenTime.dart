import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled4/ScreenTime/particularAppTiming.dart';

import 'package:usage_stats/usage_stats.dart';

import '../CustomTheme/CustomTheme.dart';
import '../barGraph/bargraph.dart';

class ScreenTime extends StatefulWidget {
  const ScreenTime({super.key});

  @override
  State<ScreenTime> createState() => _ScreenTimeState();
}

class _ScreenTimeState extends State<ScreenTime>with TickerProviderStateMixin {
  CustomTheme themeObj=CustomTheme();
  late TabController tabBarController;
  bool todaySelected = true;
  bool last7Selected = false;
  bool _showingAllApps = false;
  List<UsageInfo> _allProcessedUsageData = [];
  List<UsageInfo> _displayedUsageData = [];

  void _handleTabSelection() {
    setState(() {
      if (tabBarController.index == 0) {
        todaySelected = true;
        last7Selected = false;
        getUsageStats();
      } else {
        todaySelected = false;
        last7Selected = true;
        get7dayUsageStats();
      }
    });
  }


  String formatDuration(int milliseconds) {
    Duration d = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  List<UsageInfo> _usageData = [];


  int getUsageTimeInMillis(UsageInfo usage) {
    return int.tryParse(usage.totalTimeInForeground?.toString() ?? '0') ?? 0;
  }


  List<Map<String, dynamic>> convertUsageDataToChartFormat(List<UsageInfo> usageData) {
    if (usageData.isEmpty) return [];
    return usageData.map((usage) {
      return {
        "icon": Icons.apps,
        "name": usage.packageName ?? "Unknown",
        "usage": getUsageTimeInMillis(usage) / (60 * 1000),
      };
    }).toList();
  }


  Future<void> processUsageData() async {
    List<Application> installedApps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );

    _allProcessedUsageData = _usageData.where((usage) {
      return installedApps.any((app) => app.packageName == usage.packageName);
    }).toList();

    _allProcessedUsageData.sort((a, b) =>
        getUsageTimeInMillis(b).compareTo(getUsageTimeInMillis(a)));

    // Remove duplicates based on package name
    _allProcessedUsageData = _allProcessedUsageData.fold<List<UsageInfo>>([], (list, item) {
      if (!list.any((element) => element.packageName == item.packageName)) {
        list.add(item);
      }
      return list;
    });

    // Initially display only top 5 apps
    _displayedUsageData = _allProcessedUsageData.take(5).toList();

    setState(() {});
  }


  Future<void> getUsageStats() async {


    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(hours: 24));

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
      print(usageStats);
      setState(() {
        _usageData = usageStats;
      });

      await processUsageData();

      setState(() {});
    } catch (exception) {
      print(exception);
    }
  }


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

  List<UsageInfo> _all7dayProcessedUsageData = [];
  List<UsageInfo> _displayed7daysUsageData = [];


  Future<void> process7daysUsageData() async {
    List<Application> installedApps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );

    _all7dayProcessedUsageData = _usageData.where((usage) {
      return installedApps.any((app) => app.packageName == usage.packageName);
    }).toList();

    _all7dayProcessedUsageData.sort((a, b) =>
        getUsageTimeInMillis(b).compareTo(getUsageTimeInMillis(a)));

    // Remove duplicates based on package name
    _all7dayProcessedUsageData = _all7dayProcessedUsageData.fold<List<UsageInfo>>([], (list, item) {
      if (!list.any((element) => element.packageName == item.packageName)) {
        list.add(item);
      }
      return list;
    });

    // Initially display only top 5 apps
    _displayed7daysUsageData = _all7dayProcessedUsageData.take(5).toList();

    setState(() {});
  }


  Future<void> get7dayUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 07));

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);

      setState(() {
        _usageData = usageStats;
      });

      await process7daysUsageData();

      setState(() {});  // Add this line to trigger a rebuild after processing
    } catch (exception) {
      print(exception);
    }
  }

  @override
  void dispose() {
    tabBarController.removeListener(_handleTabSelection);
    tabBarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 2, vsync: this);
    tabBarController.addListener(_handleTabSelection);
    getUsageStats();
    get7dayUsageStats();
  }
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body:  Column(
          children: [
            SizedBox(
              height: size.height * 0.1, // Adjust this height based on your needs
              child: TabBar(
                controller: tabBarController,
                indicatorColor: Colors.transparent,
                tabs: [
                  Card(
                    color: todaySelected
                        ? themeObj.primaryColor
                        : Color.fromRGBO(209, 213, 219, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Container(
                      height: size.height * 0.045,
                      child: Center(
                        child: Text(
                          "Today",
                          style: GoogleFonts.openSans(
                            fontSize: size.width * 0.055,
                            color: themeObj.textBlack,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: last7Selected
                        ? themeObj.primaryColor
                        : Color.fromRGBO(209, 213, 219, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Container(
                      height: size.height * 0.045,
                      child: Center(
                        child: Text(
                          "Last 7 Days",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                            fontSize: size.width * 0.055,
                            color: themeObj.textBlack,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(

              child: TabBarView(
                  controller: tabBarController,
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Screen Time",
                                  style: GoogleFonts.openSans(
                                      fontSize: size.width * 0.05,
                                      color: themeObj.textBlack,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "today ",
                                  style: GoogleFonts.roboto(
                                    fontSize: size.width * 0.05,
                                    color: themeObj.textGrey,
                                    fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),

                            _allProcessedUsageData.isEmpty? Center(child: Text("No Usage Found")): Column(
                              children: [
                                DailyUsageChart(data: convertUsageDataToChartFormat(_allProcessedUsageData)),
                                SizedBox(height: size.height*0.025,),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Most Used",
                                      style: GoogleFonts.openSans(
                                          fontSize: size.width * 0.05,
                                          color: themeObj.textBlack,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _showingAllApps = !_showingAllApps;
                                          _displayedUsageData = _showingAllApps ? _allProcessedUsageData : _allProcessedUsageData.take(5).toList();
                                        });
                                      },
                                      child: Text(
                                        _showingAllApps ? "Show Less" : "Show All",
                                        style: GoogleFonts.openSans(
                                          fontSize: size.width * 0.04,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _displayedUsageData.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final usage = _displayedUsageData[index];
                                    final usageTime = getUsageTimeInMillis(usage);
                                    final maxUsageTime = getUsageTimeInMillis(_allProcessedUsageData[0]);

                                    return FutureBuilder<String>(
                                      future: getAppName(usage.packageName ?? 'Unknown'),
                                      builder: (context, snapshot) {
                                        final appName = snapshot.data ?? 'Loading...';
                                        final packageName=usage.packageName;
                                        return Card(
                                          child: ListTile(
                                            onTap: () {
                                           Navigator.push(context, MaterialPageRoute(builder: (context) =>  ParticularAppTiming(appName: packageName, usage: usage, iconWidget:  getAppIcon(usage.packageName ?? ''),),));
                                            },
                                            leading: getAppIcon(usage.packageName ?? ''),
                                            title: Text(
                                              appName,
                                              style: GoogleFonts.openSans(
                                                fontSize: size.width * 0.035,
                                                color: themeObj.textBlack,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            subtitle: LinearProgressIndicator(
                                              backgroundColor: themeObj.textGrey,
                                              color: themeObj.secondaryColor,
                                              borderRadius: BorderRadius.circular(12),
                                              valueColor: AlwaysStoppedAnimation(themeObj.secondaryColor),
                                              value: usageTime / maxUsageTime,
                                            ),
                                            trailing: Text(formatDuration(usageTime)),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )

                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Screen Time",
                                  style: GoogleFonts.openSans(
                                      fontSize: size.width * 0.05,
                                      color: themeObj.textBlack,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "last 7 days ",
                                  style: GoogleFonts.roboto(
                                    fontSize: size.width * 0.05,
                                    color: themeObj.textGrey,
                                    fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),

                            _all7dayProcessedUsageData.isEmpty? Center(child: Text("No Usage Found")): Column(
                              children: [
                                DailyUsageChart(data: convertUsageDataToChartFormat(_all7dayProcessedUsageData)),
                                SizedBox(height: size.height*0.025,),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Most Used",
                                      style: GoogleFonts.openSans(
                                          fontSize: size.width * 0.05,
                                          color: themeObj.textBlack,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _showingAllApps = !_showingAllApps;
                                          _displayed7daysUsageData = _showingAllApps ? _all7dayProcessedUsageData : _all7dayProcessedUsageData.take(5).toList();
                                        });
                                      },
                                      child: Text(
                                        _showingAllApps ? "Show Less" : "Show All",
                                        style: GoogleFonts.openSans(
                                          fontSize: size.width * 0.04,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _displayed7daysUsageData.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final usage = _displayed7daysUsageData[index];
                                    final usageTime = getUsageTimeInMillis(usage);
                                    final maxUsageTime = getUsageTimeInMillis(_all7dayProcessedUsageData[0]);

                                    return FutureBuilder<String>(
                                      future: getAppName(usage.packageName ?? 'Unknown'),
                                      builder: (context, snapshot) {
                                        final appName = snapshot.data ?? 'Loading...';
                                        return Card(
                                          child: ListTile(
                                            leading: getAppIcon(usage.packageName ?? ''),
                                            title: Text(
                                              appName,
                                              style: GoogleFonts.openSans(
                                                fontSize: size.width * 0.035,
                                                color: themeObj.textBlack,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            subtitle: LinearProgressIndicator(
                                              backgroundColor: themeObj.textGrey,
                                              color: themeObj.secondaryColor,
                                              borderRadius: BorderRadius.circular(12),
                                              valueColor: AlwaysStoppedAnimation(themeObj.secondaryColor),
                                              value: usageTime / maxUsageTime,
                                            ),
                                            trailing: Text(formatDuration(usageTime)),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )

                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ]),
            )
          ],
        ),


    );
  }
}
