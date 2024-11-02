package com.keepdeploying.conversation_bubbles

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
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

  private val notificationManager: NotificationManager =
    context.getSystemService() ?: throw IllegalStateException()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Log.d("ConversationBubbles", "onAttachedToEngine")
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.keepdeploying.conversation_bubbles")
    Log.d("ConversationBubbles", "channel: $channel")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    Log.d("ConversationBubbles", "context: $context")
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: Result) {
    Log.d("ConversationBubbles", "onMethodCall: ${call.method}")
    if (call.method == "showNotification") {
      @Suppress("UNCHECKED_CAST")
      showNotification(call.arguments as Map<String, Any>)
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  @RequiresApi(Build.VERSION_CODES.O)
  fun showNotification(details: Map<String, Any>) {
    val channelId = details["channelId"] as String

    if (notificationManager.getNotificationChannel(channelId) == null) {
      notificationManager.createNotificationChannel(
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

    val builder = NotificationCompat.Builder(context, channelId)
      .setSmallIcon(
        context.resources.getIdentifier(
          details["icon"] as String,
          "drawable",
          context.packageName
        )
      )
      .setContentTitle(details["title"] as String)
      .setContentText(details["body"] as String)

    notificationManager.notify(details["id"] as Int, builder.build())
  }
}
