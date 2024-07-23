import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_apps/device_apps.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:usage_stats/usage_stats.dart';

import '../CustomTheme/CustomTheme.dart';
import '../Timer/setTimer.dart';
import '../barGraph/bargraph.dart';

class ParticularAppTiming extends StatefulWidget {
  const ParticularAppTiming({super.key, required this.appName, required this.usage, required this.iconWidget, });
  final appName;
  final usage;
  final Widget iconWidget;



  @override
  State<ParticularAppTiming> createState() => _ParticularAppTimingState();
}

class _ParticularAppTimingState extends State<ParticularAppTiming> {



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
  List<FlSpot> getUsageSpots() {
    UsageInfo usage = widget.usage as UsageInfo;
    double usageInMinutes = getUsageTimeInMillis(usage) / (60 * 1000);
    return [FlSpot(0, usageInMinutes)];
  }

  CustomTheme themeObj=CustomTheme();
  @override
  Widget build(BuildContext context) {
    final appName= widget.appName.split('.').last;
    Size size = MediaQuery.of(context).size;
    UsageInfo usage = widget.usage as UsageInfo;
    double usageInMinutes = getUsageTimeInMillis(usage) / (60 * 1000);
    double usageInHours = usageInMinutes / 60;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: size.height*0.08,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: themeObj.textBlack,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:SizedBox(
          width: size.width*0.6,
          child: Row(
            children: [
              widget.iconWidget,
              SizedBox(width: size.width*0.02,),
              AutoSizeText(appName,overflow: TextOverflow.ellipsis,style: GoogleFonts.openSans(color: themeObj.textBlack,fontWeight: FontWeight.w400,fontSize: size.width*0.06),),
            ],
          ),
        ),
        backgroundColor: themeObj.primaryColor,
        shape: UnderlineInputBorder(
            borderSide: BorderSide(color: themeObj.textGrey)),
      ),
      body:Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          SizedBox(height: size.height*0.03),
          Center(
            child: Text(
              'App Usage: ${widget.appName}',
              style: GoogleFonts.openSans(fontSize:size.width*0.045,color:themeObj.textBlack,fontWeight:FontWeight.w500),),
          ),
          SizedBox(height: size.height*0.04),
          _buildPieChart(usageInHours),
          SizedBox(height: size.height*0.04),
          Text(
            'Total Usage: ${usageInMinutes.toStringAsFixed(2)} minutes',
            style: GoogleFonts.openSans(fontSize:size.width*0.035,color:themeObj.textBlack),),
          SizedBox(height: size.height*0.02),
          Text(
            'Total Usage: ${usageInHours.toStringAsFixed(2)} hours',
            style: GoogleFonts.openSans(fontSize:size.width*0.035,color:themeObj.textBlack),),
          SizedBox(height: size.height*0.04),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: themeObj.secondaryColor),
              onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SetTimer(appName: widget.appName, appIcon: widget.iconWidget,),));
              },
              child: Text("Set Limit ",
                style: GoogleFonts.openSans(fontSize:size.width*0.035,color:themeObj.textBlack),))
        ],
      ),
    );
  }
  Widget _buildPieChart(double usageInHours) {
    return Container(
      height: 150,
      width: 150,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: themeObj.primaryColor,
              value: usageInHours,
              title: '${usageInHours.toStringAsFixed(1)}h',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.grey[300],
              value: 24 - usageInHours,
              title: '',
              radius: 50,
            ),
          ],
        ),
      ),
    );
  }

}

