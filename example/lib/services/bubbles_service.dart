import 'package:conversation_bubbles/conversation_bubbles.dart';
import 'package:conversation_bubbles_example/models/contact.dart';
import 'package:flutter/services.dart';

class BubblesService {
  final _conversationBubblesPlugin = ConversationBubbles();
  bool _isInBubble = false;

  static final instance = BubblesService._();

  BubblesService._();

  bool get isInBubble => _isInBubble;

  Future<void> init() async {
    _conversationBubblesPlugin.init(
      appIcon: '@mipmap/ic_launcher',
      fqBubbleActivity:
          'com.keepdeploying.conversation_bubbles_example.BubbleActivity',
    );

    _isInBubble = await _conversationBubblesPlugin.isInBubble();
  }

  Future<void> show(
    Contact contact,
    String messageText, {
    bool shouldAutoExpand = false,
  }) async {
    final Contact(:id, :name) = contact;
    final bytesData = await rootBundle.load('assets/$name.jpg');
    final iconBytes = bytesData.buffer.asUint8List();

    await _conversationBubblesPlugin.show(
      notificationId: id,
      body: messageText,
      contentUri:
          'https://conversation_bubbles_example.keepdeploying.com/chat/$id',
      channel: const NotificationChannel(
          id: 'chat', name: 'Chat', description: 'Chat'),
      person: Person(id: '$id', name: name, icon: iconBytes),
      isFromUser: shouldAutoExpand,
      shouldMinimize: shouldAutoExpand,
    );
  }
}
