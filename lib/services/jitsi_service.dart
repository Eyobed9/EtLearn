import 'dart:math';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

import '../models/request_data.dart';

/// Simple wrapper around `JitsiMeetWrapper` to centralize meeting logic.
class JitsiService {
  /// Start a meeting for [request]. Returns when join completes.
  static Future<void> startMeeting({
    required RequestData request,
    required String displayName,
  }) async {
    final roomName = 'Flutter_${request.name}_${Random().nextInt(10000)}';

    // Use minimal options to remain compatible with the package version.
    await JitsiMeetWrapper.joinMeeting(
      options: JitsiMeetingOptions(
        roomNameOrUrl: roomName,
        userDisplayName: displayName,
      ),
    );
  }
}
