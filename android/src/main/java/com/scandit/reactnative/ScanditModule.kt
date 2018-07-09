package com.scandit.reactnative

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.scandit.barcodepicker.ScanditLicense

class ScanditModule(reactContext: ReactApplicationContext?) : ReactContextBaseJavaModule(reactContext)  {

    override fun getName(): String = "ScanditModule"

    @ReactMethod
    fun setAppKey(key: String) {
        ScanditLicense.setAppKey(key)
    }
}