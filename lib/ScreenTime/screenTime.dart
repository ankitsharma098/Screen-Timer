import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:usage_stats/usage_stats.dart';
import '../CustomTheme/CustomTheme.dart';
import '../barGraph/bargraph.dart';
import 'particularAppTiming.dart';

class ScreenTime extends StatefulWidget {
  const ScreenTime({super.key});

  @override
  State<ScreenTime> createState() => _ScreenTimeState();
}
class _ScreenTimeState extends State<ScreenTime> with TickerProviderStateMixin {
  CustomTheme themeObj = CustomTheme();
  late TabController tabBarController;
  bool todaySelected = true;
  bool last7Selected = false;
  bool _showingAllApps = false;
  List<UsageInfo> _allProcessedUsageData = [];
  List<UsageInfo> _displayedUsageData = [];
  List<UsageInfo> _all7dayProcessedUsageData = [];
  List<UsageInfo> _displayed7daysUsageData = [];
  List<UsageInfo> _usageData = [];

  void _handleTabSelection() {
    setState(() {
      if (tabBarController.index == 0) {
        todaySelected = true;
        last7Selected = false;
        getUsageStats(); // No need to re-check permission here
      } else {
        todaySelected = false;
        last7Selected = true;
        get7dayUsageStats();
      }
    });
  }

  Future<void> checkAndRequestUsagePermission() async {
    bool? isPermissionGranted = await UsageStats.checkUsagePermission();
    if (!isPermissionGranted!) {
      await UsageStats.grantUsagePermission();
      isPermissionGranted = await UsageStats.checkUsagePermission();
      if (isPermissionGranted!) {
        await getUsageStats();
        await get7dayUsageStats();
      }
    } else {
      await getUsageStats();
      await get7dayUsageStats();
    }
  }

  String formatDuration(int milliseconds) {
    Duration d = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

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
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps(true, false);
    _allProcessedUsageData = _usageData.where((usage) {
      return installedApps.any((app) => app.packageName == usage.packageName);
    }).toList();

    _allProcessedUsageData.sort((a, b) => getUsageTimeInMillis(b).compareTo(getUsageTimeInMillis(a)));
    _allProcessedUsageData = _allProcessedUsageData.fold<List<UsageInfo>>([], (list, item) {
      if (!list.any((element) => element.packageName == item.packageName)) {
        list.add(item);
      }
      return list;
    });

    _displayedUsageData = _allProcessedUsageData.take(5).toList();
    setState(() {});
  }

  Future<void> getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(hours: 24));
      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
      if (usageStats.isEmpty) {
        print("No usage data found for the last 24 hours");
      } else {
        usageStats.forEach((usage) {
          print("App: ${usage.packageName}, Time: ${usage.totalTimeInForeground}");
        });
      }
      setState(() {
        _usageData = usageStats;
      });
      await processUsageData();
    } catch (exception) {
      print("Error fetching usage stats: $exception");
    }
  }

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

  Future<void> process7daysUsageData() async {
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps(true, false);
    _all7dayProcessedUsageData = _usageData.where((usage) {
      return installedApps.any((app) => app.packageName == usage.packageName);
    }).toList();

    _all7dayProcessedUsageData.sort((a, b) => getUsageTimeInMillis(b).compareTo(getUsageTimeInMillis(a)));
    _all7dayProcessedUsageData = _all7dayProcessedUsageData.fold<List<UsageInfo>>([], (list, item) {
      if (!list.any((element) => element.packageName == item.packageName)) {
        list.add(item);
      }
      return list;
    });

    _displayed7daysUsageData = _all7dayProcessedUsageData.take(5).toList();
    setState(() {});
  }

  Future<void> get7dayUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 7));
      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
      if (usageStats.isEmpty) {
        print("No usage data found for the last 7 days");
      } else {
        usageStats.forEach((usage) {
          print("App: ${usage.packageName}, Time: ${usage.totalTimeInForeground}");
        });
      }
      setState(() {
        _usageData = usageStats;
      });
      await process7daysUsageData();
    } catch (exception) {
      print("Error fetching 7-day usage stats: $exception");
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
    // TODO: implement initState
    super.initState();
    tabBarController = TabController(length: 2, vsync: this);
    tabBarController.addListener(_handleTabSelection);
    getUsageStats(); // Rely on Home.dart for permission handling
    get7dayUsageStats();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.1,
            child: TabBar(
              controller: tabBarController,
              indicatorColor: Colors.transparent,
              tabs: [
                Card(
                  color: todaySelected ? themeObj.primaryColor : Color.fromRGBO(209, 213, 219, 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    height: size.height * 0.045,
                    child: Center(
                      child: Text(
                        "Today",
                        style: GoogleFonts.openSans(fontSize: size.width * 0.055, color: themeObj.textBlack),
                      ),
                    ),
                  ),
                ),
                Card(
                  color: last7Selected ? themeObj.primaryColor : Color.fromRGBO(209, 213, 219, 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    height: size.height * 0.045,
                    child: Center(
                      child: Text(
                        "Last 7 Days",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(fontSize: size.width * 0.055, color: themeObj.textBlack),
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
                            Text("Screen Time", style: GoogleFonts.openSans(fontSize: size.width * 0.05, color: themeObj.textBlack, fontWeight: FontWeight.w400)),
                            Text("today ", style: GoogleFonts.roboto(fontSize: size.width * 0.05, color: themeObj.textGrey, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        _allProcessedUsageData.isEmpty
                            ? Center(child: Text("No Usage Found"))
                            : Column(
                          children: [
                            DailyUsageChart(data: convertUsageDataToChartFormat(_allProcessedUsageData)),
                            SizedBox(height: size.height * 0.025),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Most Used", style: GoogleFonts.openSans(fontSize: size.width * 0.05, color: themeObj.textBlack, fontWeight: FontWeight.w400)),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showingAllApps = !_showingAllApps;
                                      _displayedUsageData = _showingAllApps ? _allProcessedUsageData : _allProcessedUsageData.take(5).toList();
                                    });
                                  },
                                  child: Text(_showingAllApps ? "Show Less" : "Show All", style: GoogleFonts.openSans(fontSize: size.width * 0.04, color: Colors.blue, fontWeight: FontWeight.w400)),
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
                                    final packageName = usage.packageName;
                                    return Card(
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ParticularAppTiming(
                                                appName: packageName!,
                                                usage: usage,
                                                iconWidget: getAppIcon(usage.packageName ?? ''),
                                              ),
                                            ),
                                          );
                                        },
                                        leading: getAppIcon(usage.packageName ?? ''),
                                        title: Text(appName, style: GoogleFonts.openSans(fontSize: size.width * 0.035, color: themeObj.textBlack, fontWeight: FontWeight.w400)),
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
                            ),
                          ],
                        ),
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
                            Text("Screen Time", style: GoogleFonts.openSans(fontSize: size.width * 0.05, color: themeObj.textBlack, fontWeight: FontWeight.w400)),
                            Text("last 7 days ", style: GoogleFonts.roboto(fontSize: size.width * 0.05, color: themeObj.textGrey, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        _all7dayProcessedUsageData.isEmpty
                            ? Center(child: Text("No Usage Found"))
                            : Column(
                          children: [
                            DailyUsageChart(data: convertUsageDataToChartFormat(_all7dayProcessedUsageData)),
                            SizedBox(height: size.height * 0.025),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Most Used", style: GoogleFonts.openSans(fontSize: size.width * 0.05, color: themeObj.textBlack, fontWeight: FontWeight.w400)),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showingAllApps = !_showingAllApps;
                                      _displayed7daysUsageData = _showingAllApps ? _all7dayProcessedUsageData : _all7dayProcessedUsageData.take(5).toList();
                                    });
                                  },
                                  child: Text(_showingAllApps ? "Show Less" : "Show All", style: GoogleFonts.openSans(fontSize: size.width * 0.04, color: Colors.blue, fontWeight: FontWeight.w400)),
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
                                        title: Text(appName, style: GoogleFonts.openSans(fontSize: size.width * 0.035, color: themeObj.textBlack, fontWeight: FontWeight.w400)),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}