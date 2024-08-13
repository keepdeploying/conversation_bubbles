import 'dart:math';

class Message {
  static final _r = Random();

  final String id;
  final String? photo;
  final String? sender; // null sender means "You"
  final String text;
  final int timestamp;

  Message({this.sender, required this.text, this.photo})
      : id = _id(),
        timestamp = _now();

  static String _id() =>
      String.fromCharCodes(List.generate(10, (i) => _r.nextInt(33) + 89));

  static int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  bool get isIncoming => sender != null;
}
