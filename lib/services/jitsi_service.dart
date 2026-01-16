import 'dart:math';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

import '../models/request_data.dart';

/// Simple wrapper around `JitsiMeet` to centralize meeting logic.
class JitsiService {
  /// Start a meeting for [request]. Returns when join completes.
  static Future<void> startMeeting({
    required RequestData request,
    required String displayName,
  }) async {
    final roomName = 'Flutter_${request.name}_${Random().nextInt(10000)}';

    var jitsiMeet = JitsiMeet();
    var options = JitsiMeetConferenceOptions(
      room: roomName,
      userInfo: JitsiMeetUserInfo(displayName: displayName),
      configOverrides: {'requireDisplayName': true},
    );

    // Use minimal options to remain compatible with the package version.
    jitsiMeet.join(options);
  }
}
