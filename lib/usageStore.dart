import 'dart:async';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:usage_stats/usage_stats_data.dart';

final auth = FirebaseAuth.instance;

class UsageStore
{
  static DateTime lastWriteTime;
  static Future<Null>  store(DateTime day, int duration, List<UsageStatsData> list) async {
     var user = await auth.currentUser();
     final users = FirebaseDatabase.instance.reference().child("users");
     var usages = users.child("${user.uid}/usages");
     
      var formatter = new DateFormat('yyyyMMdd');
      var date = formatter.format(day);
     var value = await usages.child(date).once();
     if (value.value != null) {
        lastWriteTime = day;
        return;
     }
  
    dynamic map = {};
    if (list.length == 0) {
      map["com_none_app"] = { 'duration': 0, 'appName': "none", 'packageName': "com.none.app"} ;
    } else {
      for (var usage in list)
      {
        if (usage.packageName.endsWith("launcher"))
          continue;
        
        if (usage.duration < 10000)
          continue;

        var key = usage.packageName.replaceAll('.', '_');
        map[key] = { 'duration': usage.duration, 'appName': usage.appName, 'packageName': usage.packageName} ;
      }     
    }
    usages.child(date).set({'duration' : duration, "appUsage" : map});
    lastWriteTime = day;
  }
}

