import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utility{

  static void showSnackBar(BuildContext context,String msg)
  {

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(msg)),);
  }
  //convert the datetime into a proper format 
  static String formatTime({required BuildContext context,required String msg}){
    final date=DateTime.fromMillisecondsSinceEpoch(int.parse(msg));

    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageTime(String time,BuildContext context){
    final date=DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final now=DateTime.now();
    if(now.day==date.day && now.month==date.month && now.year==date.year){
      return TimeOfDay.fromDateTime(date).format(context);
    }

    return  '${date.day} ${_getMonth(date)}';
  }
   static _getMonth(DateTime date){
    switch (date.month) {
      case 1:
        return 'jan';
      case 2:
        return 'feb';
      case 3:
        return 'mar';
      case 4:
        return 'apr';
      case 5:
        return 'may';
      case 6:
        return 'jun';
      case 7:
        return 'jul';
      case 8:
        return 'aug';
      case 9:
        return 'sept';
      case 10:
        return 'oct';
      case 11:
        return 'nov';
      case 12:
        return 'dec';
    }
    return 'N/A';
   }
}