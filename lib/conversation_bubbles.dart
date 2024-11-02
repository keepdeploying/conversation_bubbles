import 'conversation_bubbles_platform_interface.dart';
import 'notification_details.dart';

export 'notification_details.dart';

class ConversationBubbles {
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
  }) {
    return ConversationBubblesPlatform.instance.showNotification(
      id: id,
      title: title,
      body: body,
      details: details,
    );
  }
}
