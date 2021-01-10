package com.example.business_travel

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import com.tekartik.sqflite.SqflitePlugin

import io.flutter.view.FlutterMain
import rekab.app.background_locator.LocatorService

class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
        LocatorService.setPluginRegistrant(this)
        FlutterMain.startInitialization(this)
    }

    override fun registerWith(registry: PluginRegistry?) {
        if (!registry!!.hasPlugin("com.tekartik.sqflite.SqflitePlugin")) {
            SqflitePlugin.registerWith(registry!!.registrarFor("com.tekartik.sqflite.SqflitePlugin"))
        }
    }
}
