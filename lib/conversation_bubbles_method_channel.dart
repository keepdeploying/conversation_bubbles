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

  /// Stores the [appIcon] for use in showing bubbles.
  @override
  void init({required String appIcon}) => _appIcon = appIcon;

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
  }) async {
    if (_appIcon == null) {
      throw Exception(
        'You must call init() before calling show() to set the appIcon.',
      );
    }

    await methodChannel.invokeMethod<void>('show', {
      'notificationId': notificationId,
      'body': body,
      'appIcon': _appIcon,
      'contentUri': contentUri,
      ...channel.toMap(),
      ...person.toMap(),
      'isFromUser': isFromUser ?? false,
      'shouldMinimize': shouldMinimize ?? false,
    });
  }
}
