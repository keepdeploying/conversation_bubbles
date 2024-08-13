import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'conversation_bubbles_method_channel.dart';

abstract class ConversationBubblesPlatform extends PlatformInterface {
  /// Constructs a ConversationBubblesPlatform.
  ConversationBubblesPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConversationBubblesPlatform _instance = MethodChannelConversationBubbles();

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}