import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:usage_stats/usage_stats.dart';

import 'usage.dart';

final auth = FirebaseAuth.instance;
final usage = new Usage();


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

  Future updateUsageToday() async {
    var usageStatsToday = await Usage.getUsageStats(0);
    
    usageStatsToday?.sort((a, b) => b.duration.compareTo(a.duration));
    var timeToday = Usage.calcDuration(usageStatsToday);

    usageStatsYesterday = await Usage.getUsageStats(-1);
    usageStatsYesterday.sort((a, b) => b.duration.compareTo(a.duration));
    var timeYesterday = Usage.calcDuration(usageStatsYesterday);
    UsageStore.store(Usage.getStartOfDay(-1), timeYesterday, usageStatsYesterday);

    setState(() {
      this.usageToday = formatTime(timeToday);
      this.usageStatsToday = usageStatsToday;
      this.usageStatsYesterday = usageStatsYesterday;
      this.usageYesterday = formatTime(timeYesterday);
    });
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

  Widget homeView() {
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

  @override
  Widget build(BuildContext context) {
    return homeView();
  }
}