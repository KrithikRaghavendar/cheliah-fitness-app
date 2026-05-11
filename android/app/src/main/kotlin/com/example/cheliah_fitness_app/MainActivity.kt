package com.example.cheliah_fitness_app

import android.content.Context
import android.media.AudioManager
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.cheliah.fitness/media_control"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendMediaEvent") {
                val keyCode = call.argument<Int>("keyCode") ?: KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                
                // Simulate pressing and releasing a Bluetooth headset media button
                val downEvent = KeyEvent(KeyEvent.ACTION_DOWN, keyCode)
                audioManager.dispatchMediaKeyEvent(downEvent)
                
                val upEvent = KeyEvent(KeyEvent.ACTION_UP, keyCode)
                audioManager.dispatchMediaKeyEvent(upEvent)
                
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
