package com.app.coursei

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import android.view.WindowManager;

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    // Our native splash screen was FULLSCREEN, let's clear the flag.
    window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
  }
}
