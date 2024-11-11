import 'conversation_bubbles_platform_interface.dart';
import 'models.dart';

export 'models.dart';

class ConversationBubbles {
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String appIcon,
    required NotificationChannel channel,
    required Person person,
    bool? isFromUser,
  }) {
    return ConversationBubblesPlatform.instance.show(
      id: id,
      title: title,
      body: body,
      appIcon: appIcon,
      channel: channel,
      person: person,
      isFromUser: isFromUser,
    );
  }
}
