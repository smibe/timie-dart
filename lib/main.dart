import 'dart:async';
import 'dart:math';
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
  List<UsageStatsData> usageStatsToday;
  List<UsageStatsData> usageStatsYesterday;

  Future<List<UsageStatsData>> getUsageStats(int dayOffset) async {
    var now = new  DateTime.now();
    var start = new DateTime(now.year, now.month, now.day, 0, 0, 1);
    if (dayOffset != 0) 
      start = start.add(new Duration(days: dayOffset));

    var end = new DateTime(start.year, start.month, start.day, 23, 59, 58);
    if (end.millisecondsSinceEpoch > now.millisecondsSinceEpoch)
      end = now;

    return await UsageStats.usageStats(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch);
  }

  Future updateUsageToday() async {
    var usageStatsToday = await getUsageStats(0);
    
    usageStatsToday?.sort((a, b) => b.duration.compareTo(a.duration));
    var timeToday = calcDuration(usageStatsToday);

    usageStatsYesterday = await getUsageStats(-1);
    usageStatsYesterday.sort((a, b) => b.duration.compareTo(a.duration));
    var timeYesterday = calcDuration(usageStatsYesterday);


    setState(() {
      this.usageToday = formatTime(timeToday);
      this.usageStatsToday = usageStatsToday;
      this.usageStatsYesterday = usageStatsYesterday;
      this.usageYesterday = formatTime(timeYesterday);
    });
  }

  int calcDuration(List<UsageStatsData> list)
  {
      num duration = 0;
      for (var s in list) {
          if (s.duration > 1000 && !s.packageName.endsWith("launcher")) {
            duration += s.duration;
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

  List<Widget> usageStatsWidgets(List<UsageStatsData> list)
  {
    List<Widget> usageWidgets = new List<Widget>();
    if (list == null) 
      return usageWidgets;
    
    for (int i = 0; i < min (5, list.length); i++)
    {
        var u = list[i];
        if (u.duration > 3000 && !u.packageName.endsWith("launcher"))
        {
          usageWidgets.add(new Text('${u.appName} : ${formatTime(u.duration)}', textScaleFactor: 0.8,));
        }
    }
    return usageWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: 
        new Padding (
          padding:   new EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
          child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text('Zeit am Handy:', textScaleFactor: 1.2,),
            new Container(
              color: Colors.grey[300],
              padding: new EdgeInsets.all(3.0),
              child: new Row(children: [
                  new Text('Heute: '),
                  new Text('$usageToday'),
                ]),
            ),
            new Padding(padding: new EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 5.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: usageStatsWidgets(usageStatsToday),
              ),
            ),
            new Container(
              color: Colors.grey[300],
              padding: new EdgeInsets.all(3.0),
              child: new Row(children: [
                  new Text('Gestern: '),
                  new Text('$usageYesterday'),
            ]),
            ),
            new Padding(padding: new EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 5.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: usageStatsWidgets(usageStatsYesterday),
              ),
            ),
            ]),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: updateUsageToday,
        tooltip: 'Neu laden',
        child: new Icon(Icons.refresh),
      ),
    );
  }
}
