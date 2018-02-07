import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:usage_stats/usage_stats_impl.dart';

import 'TimieHomePage.dart' as TimieHomePage;
import 'usage.dart' as Usage;
import 'usageStore.dart';
import 'DI.dart';

final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;
final usageStats = new UsageStats();
final usage = new Usage.Usage(usageStats);


Future<bool> silentLogIn() async {
 GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null)
    user = await googleSignIn.signInSilently();
  
  if (user == null)
    return false;
  
  await authenticate();
  return true;
}

Future<Null> authenticate() async {
    if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
    await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  }
}

Future<Null> saveUsage() async {
    if (UsageStore.lastWriteTime != null && UsageStore.lastWriteTime.millisecondsSinceEpoch >= Usage.Usage.getStartOfDay(-1).millisecondsSinceEpoch) {
      print("Usage already stored.");
      return;
    }

    var usageStatsYesterday = await usage.getUsageStats(-1);
    usageStatsYesterday.sort((a, b) => b.duration.compareTo(a.duration));
    var timeYesterday = Usage.Usage.calcDuration(usageStatsYesterday);
    UsageStore.store(Usage.Usage.getStartOfDay(-1), timeYesterday, usageStatsYesterday);
    print("Usage was successfully stored.");
}

var globalLoggedIn = false;
Future<Null>   main() async {
    final int alarmID = 99;
    silentLogIn().then((u) async {
      globalLoggedIn = u;
      runApp(new TimieApp());
      var result = await AndroidAlarmManager.periodic(const Duration(minutes: 30), alarmID, saveUsage);
      print ('$result');
    });
}

class TimieApp extends StatelessWidget 
{  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DI.setInstance<Usage.Usage>(usage);
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: getHome(),
    );
  }

  Widget getHome() {
    //return new TimieHomePage.TimieHomePage(title: 'Timie');
    return new Home();
  }
}

class HomeState extends State<Home> {
  var loggedIn = globalLoggedIn;

  Future<Null> logIn() async
  {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user != null)
      return;

    user = await googleSignIn.signIn();
    await analytics.logLogin();
    await authenticate();
    setState(() {
      this.loggedIn = user != null;
    });
 }

  @override
  Widget build(BuildContext context) {
    if (this.loggedIn)
      return new TimieHomePage.TimieHomePage(title: "Timie",);

    return new Card(
      child: new Padding(
       padding:   new EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 20.0),
      child : new Column(
      children: <Widget>[
        new FlatButton(
          child: new Text("Bitte anmelden"),
           color: Colors.amber,
           onPressed: logIn,
          )
      ],
    )));
  }
}

class Home extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() => new HomeState();
}