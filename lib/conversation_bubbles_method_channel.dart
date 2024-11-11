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

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String appIcon,
    required NotificationChannel channel,
    required Person person,
    bool? isFromUser,
  }) async {
    await methodChannel.invokeMethod<void>('show', {
      'id': id,
      'title': title,
      'body': body,
      'appIcon': appIcon,
      ...channel.toMap(),
      ...person.toMap(),
      'isFromUser': isFromUser ?? false,
    });
  }
}
