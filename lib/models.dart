import 'dart:typed_data';

class NotificationChannel {
  final String id;
  final String name;
  final String? description;

  const NotificationChannel(
      {required this.id, required this.name, this.description});

  Map<String, String?> toMap() {
    return {
      'channelId': id,
      'channelName': name,
      'channelDescription': description
    };
  }
}

class Person {
  final String id;
  final String name;
  final Uint8List icon;

  const Person({required this.id, required this.name, required this.icon});

  Map<String, Object?> toMap() =>
      {'personId': id, 'personName': name, 'personIcon': icon};
}
