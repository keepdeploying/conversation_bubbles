
import 'conversation_bubbles_platform_interface.dart';

class ConversationBubbles {
  Future<String?> getPlatformVersion() {
    return ConversationBubblesPlatform.instance.getPlatformVersion();
  }
}
