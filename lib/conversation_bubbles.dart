import 'conversation_bubbles_platform_interface.dart';
import 'models.dart';

export 'models.dart';

class ConversationBubbles {
  Future<String?> getIntentUri() {
    return ConversationBubblesPlatform.instance.getIntentUri();
  }

  void init({required String appIcon}) {
    return ConversationBubblesPlatform.instance.init(appIcon: appIcon);
  }

  Future<bool> isInBubble() {
    return ConversationBubblesPlatform.instance.isInBubble();
  }

  Future<void> show({
    required int notificationId,
    required String body,
    required String contentUri,
    required NotificationChannel channel,
    required Person person,
    bool? isFromUser,
    bool? shouldMinimize,
  }) {
    return ConversationBubblesPlatform.instance.show(
      notificationId: notificationId,
      body: body,
      contentUri: contentUri,
      channel: channel,
      person: person,
      isFromUser: isFromUser,
      shouldMinimize: shouldMinimize,
    );
  }
}
