package dev.example.messseat

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "dev.example.messseat/notification"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "canPostNotifications" -> result.success(NotificationHelper.canPostNotifications(this))
                "openNotificationSettings" -> {
                    NotificationHelper.openNotificationSettings(this)
                    result.success(null)
                }
                "ensurePushChannel" -> {
                    NotificationHelper.ensurePushChannel(this)
                    result.success(null)
                }
                "alert" -> {
                    NotificationHelper.inAppNotyAlert(
                        this,
                        call.argument<Boolean>("sound") ?: true,
                        call.argument<Boolean>("vibration") ?: true
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
