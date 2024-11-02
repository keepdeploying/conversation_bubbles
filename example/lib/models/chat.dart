import 'package:conversation_bubbles_example/models/contact.dart';
import 'package:conversation_bubbles_example/models/message.dart';

class Chat {
  final Contact contact;
  final List<Message> messages;

  Chat({required this.contact})
      : messages = [
          Message(sender: contact.name, text: 'Send me a message'),
          Message(sender: contact.name, text: 'I will reply in 5 seconds')
        ];
}
