import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'conversation_bubbles_method_channel.dart';
import 'models.dart';

abstract class ConversationBubblesPlatform extends PlatformInterface {
  /// Constructs a ConversationBubblesPlatform.
  ConversationBubblesPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConversationBubblesPlatform _instance =
      MethodChannelConversationBubbles();

  /// The default instance of [ConversationBubblesPlatform] to use.
  ///
  /// Defaults to [MethodChannelConversationBubbles].
  static ConversationBubblesPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ConversationBubblesPlatform] when
  /// they register themselves.
  static set instance(ConversationBubblesPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getIntentUri() {
    throw UnimplementedError('getIntentUri() has not been implemented.');
  }

  void init({required String appIcon, required String fqBubbleActivity}) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<bool> isInBubble() {
    throw UnimplementedError('isInBubble() has not been implemented.');
  }

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
    throw UnimplementedError('show() has not been implemented.');
  }
}
