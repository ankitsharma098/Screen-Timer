import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled4/Utils/utils.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:workmanager/workmanager.dart';


import 'Home.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    "checkAppUsageLimits",
    frequency: Duration(seconds: 15), // Adjust frequency as needed
  );
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home()));
}



void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await checkAppUsageLimit();
    print("WorkManager Initialised");
    return Future.value(true);
  });
}

Future<void> checkAppUsageLimit() async {

  //String appName = "com.example.app"; // Replace with your app's package name
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? appName = prefs.getString("aapName"); // Replace with your app's package name
  String? storedLimitString = prefs.getString("limit");

  if (storedLimitString != null) {
    List<String> parts = storedLimitString.split(':');
    int limitHours = int.parse(parts[0]);
    int limitMinutes = int.parse(parts[1]);
    int totalLimitMinutes = (limitHours * 60) + limitMinutes;

    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 1));

    List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);

    for (var usageInfo in usageStats) {
      if (usageInfo.packageName == appName) {
        int usageMinutes = 0;
        if (usageInfo.totalTimeInForeground != null) {
          // Convert to int before division
          int totalTimeInMs = int.tryParse(usageInfo.totalTimeInForeground!) ?? 0;
          usageMinutes = (totalTimeInMs / (1000 * 60)).round();
        }
        print("Usage data for $appName: ${usageInfo.totalTimeInForeground}");

        if (usageMinutes > totalLimitMinutes) {
          // Notify user that app has exceeded its usage limit
          //   Utils obj=Utils();
          //   BuildContext context ;
          //   obj.showGreenSnackBar("Usage Limit ExceededYou have exceeded ",context);
          await showNotification("Usage Limit Exceeded", "You have exceeded the usage limit for $appName.");
        }
        break;
      }
    }
  }
}

Future<void> showNotification(String title, String body) async {
  // Implement notification logic using flutter_local_notifications or another notification package
  print('$title: $body');
  print("More than used");
}


















