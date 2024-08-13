import 'package:flutter_test/flutter_test.dart';
import 'package:conversation_bubbles/conversation_bubbles.dart';
import 'package:conversation_bubbles/conversation_bubbles_platform_interface.dart';
import 'package:conversation_bubbles/conversation_bubbles_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockConversationBubblesPlatform
    with MockPlatformInterfaceMixin
    implements ConversationBubblesPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ConversationBubblesPlatform initialPlatform = ConversationBubblesPlatform.instance;

  test('$MethodChannelConversationBubbles is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelConversationBubbles>());
  });

  test('getPlatformVersion', () async {
    ConversationBubbles conversationBubblesPlugin = ConversationBubbles();
    MockConversationBubblesPlatform fakePlatform = MockConversationBubblesPlatform();
    ConversationBubblesPlatform.instance = fakePlatform;

    expect(await conversationBubblesPlugin.getPlatformVersion(), '42');
  });
}
