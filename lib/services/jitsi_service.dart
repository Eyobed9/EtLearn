import 'package:jitsi_meet/jitsi_meet.dart';

class JitsiService {
  static Future<void> joinMeeting({
    required String roomName,
    String? serverUrl,
    String? displayName,
    String? email,
    bool audioMuted = false,
    bool videoMuted = false,
  }) async {
    try {
      var options = JitsiMeetingOptions(room: roomName)
        ..serverURL = serverUrl
        ..userDisplayName = displayName
        ..userEmail = email
        ..audioMuted = audioMuted
        ..videoMuted = videoMuted;

      await JitsiMeet.joinMeeting(options);
    } catch (e) {
      // keep failure silent for now; caller can handle if needed
      // ignore: avoid_print
      print('Jitsi join error: $e');
    }
  }
}
