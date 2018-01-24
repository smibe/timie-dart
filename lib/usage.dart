import 'dart:async';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:usage_stats/usage_stats.dart';

final auth = FirebaseAuth.instance;

class UsageStore
{
  static Future<Null>  store(DateTime day, int duration, List<UsageStatsData> list) async {
     var user = await auth.currentUser();
     final users = FirebaseDatabase.instance.reference().child("users");
     var usages = users.child("${user.uid}/usages");
     
      var formatter = new DateFormat('yyyyMMdd');
      var date = formatter.format(day);
     var value = await usages.child(date).once();
     if (value.value != null)
        return;

    dynamic map = {};
    if (list.length == 0) {
      map["com.none.app"] = { 'duration': 0, 'appName': "none", 'packageName': "com.none.app"} ;
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
  }
}

class Usage {
    Usage();

    static DateTime getStartOfDay(num dayOffset)
    {
      var now = new  DateTime.now();
      var start = new DateTime(now.year, now.month, now.day, 0, 0, 1);
      if (dayOffset != 0) 
        start = start.add(new Duration(days: dayOffset));

      return start;
    }

    
    static Future<List<UsageStatsData>> getUsageStats(int dayOffset) async {
    
    var start = getStartOfDay(dayOffset);

    var end = new DateTime(start.year, start.month, start.day, 23, 59, 58);

    var now = new  DateTime.now();
    if (end.millisecondsSinceEpoch > now.millisecondsSinceEpoch)
      end = now;

    var result = await UsageStats.buildUsageStats(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch);

    return result;
  }

  static int calcDuration(List<UsageStatsData> list)
  {
      num duration = 0;
      for (var s in list) {
          if (s.duration > 1000 && !s.packageName.endsWith("launcher")) {
            duration += s.duration;
          }
      }
      return duration;
  }

}