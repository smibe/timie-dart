package com.smibe.timie

import android.os.Bundle
import android.util.Log

import io.flutter.app.FlutterApplication
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.androidalarmmanager.AlarmService
import io.flutter.view.FlutterNativeView



class MainActivity(): FlutterActivity() {
    val TAG = "TimieMainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
  }
}
