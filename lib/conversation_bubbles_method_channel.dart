import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'conversation_bubbles_platform_interface.dart';

/// An implementation of [ConversationBubblesPlatform] that uses method channels.
class MethodChannelConversationBubbles extends ConversationBubblesPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('conversation_bubbles');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
