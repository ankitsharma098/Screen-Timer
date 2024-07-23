import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:usage_stats/usage_stats.dart';

import '../CustomTheme/CustomTheme.dart';
import '../Utils/utils.dart';

class SetTimer extends StatefulWidget {
  const SetTimer({super.key, required this.appName, required this.appIcon});
  final appName;
  final Widget appIcon;

  @override
  State<SetTimer> createState() => _SetTimerState();
}

class _SetTimerState extends State<SetTimer> {

  void formatUsageTime(int usageMinutes) {
    int hours = usageMinutes ~/ 60; // Integer division to get the hours
    int minutes = usageMinutes % 60; // Modulus to get the remaining minutes

    // Format the hours and minutes into a string
    String formattedTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
   setState(() {
     usageTiming=formattedTime;
   });
  }
String usageTiming="";
  Future<void> getUsageData() async {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 1));

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);

      for (var usageInfo in usageStats) {
        if (usageInfo.packageName == widget.appName) {
          int usageMinutes = 0;
          if (usageInfo.totalTimeInForeground != null) {
            int totalTimeInMs = int.tryParse(usageInfo.totalTimeInForeground!) ?? 0;
            usageMinutes = (totalTimeInMs / (1000 * 60)).round();
          }
          print("Usage data for $widget.appName: ${usageInfo.totalTimeInForeground}");
          setState(() {
            formatUsageTime(usageMinutes);
          });
          break;
        }
      }


  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsageData();
  }

  CustomTheme themeObj=CustomTheme();
  @override
  Widget build(BuildContext context) {
    print(usageTiming);
    final appName= widget.appName.split('.').last;
    // UsageInfo usage = widget.usage as UsageInfo;
    // double usageInMinutes = getUsageTimeInMillis(usage) / (60 * 1000);
    // double usageInHours = usageInMinutes / 60;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,color: themeObj.textBlack,),
            onPressed: () {
           Navigator.pop(context);
            },
          ),
          title: AutoSizeText("Set Timing",style: TextStyle(color: themeObj.textBlack,fontWeight: FontWeight.w400,fontSize: size.width*0.06),),
          backgroundColor: themeObj.primaryColor,
          shape: UnderlineInputBorder(
              borderSide: BorderSide(color: themeObj.textGrey)),
        ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height*0.01,),
          SizedBox(
              height: size.height*0.5,
              width: size.width,
              child: CustomTimePicker(appName:widget.appName)),
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: AutoSizeText("APPS & CATEGORIES",style: TextStyle(color: themeObj.textGrey,fontWeight: FontWeight.w400,fontSize: size.width*0.04),),
            ),
            Divider(color: Colors.grey,thickness: 1,),
            ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {

                  return ListTile(
                    leading:   widget.appIcon,
                    title:  AutoSizeText(appName,style: GoogleFonts.openSans(color: themeObj.textBlack,fontWeight: FontWeight.w400,fontSize: size.width*0.05),),
                  trailing:     Text(
                    '${usageTiming} hours',
                    style: GoogleFonts.openSans(fontSize:size.width*0.045,color:themeObj.textBlack,fontWeight:FontWeight.w500),),
                  );

                }, separatorBuilder: (context, index) {
              return Divider();
            }, itemCount: 1)
          ],
        )
        ],
      ),
    );
  }
}

class CustomTimePicker extends StatefulWidget {
  const CustomTimePicker({super.key, required this.appName});
  final String appName;
  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  int hours = 0;
  int minutes = 0;
  CustomTheme themeObj=CustomTheme();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height*0.02),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AutoSizeText("Time",style: TextStyle(color: themeObj.textBlack,fontWeight: FontWeight.w400,fontSize: size.width*0.05),),
          ),
          SizedBox(height: size.height*0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPicker(hours, (value) => setState(() => hours = value), 23, 'hours'),
              const SizedBox(width: 20),
              _buildPicker(minutes, (value) => setState(() => minutes = value), 59, 'min'),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: themeObj.primaryColor),
              child:AutoSizeText("Set",style: TextStyle(color: themeObj.textBlack,fontWeight: FontWeight.w400,fontSize: size.width*0.045),),

              onPressed: () async{
                SharedPreferences pref =await SharedPreferences.getInstance();
                pref.setString("appName", "${widget.appName}");
                pref.setString("limit", "$hours:$minutes");
                  print(pref.getString("appName"));
                  print(pref.getString("limit"));
                print('Time set to $hours:$minutes');
              Utils.showGreenSnackBar("The ${widget.appName} has Set a limit of $hours:$minutes",context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker(int value, Function(int) onChanged, int maxValue, String label) {
    return Column(
      children: [
        Container(
          width: 80,
          child: Column(
            children: [
              AutoSizeText('$value'.padLeft(2, '0'), style: TextStyle(fontSize: 40)),
              Container(
                height: 2,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 80,
          child: NumberPicker(
            value: value,
            minValue: 0,
            maxValue: maxValue,
            onChanged: onChanged,
            itemHeight: 40,
            textStyle: TextStyle(fontSize: 20),
            selectedTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: 80,
          child: Column(
            children: [
              Container(
                height: 2,
                color: Colors.grey[300],
              ),
              SizedBox(height: 5),
              AutoSizeText(label),
            ],
          ),
        ),
      ],
    );
  }
}
