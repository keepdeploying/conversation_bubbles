import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'conversation_bubbles_platform_interface.dart';
import 'notification_details.dart';

/// An implementation of [ConversationBubblesPlatform] that uses method channels.
class MethodChannelConversationBubbles extends ConversationBubblesPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('com.keepdeploying.conversation_bubbles');

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
  }) async {
    await methodChannel.invokeMethod<void>('showNotification', {
      'id': id,
      'title': title,
      'body': body,
      ...details.toMap(),
    });
  }
}
