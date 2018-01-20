import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import './TimieHomePage.dart' as TimieHomePage;

final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;

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

var globalLoggedIn = false;
void main() {
  silentLogIn().then((u) {
    globalLoggedIn = u;
    runApp(new TimieApp());
  });
}

class TimieApp extends StatelessWidget 
{  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
    analytics.logLogin();
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