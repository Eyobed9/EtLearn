/// Model: RequestData
/// Represents a single teaching request from a learner.
class RequestData {
  final int id;
  final int courseId;
  final String learnerUid;
  final String learnerName;
  final String courseTitle;
  final int creditCost;
  final int durationMinutes;
  final List<String> availableTimes;
  final DateTime? scheduledTime;
  final String? meetingLink;

  // Getters for compatibility with other parts of the app that might use old field names
  String get name => learnerName;
  String get course => courseTitle;
  int get coins => creditCost;
  String get duration => '$durationMinutes min';

  const RequestData({
    required this.id,
    required this.courseId,
    required this.learnerUid,
    required this.learnerName,
    required this.courseTitle,
    required this.creditCost,
    required this.durationMinutes,
    required this.availableTimes,
    this.scheduledTime,
    this.meetingLink,
  });
}
