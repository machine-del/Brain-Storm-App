import '../../domain/entities/notification_entity.dart';

abstract class INotificationService {
  Future<void> initialize();
  Future<void> scheduleDailyReminder(DateTime time);
  Future<void> scheduleTaskReminder(DateTime time, String taskTitle);
  Future<void> showCustomNotification(NotificationEntity notification);
  Future<void> cancelAllNotifications();
  Future<void> cancelNotification(int id);
  bool get isPermissionGranted;
}