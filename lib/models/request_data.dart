/// Model: RequestData
/// Represents a single teaching request from a learner.
class RequestData {
  final dynamic id;
  final String name;
  final String course;
  final String duration;
  final int coins;
  final List<String> availableTimes;

  const RequestData({
    this.id,
    required this.name,
    required this.course,
    required this.duration,
    required this.coins,
    this.availableTimes = const [],
  });
}
