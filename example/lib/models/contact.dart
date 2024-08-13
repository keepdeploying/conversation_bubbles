import 'dart:math';

import 'package:conversation_bubbles_example/models/message.dart';

class Contact {
  final String id;
  final String name;
  final Message Function({required String text}) reply;

  Contact({required this.name, required this.reply}) : id = _id();

  static final _r = Random();
  static String _id() =>
      String.fromCharCodes(List.generate(10, (i) => _r.nextInt(33) + 89));

  static final all = [
    Contact(
      name: 'Cat',
      reply: ({required String text}) => Message(sender: 'Cat', text: 'Meow'),
    ),
    Contact(
      name: 'Dog',
      reply: ({required String text}) =>
          Message(sender: 'Dog', text: 'Woof woof!!'),
    ),
    Contact(
      name: 'Parrot',
      reply: ({required String text}) => Message(sender: 'Parrot', text: text),
    ),
    Contact(
      name: 'Sheep',
      reply: ({required String text}) =>
          Message(photo: 'sheep_full', sender: 'Sheep', text: 'Look at me!'),
    ),
  ];
}
