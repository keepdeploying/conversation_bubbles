import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'conversation_bubbles_platform_interface.dart';
import 'models.dart';

/// An implementation of [ConversationBubblesPlatform] that uses method channels.
class MethodChannelConversationBubbles extends ConversationBubblesPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('com.keepdeploying.conversation_bubbles');

  String? _appIcon;
  String? _fqBubbleActivity;

  /// Stores the [appIcon] and the fully qualified name of the Android Activity
  /// for use in showing bubbles.
  @override
  void init({required String appIcon, required String fqBubbleActivity}) {
    _appIcon = appIcon;
    _fqBubbleActivity = fqBubbleActivity;
  }

  @override
  Future<String?> getIntentUri() {
    return methodChannel.invokeMethod<String>('getIntentUri');
  }

  @override
  Future<bool> isInBubble() async {
    return (await methodChannel.invokeMethod<bool>('isInBubble')) ?? false;
  }

  @override
  Future<void> show({
    required int notificationId,
    required String body,
    required String contentUri,
    required NotificationChannel channel,
    required Person person,
    bool? isFromUser,
    bool? shouldMinimize,
    String? appIcon,
    String? fqBubbleActivity,
  }) async {
    if (appIcon == null && _appIcon == null) {
      throw Exception(
        'You must call init() before calling show() to set the appIcon '
        ' OR you must provide the appIcon as a parameter to show().',
      );
    }

    if (fqBubbleActivity == null && _fqBubbleActivity == null) {
      throw Exception(
        'You must call init before calling show to set the fqBubbleActivity '
        ' OR you must provide the fqBubbleActivity as a parameter to show().',
      );
    }

    await methodChannel.invokeMethod<void>('show', {
      'notificationId': notificationId,
      'body': body,
      'appIcon': appIcon ?? _appIcon,
      'contentUri': contentUri,
      ...channel.toMap(),
      ...person.toMap(),
      'isFromUser': isFromUser ?? false,
      'shouldMinimize': shouldMinimize ?? false,
      'fqBubbleActivity': fqBubbleActivity ?? _fqBubbleActivity,
    });
  }
}
