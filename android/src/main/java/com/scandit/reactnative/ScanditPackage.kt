package com.scandit.reactnative

import android.view.View
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.SimpleViewManager
import kotlin.collections.ArrayList

class ScanditPackage : ReactPackage {

    override fun createNativeModules(reactContext: ReactApplicationContext?): MutableList<NativeModule> {
        val modules = ArrayList<NativeModule>()
        modules.add(ScanditModule(reactContext))
        return modules
    }

    override fun createViewManagers(reactContext: ReactApplicationContext?): MutableList<SimpleViewManager<View>> {
        val managers = ArrayList<SimpleViewManager<View>>()
        managers.add(BarcodePicker() as SimpleViewManager<View>)
        return managers
    }
}