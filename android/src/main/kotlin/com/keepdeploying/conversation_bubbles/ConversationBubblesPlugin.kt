package com.keepdeploying.conversation_bubbles

import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.view.WindowManager
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.Person
import androidx.core.content.LocusIdCompat
import androidx.core.content.getSystemService
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import androidx.core.net.toUri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
/** ConversationBubblesPlugin */
class ConversationBubblesPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private var activity: Activity? = null
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  companion object {
    private const val REQUEST_BUBBLE = 1
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel =
      MethodChannel(flutterPluginBinding.binaryMessenger, "com.keepdeploying.conversation_bubbles")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getIntentUri" -> {
        result.success(getIntentUri())
      }
      "isInBubble" -> {
        result.success(isInBubble())
      }
      "show" -> {
        @Suppress("UNCHECKED_CAST")
        show(call.arguments as Map<String, Any>)
        result.success(null)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  fun getIntentUri(): String? {
    return activity?.intent?.data?.toString()
  }

  fun isInBubble(): Boolean {
    return if (Build.VERSION.SDK_INT >= 31) {
      activity?.isLaunchedFromBubble ?: false
    } else {
      false
    }
  }

  private fun flagUpdateCurrent(mutable: Boolean): Int {
    return if (mutable) {
      if (Build.VERSION.SDK_INT >= 31) {
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
      } else {
        PendingIntent.FLAG_UPDATE_CURRENT
      }
    } else {
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    }
  }

  private fun getScreenHeight(): Int {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      val windowManager = context.getSystemService<WindowManager>()
        ?: throw IllegalStateException("WindowManager is null")
      val windowMetrics = windowManager.currentWindowMetrics
      val rect = windowMetrics.bounds
      rect.bottom
    } else {
      context.resources.displayMetrics.heightPixels
    }
  }

  @RequiresApi(Build.VERSION_CODES.O)
  fun show(details: Map<String, Any>) {
    if (activity == null) throw IllegalStateException("Activity is null")

    val notifManager = context.getSystemService<NotificationManager>()
      ?: throw IllegalStateException("NotificationManager is null")
    val channelId = details["channelId"] as String

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

    val personName = details["personName"] as String
    val iconArray = details["personIcon"] as ByteArray
    val iconBitmap = BitmapFactory.decodeByteArray(iconArray, 0, iconArray.size)
    val icon = IconCompat.createWithAdaptiveBitmap(iconBitmap)
    val person = Person.Builder().setName(personName).setIcon(icon).build()
    val personId = details["personId"] as String
    val contentUri = (details["contentUri"] as String).toUri()            

    // Create a dynamic shortcut for the person
    val shortcut = ShortcutInfoCompat.Builder(context, personId)
      .setLocusId(LocusIdCompat(personId))
      .setActivity(ComponentName(context, activity!!::class.java))
      .setShortLabel(personName)
      .setIcon(icon)
      .setLongLived(true)
      .setIntent(
        Intent(context, activity!!::class.java).setAction(Intent.ACTION_VIEW).setData(contentUri)
      )
      .setPerson(person)
      .build()
    ShortcutManagerCompat.pushDynamicShortcut(context, shortcut)

    val pendingIntent = PendingIntent.getActivity(
      context,
      REQUEST_BUBBLE,
      Intent(context, activity!!::class.java)
        .setAction(Intent.ACTION_VIEW).setData(contentUri),
      flagUpdateCurrent(mutable = true)
    )

    val isFromUser = details["isFromUser"] as Boolean
    val builder = NotificationCompat.Builder(context, channelId)
      .setBubbleMetadata(
        NotificationCompat.BubbleMetadata.Builder(pendingIntent, icon)
          .setDesiredHeight((getScreenHeight() * 0.75).toInt()).apply {
            if (isFromUser) {
              setAutoExpandBubble(true)
              setSuppressNotification(true)
            }
          }.build()
      )
      .setSmallIcon(
        context.resources.getIdentifier(
          details["appIcon"] as String,
          "drawable",
          context.packageName
        )
      )
      .setCategory(Notification.CATEGORY_MESSAGE)
      .setShortcutId(personId)
      .setLocusId(LocusIdCompat(personId))
      .addPerson(person)
      .setShowWhen(true)
      .setContentIntent(pendingIntent)
      .setStyle(
        NotificationCompat.MessagingStyle(person)
          .addMessage(
            details["body"] as String,
            System.currentTimeMillis(),
            person
          )
      )

    if (isFromUser) builder.setOnlyAlertOnce(true)

    notifManager.notify(details["notificationId"] as Int, builder.build())

    if (details["shouldMinimize"] as Boolean) {
      activity!!.moveTaskToBack(true)
    }
  }
}
