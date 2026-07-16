class NotificationEntity {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime? scheduledTime;
  final bool isScheduled;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.scheduledTime,
    this.isScheduled = false,
  });
}