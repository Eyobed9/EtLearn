import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

import '../models/request_data.dart';

/// Simple wrapper around `JitsiMeetWrapper` to centralize meeting logic.
class JitsiService {
  /// Add a meeting listener (forward to `JitsiMeetWrapper`).
  static void addListener(JitsiMeetingListener listener) =>
      JitsiMeetWrapper.addListener(listener);

  /// Remove all registered listeners.
  static void removeAllListeners() => JitsiMeetWrapper.removeAllListeners();

  /// Start a meeting for [request]. Returns when join completes.
  static Future<void> startMeeting({
    required RequestData request,
    required String displayName,
  }) async {
    final roomName = 'Flutter_${request.name}_${Random().nextInt(10000)}';

    await JitsiMeetWrapper.joinMeeting(
      options: JitsiMeetingOptions(
        roomNameOrUrl: roomName,
        userDisplayName: displayName,
        audioMuted: false,
        videoMuted: false,
      ),
    );
  }
}
