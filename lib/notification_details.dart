class NotificationDetails {
  final String channelId;
  final String channelName;
  final String? channelDescription;
  final String icon;

  const NotificationDetails({
    required this.channelId,
    required this.channelName,
    this.channelDescription,
    required this.icon,
  });

  Map<String, String?> toMap() {
    return {
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'icon': icon
    };
  }
}
