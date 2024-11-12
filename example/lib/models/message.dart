import 'package:isar/isar.dart';

part 'message.g.dart';

@collection
class Message {
  @Index()
  final int contactId;

  Id id = Isar.autoIncrement;

  @Index()
  final bool isIncoming;

  @Index()
  final String? photo;

  @Index()
  final String text;

  @Index()
  final int timestamp;

  Message({
    required this.contactId,
    this.isIncoming = true,
    required this.text,
    this.photo,
  }) : timestamp = _now();

  static int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}
