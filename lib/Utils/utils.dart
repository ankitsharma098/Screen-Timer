import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

  class Utils{
  static showGreenSnackBar(String message,BuildContext context){

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message,
          style: GoogleFonts.openSans(fontSize: 15,color: Colors.black),),backgroundColor: Colors.green,),
      snackBarAnimationStyle:AnimationStyle(
          duration: Duration(microseconds: 50),
          reverseDuration: Duration(microseconds: 50)

      ),

    );

  }
  static showRedSnackBar(String message,BuildContext context){

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message,style:
      GoogleFonts.openSans(fontSize: 15,color: Colors.black),),
        backgroundColor: Colors.red,),
      snackBarAnimationStyle:AnimationStyle(
      duration: Duration(microseconds: 50),
    reverseDuration: Duration(microseconds: 50))
    );

  }
}