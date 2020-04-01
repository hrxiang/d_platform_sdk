package org.dplatform.d_platform_sdk_example

import android.content.Intent
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        println("============call  native MainActivity onNewIntent===============")
    }
}
