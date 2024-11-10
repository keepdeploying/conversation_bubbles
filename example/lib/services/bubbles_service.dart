import 'package:conversation_bubbles/conversation_bubbles.dart';

int _notifId = 0;

class BubblesService {
  final _conversationBubblesPlugin = ConversationBubbles();

  static final instance = BubblesService._();

  BubblesService._();

  Future<void> show({required String title, required String body}) async {
    await _conversationBubblesPlugin.show(
      id: _notifId++,
      title: title,
      body: body,
      details: const NotificationDetails(
        icon: '@mipmap/ic_launcher',
        channelId: 'chat',
        channelName: 'Chat',
        channelDescription: 'Chat',
      ),
    );
  }
}
