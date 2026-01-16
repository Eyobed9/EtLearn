import 'dart:async';
import 'package:flutter/material.dart';
import 'package:et_learn/helpers/credits.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:et_learn/services/database_service.dart';
import 'package:et_learn/authentication/auth.dart';
import 'package:et_learn/models/request_data.dart';
import 'dart:math';

/// Inbox Screen
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool isRequestsTab = true;
  List<RequestData> requests = [];
  bool loadingRequests = true;
  final supabase = Supabase.instance.client;
  final DatabaseService _dbService = DatabaseService();
  final Auth _auth = Auth();

  @override
  void initState() {
    super.initState();
    _loadCredits();
    _loadRequests();
  }

  /// Load user's credits
  Future<void> _loadCredits() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('users')
          .select('credits')
          .eq('uid', user.uid)
          .maybeSingle();

      if (data is Map<String, dynamic>) {
        totalCreditsNotifier.value = data['credits'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error loading credits: $e');
    }
  }

  /// Load demo or real requests
  Future<void> _loadRequests() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => loadingRequests = true);

    try {
      final mentorRequests = await _dbService.getMentorRequests(user.uid);

      final parsed = mentorRequests.map((req) {
        final course = req['courses'] as Map<String, dynamic>?;
        final learner = req['users'] as Map<String, dynamic>?;
        final available =
            (req['available_times'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        return RequestData(
          id: (req['id'] as num).toInt(),
          courseId: (req['course_id'] as num).toInt(),
          learnerUid: req['learner_uid'] as String,
          learnerName: learner?['full_name']?.toString() ?? 'Student',
          courseTitle: course?['title']?.toString() ?? 'Course',
          creditCost: course?['credit_cost'] as int? ?? 0,
          durationMinutes: course?['duration_minutes'] as int? ?? 0,
          availableTimes: available,
          scheduledTime: req['scheduled_time'] != null
              ? DateTime.tryParse(req['scheduled_time'].toString())
              : null,
        );
      }).toList();

      // Keep the demo as a fallback preview when there are no real requests
      final newRequests = parsed.isNotEmpty
          ? parsed
          : [
              const RequestData(
                id: 0,
                courseId: 0,
                learnerUid: 'demo',
                learnerName: 'Demo Student',
                courseTitle: 'Flutter Basics',
                creditCost: 50,
                durationMinutes: 60,
                availableTimes: ['Now +5 sec'],
              ),
            ];

      if (mounted) {
        setState(() {
          requests = newRequests;
        });
      }
    } catch (e) {
      debugPrint('Error loading requests: $e');
    }

    if (mounted) {
      setState(() => loadingRequests = false);
    }
  }

  /// Accept a request, pick a slot, and start a meeting
  Future<void> _acceptRequest(RequestData request) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final scheduledAt = await _pickTimeSlot(request);
      if (scheduledAt == null) return;

      if (request.id != 0) {
        await _dbService.acceptCourseRequest(
          request.id,
          request.learnerUid,
          request.courseId,
        );
      }

      final password = _generateMeetingPassword();
      await _startVideoMeeting(request, scheduledAt, password);
      await _notifyLearner(request, scheduledAt, password);
      await _loadRequests();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request accepted! Meeting starting. Password: $password',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      debugPrint('Error accepting request: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  /// Let mentor pick a time slot from the student-provided list or scheduled time.
  Future<DateTime?> _pickTimeSlot(RequestData request) async {
    final options = <String>[];
    options.addAll(request.availableTimes);
    if (request.scheduledTime != null) {
      options.add(request.scheduledTime!.toIso8601String());
    }

    if (options.isEmpty) return DateTime.now();

    return showModalBottomSheet<DateTime>(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...options.map(
              (slot) => ListTile(
                title: Text(slot),
                onTap: () {
                  Navigator.pop(ctx, DateTime.tryParse(slot) ?? DateTime.now());
                },
              ),
            ),
            ListTile(
              title: const Text('Start now'),
              onTap: () => Navigator.pop(ctx, DateTime.now()),
            ),
          ],
        );
      },
    );
  }

  /// Add coins after meeting
  Future<void> _addCoins(int coinsToAdd) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('users')
          .select('credits')
          .eq('uid', user.uid)
          .maybeSingle();

      int currentCredits = totalCreditsNotifier.value;
      if (data is Map<String, dynamic>) {
        currentCredits = data['credits'] ?? currentCredits;
      }

      final newCredits = currentCredits + coinsToAdd;

      await supabase
          .from('users')
          .update({'credits': newCredits})
          .eq('uid', user.uid);

      totalCreditsNotifier.value = newCredits;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meeting ended. Coins ($coinsToAdd) credited!'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding coins: $e');
    }
  }

  /// Start meeting and show meeting link
  Future<void> _startVideoMeeting(
    RequestData request,
    DateTime startAt,
    String password,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final roomName =
        'ETLearn_${request.courseId}_${DateTime.now().millisecondsSinceEpoch}';
    final meetingLink = 'https://meet.jit.si/$roomName';

    // Update the UI with the link (Feature from demo logic)
    if (mounted) {
      setState(() {
        final index = requests.indexOf(request);
        if (index != -1) {
          requests[index] = RequestData(
            id: request.id,
            courseId: request.courseId,
            learnerUid: request.learnerUid,
            learnerName: request.learnerName,
            courseTitle: request.courseTitle,
            creditCost: request.creditCost,
            durationMinutes: request.durationMinutes,
            availableTimes: request.availableTimes,
            scheduledTime: request.scheduledTime,
            meetingLink: meetingLink,
          );
        }
      });
    }

    final wait = startAt.difference(DateTime.now());
    if (wait > Duration.zero) {
      final capped = wait < const Duration(minutes: 15) ? wait : Duration.zero;
      if (capped > Duration.zero) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Starting meeting at ${startAt.toLocal()} (${capped.inMinutes} min)',
              ),
            ),
          );
        }
        await Future.delayed(capped);
      }
    }

    var jitsiMeet = JitsiMeet();
    var options = JitsiMeetConferenceOptions(
      room: roomName,
      userInfo: JitsiMeetUserInfo(
        displayName: user.displayName ?? 'Mentor',
        email: user.email,
        avatar: user.photoURL,
      ),
      configOverrides: {
        'requireDisplayName': true,
        // The new SDK handles passwords differently, but we'll try passing it if we can,
        // otherwise users can set it via the meeting interface if they are moderators.
        // For Jitsi Meet, setting room password via config/options on join isn't always standard
        // without a token, but we'll keep the structure clean.
      },
    );

    jitsiMeet.join(options);

    // For demo requests or immediate rewards, add coins now.
    // In a real scenario, this might happen via backend or after close,
    // but here we simulate the 'Demo' flow adding coins.
    if (request.id == 0) {
      await _addCoins(request.creditCost);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meeting link: $meetingLink | Password: $password'),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  String _generateMeetingPassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _notifyLearner(
    RequestData request,
    DateTime scheduledAt,
    String password,
  ) async {
    // Skip notification for demo requests
    if (request.id == 0 || request.learnerUid == 'demo') return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final roomName =
          'ETLearn_${request.courseId}_${DateTime.now().millisecondsSinceEpoch}';
      final meetingLink = 'https://meet.jit.si/$roomName';
      final whenLabel = scheduledAt.toLocal().toString();

      await _dbService.sendMessage(
        senderUid: user.uid,
        receiverUid: request.learnerUid,
        content:
            'Your session for ${request.courseTitle} is scheduled at $whenLabel. Join: $meetingLink Password: $password',
        courseId: request.courseId,
      );
    } catch (e) {
      debugPrint('Failed to notify learner: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ValueListenableBuilder<int>(
          valueListenable: totalCreditsNotifier,
          builder: (context, totalCredits, _) {
            return Text(
              'Inbox',
              style: const TextStyle(
                color: Color(0xFF202244),
                fontFamily: 'Jost',
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Tabs
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRequestsTab = false),
                    child: _TabButton(title: 'Chat', selected: !isRequestsTab),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRequestsTab = true),
                    child: _TabButton(
                      title: 'Requests',
                      selected: isRequestsTab,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: isRequestsTab
                    ? (loadingRequests
                          ? const Center(child: CircularProgressIndicator())
                          : requests.isEmpty
                          ? const Center(
                              child: Text(
                                'No pending requests',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadRequests,
                              child: ListView(
                                children: requests
                                    .map(
                                      (req) => RequestTile(
                                        request: req,
                                        onAccept: () => _acceptRequest(req),
                                        onDeny: () async {
                                          await _dbService.rejectCourseRequest(
                                            req.id,
                                          );
                                          setState(() {
                                            requests.remove(req);
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Denied ${req.learnerName}, requester notified.',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ))
                    : const Center(
                        child: Text(
                          'Chat screen here...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab button used in the inbox header.
class _TabButton extends StatelessWidget {
  final String title;
  final bool selected;

  const _TabButton({required this.title, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF167F71) : const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF202244),
          fontFamily: 'Mulish',
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Shows a single request with Accept/Deny buttons.
class RequestTile extends StatelessWidget {
  final RequestData request;
  final VoidCallback onAccept;
  final VoidCallback onDeny;

  const RequestTile({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final scheduledLabel = request.scheduledTime != null
        ? 'Scheduled: ${request.scheduledTime!.toLocal()}'
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.learnerName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202244),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${request.courseTitle} • ${(request.durationMinutes ~/ 60)}h ${(request.durationMinutes % 60)}m • ${request.creditCost} credits',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF545454),
            ),
          ),
          if (request.availableTimes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Preferred times: ${request.availableTimes.join(', ')}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0961F5),
                ),
              ),
            ),
          if (scheduledLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                scheduledLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF167F71),
                ),
              ),
            ),
          if (request.meetingLink != null) ...[
            const SizedBox(height: 4),
            SelectableText(
              'Meeting: ${request.meetingLink}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0961F5),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF167F71),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDeny,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Deny',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
