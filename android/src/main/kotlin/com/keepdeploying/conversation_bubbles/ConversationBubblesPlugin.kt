package com.keepdeploying.conversation_bubbles

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.content.getSystemService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ConversationBubblesPlugin */
class ConversationBubblesPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel =
      MethodChannel(flutterPluginBinding.binaryMessenger, "com.keepdeploying.conversation_bubbles")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "show") {
      @Suppress("UNCHECKED_CAST")
      show(call.arguments as Map<String, Any>)
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  @RequiresApi(Build.VERSION_CODES.O)
  fun show(details: Map<String, Any>) {
    val channelId = details["channelId"] as String
    val notifManager = context.getSystemService<NotificationManager>()
      ?: throw IllegalStateException("NotificationManager is null")

    if (notifManager.getNotificationChannel(channelId) == null) {
      notifManager.createNotificationChannel(
        NotificationChannel(
          channelId,
          details["channelName"] as String,
          // The importance must be IMPORTANCE_HIGH to show Bubbles.
          NotificationManager.IMPORTANCE_HIGH
        ).apply {
          val desc = details["channelDetails"] as String?
          if (desc != null) description = desc
        }
      )
    }

    val builder = Notification.Builder(context, channelId)
      .setSmallIcon(
        context.resources.getIdentifier(
          details["icon"] as String,
          "drawable",
          context.packageName
        )
      )
      .setContentTitle(details["title"] as String)
      .setContentText(details["body"] as String)

    notifManager.notify(details["id"] as Int, builder.build())
  }
}
