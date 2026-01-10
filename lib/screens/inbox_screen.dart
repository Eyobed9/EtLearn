import 'package:flutter/material.dart';
import 'dart:math';

import '../models/request_data.dart';
import '../services/jitsi_service.dart';

/// InboxScreen: Shows chat and requests tabs with request list.
/// Teachers can Accept/Deny requests, schedule Jitsi meetings, and gain coins.
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool isRequestsTab = true;

  final List<RequestData> requests = const [
    RequestData(
      name: 'Johan',
      course: 'Intro to Flutter',
      duration: '2 Hrs',
      coins: 50,
      availableTimes: ['Jan 12, 10:00 AM', 'Jan 12, 2:00 PM'],
    ),
    RequestData(
      name: 'Timothee',
      course: 'UI/UX Design Basics',
      duration: '3 Hrs',
      coins: 70,
      availableTimes: ['Jan 13, 11:00 AM', 'Jan 14, 1:00 PM'],
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Forward meeting end events to show feedback / credit coins.
    JitsiService.addListener(JitsiMeetingListener(
      onConferenceTerminated: (url, error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coins credited after meeting completion!')),
        );
      },
    ));
  }

  @override
  void dispose() {
    JitsiService.removeAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Color(0xFF202244),
            fontFamily: 'Jost',
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 16)),
            // Tabs
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRequestsTab = false),
                    child: _TabButton(title: 'Chat', selected: !isRequestsTab),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 12)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRequestsTab = true),
                    child: _TabButton(title: 'Requests', selected: isRequestsTab),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 16)),
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
                    ? ListView(
                        children: requests
                            .map(
                              (req) => RequestTile(
                                request: req,
                                onAccept: () => _showTimeDialog(req),
                                onDeny: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Denied ${req.name}, requester notified.')),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      )
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

  /// Show dialog to pick a time and start the meeting.
  void _showTimeDialog(RequestData request) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Select time for ${request.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: request.availableTimes
              .map((time) => ListTile(
                    title: Text(time),
                    onTap: () {
                      Navigator.pop(context);
                      _startJitsiMeeting(request, time);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Start a Jitsi meeting using the `JitsiService` wrapper.
  void _startJitsiMeeting(RequestData request, String selectedTime) async {
    // Display name could be fetched from auth; using a placeholder here.
    const displayName = 'Teacher';

    await JitsiService.startMeeting(request: request, displayName: displayName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meeting started with ${request.name}. Coins (${request.coins}) will be credited after completion.'),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request.name,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF202244))),
          const Padding(padding: EdgeInsets.only(top: 4)),
          Text(
            '${request.course} • ${request.duration} • ${request.coins} coins',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF545454),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF167F71),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Accept'),
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 12)),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDeny,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Deny'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // Tab state: Chat or Requests
  bool isRequestsTab = true;

  // Sample request data
  final List<RequestData> requests = [
    RequestData(
      name: 'Johan',
      course: 'Intro to Flutter',
      duration: '2 Hrs',
      coins: 50,
      availableTimes: ['Jan 12, 10:00 AM', 'Jan 12, 2:00 PM'],
    ),
    RequestData(
      name: 'Timothee',
      course: 'UI/UX Design Basics',
      duration: '3 Hrs',
      coins: 70,
      availableTimes: ['Jan 13, 11:00 AM', 'Jan 14, 1:00 PM'],
    ),
    RequestData(
      name: 'Amanriya',
      course: 'Web Development 101',
      duration: '1.5 Hrs',
      coins: 40,
      availableTimes: ['Jan 15, 9:00 AM', 'Jan 15, 3:00 PM'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Color(0xFF202244),
            fontFamily: 'Jost',
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 16)),

            /// Tabs
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isRequestsTab = false;
                      });
                    },
                    child: _TabButton(title: 'Chat', selected: !isRequestsTab),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 12)),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isRequestsTab = true;
                      });
                    },
                    child: _TabButton(
                      title: 'Requests',
                      selected: isRequestsTab,
                    ),
                  ),
                ),
              ],
            ),

            const Padding(padding: EdgeInsets.only(top: 16)),

            /// Content
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
                    ? ListView(
                        children: requests
                            .map(
                              (req) => RequestTile(
                                request: req,
                                onAccept: () {
                                  // Here: schedule video chat and mark coins gainable
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Accepted ${req.name}, select a time to schedule video chat.',
                                      ),
                                    ),
                                  );

                                  _showTimeDialog(req);
                                },
                                onDeny: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Denied ${req.name}, requester notified.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      )
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

  /// Dialog to select available time
  void _showTimeDialog(RequestData request) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Select time for ${request.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: request.availableTimes
              .map(
                (time) => ListTile(
                  title: Text(time),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Video chat scheduled at $time. Coins will be gained after completion.',
                        ),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ---------------- Tab Button ----------------
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

// ---------------- Request Data Model ----------------
class RequestData {
  final String name;
  final String course;
  final String duration;
  final int coins;
  final List<String> availableTimes;

  RequestData({
    required this.name,
    required this.course,
    required this.duration,
    required this.coins,
    required this.availableTimes,
  });
}

// ---------------- Request Tile ----------------
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            request.name,
            style: const TextStyle(
              color: Color(0xFF202244),
              fontFamily: 'Jost',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Padding(padding: EdgeInsets.only(top: 4)),

          // Course details
          Text(
            '${request.course} • ${request.duration} • ${request.coins} coins',
            style: const TextStyle(
              color: Color(0xFF545454),
              fontFamily: 'Mulish',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Padding(padding: EdgeInsets.only(top: 8)),

          // Buttons
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
                  child: const Text('Accept'),
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 12)),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDeny,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Deny'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
