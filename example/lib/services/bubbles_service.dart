import 'package:conversation_bubbles/conversation_bubbles.dart';
import 'package:conversation_bubbles_example/models/chat.dart';
import 'package:conversation_bubbles_example/models/contact.dart';
import 'package:flutter/services.dart';

class BubblesService {
  final _conversationBubblesPlugin = ConversationBubbles();

  static final instance = BubblesService._();

  BubblesService._();

  Future<void> show(Chat chat, {shouldAutoExpand = false}) async {
    final Contact(:id, :name) = chat.contact;
    final bytesData = await rootBundle.load('assets/$name.jpg');
    final iconBytes = bytesData.buffer.asUint8List();

    await _conversationBubblesPlugin.show(
      id: chat.id,
      title: "${chat.contact.name} messaged you",
      body: chat.messages.last.text,
      appIcon: '@mipmap/ic_launcher',
      channel: const NotificationChannel(
          id: 'chat', name: 'Chat', description: 'Chat'),
      person: Person(id: id, name: name, icon: iconBytes),
      isFromUser: shouldAutoExpand,
    );
  }
}
