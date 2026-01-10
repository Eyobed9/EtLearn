/// Model: RequestData
/// Represents a single teaching request from a learner.
class RequestData {
  final String name;
  final String course;
  final String duration;
  final int coins;
  final List<String> availableTimes;

  const RequestData({
    required this.name,
    required this.course,
    required this.duration,
    required this.coins,
    required this.availableTimes,
  });
}
