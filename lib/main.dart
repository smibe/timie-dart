import 'dart:async';
import 'package:flutter/material.dart';

import 'package:usage_stats/usage_stats.dart';


void main() => runApp(new TimieApp());

class TimieApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new TimieHomePage(title: 'Timie'),
    );
  }
}

class TimieHomePage extends StatefulWidget {
  TimieHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
    TimieHomePageState createState() => new TimieHomePageState();
}

class TimieHomePageState extends State<TimieHomePage> {
  String usageToday = '0:00';
  String usageYesterday = '0:00';

  Future<List<String>> getUsageStats(int dayOffset) async {
    var now = new  DateTime.now();
    var start = new DateTime(now.year, now.month, now.day);
    if (dayOffset != 0) 
      start = start.add(new Duration(days: dayOffset));

    var end = new DateTime(start.year, start.month, start.day + 1);
    return await UsageStats.usageStats(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch);
  }

  Future updateUsageToday() async {
    var timeToday = calcDuration(await getUsageStats(0));

    var timeYesterday = calcDuration(await getUsageStats(-1));


    setState(() {
      this.usageToday = formatTime(timeToday);
      this.usageYesterday = formatTime(timeYesterday);
    });
  }

  int calcDuration(List<String> list)
  {
      num duration = 0;
      for (var s in list) {
        var entry = s.split(";");
        if (entry.length == 2)
        {
          var t = int.parse(entry[0]);
          if (t > 1000 && !entry[1].endsWith("launcher")) {
            duration += num.parse(entry[0]);
          }
        }
      }
      return duration;
  }

  String formatTime(int duration)
  {
    var d = new Duration(milliseconds: duration);
    var result = d.toString();
    
    return result.substring(0, result.indexOf('.'));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Zeit am Handy:',
            ),
            new Text(
              'Heute: $usageToday',
            ),
            new Text(
              'Gestern: $usageYesterday',
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: updateUsageToday,
        tooltip: 'Neu laden',
        child: new Icon(Icons.refresh),
      ),
    );
  }
}
