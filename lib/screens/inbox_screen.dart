// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:et_learn/helpers/credits.dart';
// // import 'package:et_learn/authentication/auth.dart';
// // import 'package:et_learn/services/database_service.dart';
// // import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

// // /// Inbox Screen with Requests and Messaging
// // class InboxScreen extends StatefulWidget {
// //   const InboxScreen({super.key});

// //   @override
// //   State<InboxScreen> createState() => _InboxScreenState();
// // }

// // class _InboxScreenState extends State<InboxScreen> {
// //   final DatabaseService _dbService = DatabaseService();
// //   final Auth _auth = Auth();

// //   bool isRequestsTab = true;
// //   List<Map<String, dynamic>> requests = [];
// //   List<Map<String, dynamic>> conversations = [];
// //   bool loading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadData();
// //   }

// //   Future<void> _loadData() async {
// //     await Future.wait([
// //       _loadCredits(),
// //       _loadRequests(),
// //       _loadConversations(),
// //     ]);
// //   }

// //   Future<void> _loadCredits() async {
// //     final user = _auth.currentUser;
// //     if (user == null) return;

// //     try {
// //       final credits = await _dbService.getUserCredits(user.uid);
// //       totalCreditsNotifier.value = credits;
// //     } catch (e) {
// //       debugPrint('Error loading credits: $e');
// //     }
// //   }

// //   Future<void> _loadRequests() async {
// //     setState(() => loading = true);
// //     final user = _auth.currentUser;
// //     if (user == null) {
// //       setState(() => loading = false);
// //       return;
// //     }

// //     try {
// //       final mentorRequests = await _dbService.getMentorRequests(user.uid);
// //       setState(() {
// //         requests = mentorRequests;
// //         loading = false;
// //       });
// //     } catch (e) {
// //       debugPrint('Error loading requests: $e');
// //       setState(() => loading = false);
// //     }
// //   }

// //   Future<void> _loadConversations() async {
// //     final user = _auth.currentUser;
// //     if (user == null) return;

// //     try {
// //       final convos = await _dbService.getConversations(user.uid);
// //       setState(() {
// //         conversations = convos;
// //       });
// //     } catch (e) {
// //       debugPrint('Error loading conversations: $e');
// //     }
// //   }

// //   Future<void> _acceptRequest(Map<String, dynamic> request) async {
// //     final user = _auth.currentUser;
// //     if (user == null) return;

// //     try {
// //       final courseId = request['course_id'] as int;
// //       final learnerUid = request['learner_uid'] as String;
// //       final requestId = request['id'] as int;

// //       // Accept the request (creates enrollment)
// //       await _dbService.acceptCourseRequest(requestId, learnerUid, courseId);

// //       // Get course and learner info for meeting
// //       final course = request['courses'] as Map<String, dynamic>?;
// //       final learner = request['users'] as Map<String, dynamic>?;

// //       if (course != null && learner != null) {
// //         // Start video meeting with 5 second delay
// //         await _startVideoMeeting(
// //           course: course,
// //           learnerName: learner['full_name'] ?? 'Student',
// //           learnerUid: learnerUid,
// //         );
// //       }

// //       // Reload requests
// //       await _loadRequests();

// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Request accepted! Video meeting starting...')),
// //       );
// //     } catch (e) {
// //       debugPrint('Error accepting request: $e');
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error: ${e.toString()}')),
// //       );
// //     }
// //   }

// //   Future<void> _startVideoMeeting({
// //     required Map<String, dynamic> course,
// //     required String learnerName,
// //     required String learnerUid,
// //   }) async {
// //     final user = _auth.currentUser;
// //     if (user == null) return;

// //     // Create unique room name
// //     final roomName = 'ETLearn_${course['id']}_${DateTime.now().millisecondsSinceEpoch}';

// //     // Show notification that meeting will start in 5 seconds
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(
// //         content: Text('Video meeting will start in 5 seconds...'),
// //         duration: Duration(seconds: 5),
// //       ),
// //     );

// //     // Wait 5 seconds before starting
// //     await Future.delayed(const Duration(seconds: 5));

// //     if (!mounted) return;

// //     // Start Jitsi meeting
// //     try {
// //       await JitsiMeetWrapper.joinMeeting(
// //         options: JitsiMeetingOptions(
// //           roomNameOrUrl: roomName,
// //           userDisplayName: user.displayName ?? 'Mentor',
// //         ),
// //       );
// //     } catch (e) {
// //       debugPrint('Error starting Jitsi meeting: $e');
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error starting meeting: ${e.toString()}')),
// //       );
// //     }
// //   }

// //   Future<void> _rejectRequest(int requestId) async {
// //     try {
// //       await _dbService.rejectCourseRequest(requestId);
// //       await _loadRequests();

// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Request rejected. Requester notified.')),
// //       );
// //     } catch (e) {
// //       debugPrint('Error rejecting request: $e');
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error: ${e.toString()}')),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F8FE),
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         title: ValueListenableBuilder<int>(
// //           valueListenable: totalCreditsNotifier,
// //           builder: (context, totalCredits, _) {
// //             return Text(
// //               'Inbox',
// //               style: const TextStyle(
// //                 color: Color(0xFF202244),
// //                 fontFamily: 'Jost',
// //                 fontSize: 21,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16),
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 16),
// //             // Tabs
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: GestureDetector(
// //                     onTap: () => setState(() => isRequestsTab = false),
// //                     child: _TabButton(title: 'Chat', selected: !isRequestsTab),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: GestureDetector(
// //                     onTap: () => setState(() => isRequestsTab = true),
// //                     child: _TabButton(
// //                       title: 'Requests',
// //                       selected: isRequestsTab,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 16),
// //             // Content
// //             Expanded(
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(vertical: 12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                   boxShadow: const [
// //                     BoxShadow(
// //                       color: Color(0x14000000),
// //                       blurRadius: 10,
// //                       offset: Offset(0, 4),
// //                     ),
// //                   ],
// //                 ),
// //                 child: isRequestsTab
// //                     ? _buildRequestsTab()
// //                     : _buildChatTab(),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildRequestsTab() {
// //     if (loading) {
// //       return const Center(child: CircularProgressIndicator());
// //     }

// //     if (requests.isEmpty) {
// //       return const Center(
// //         child: Text(
// //           'No pending requests',
// //           style: TextStyle(color: Colors.grey),
// //         ),
// //       );
// //     }

// //     return RefreshIndicator(
// //       onRefresh: _loadRequests,
// //       child: ListView.builder(
// //         itemCount: requests.length,
// //         itemBuilder: (context, index) {
// //           final request = requests[index];
// //           final course = request['courses'] as Map<String, dynamic>?;
// //           final learner = request['users'] as Map<String, dynamic>?;
// //           final status = request['status'] as String? ?? 'pending';

// //           return _RequestTile(
// //             request: request,
// //             courseTitle: course?['title'] ?? 'Unknown Course',
// //             learnerName: learner?['full_name'] ?? 'Unknown',
// //             status: status,
// //             onAccept: status == 'pending' ? () => _acceptRequest(request) : null,
// //             onReject: status == 'pending'
// //                 ? () => _rejectRequest(request['id'] as int)
// //                 : null,
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildChatTab() {
// //     if (conversations.isEmpty) {
// //       return const Center(
// //         child: Text(
// //           'No conversations yet',
// //           style: TextStyle(color: Colors.grey),
// //         ),
// //       );
// //     }

// //     return RefreshIndicator(
// //       onRefresh: _loadConversations,
// //       child: ListView.builder(
// //         itemCount: conversations.length,
// //         itemBuilder: (context, index) {
// //           final conversation = conversations[index];
// //           return _ConversationTile(
// //             conversation: conversation,
// //             onTap: () {
// //               // Navigate to chat screen (can be implemented later)
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('Chat feature coming soon')),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// // /// Tab button widget
// // class _TabButton extends StatelessWidget {
// //   final String title;
// //   final bool selected;

// //   const _TabButton({required this.title, required this.selected});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 48,
// //       alignment: Alignment.center,
// //       decoration: BoxDecoration(
// //         color: selected ? const Color(0xFF167F71) : const Color(0xFFE8F1FF),
// //         borderRadius: BorderRadius.circular(24),
// //       ),
// //       child: Text(
// //         title,
// //         style: TextStyle(
// //           color: selected ? Colors.white : const Color(0xFF202244),
// //           fontFamily: 'Mulish',
// //           fontSize: 15,
// //           fontWeight: FontWeight.w800,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // /// Request tile widget
// // class _RequestTile extends StatelessWidget {
// //   final Map<String, dynamic> request;
// //   final String courseTitle;
// //   final String learnerName;
// //   final String status;
// //   final VoidCallback? onAccept;
// //   final VoidCallback? onReject;

// //   const _RequestTile({
// //     required this.request,
// //     required this.courseTitle,
// //     required this.learnerName,
// //     required this.status,
// //     this.onAccept,
// //     this.onReject,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final course = request['courses'] as Map<String, dynamic>?;
// //     final creditCost = course?['credit_cost'] ?? 0;

// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       learnerName,
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.w600,
// //                         color: Color(0xFF202244),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       '$courseTitle • $creditCost credits',
// //                       style: const TextStyle(
// //                         fontSize: 13,
// //                         fontWeight: FontWeight.w700,
// //                         color: Color(0xFF545454),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               _StatusChip(status: status),
// //             ],
// //           ),
// //           if (status == 'pending' && (onAccept != null || onReject != null)) ...[
// //             const SizedBox(height: 12),
// //             Row(
// //               children: [
// //                 if (onAccept != null)
// //                   Expanded(
// //                     child: ElevatedButton(
// //                       onPressed: onAccept,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFF167F71),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                       child: const Text('Accept'),
// //                     ),
// //                   ),
// //                 if (onAccept != null && onReject != null)
// //                   const SizedBox(width: 12),
// //                 if (onReject != null)
// //                   Expanded(
// //                     child: ElevatedButton(
// //                       onPressed: onReject,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFFF44336),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                       child: const Text('Reject'),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }
// // }

// // /// Status chip widget
// // class _StatusChip extends StatelessWidget {
// //   final String status;

// //   const _StatusChip({required this.status});

// //   @override
// //   Widget build(BuildContext context) {
// //     Color color;
// //     String text;

// //     switch (status) {
// //       case 'accepted':
// //         color = Colors.green;
// //         text = 'Accepted';
// //         break;
// //       case 'rejected':
// //         color = Colors.red;
// //         text = 'Rejected';
// //         break;
// //       default:
// //         color = Colors.orange;
// //         text = 'Pending';
// //     }

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(8),
// //         border: Border.all(color: color),
// //       ),
// //       child: Text(
// //         text,
// //         style: TextStyle(
// //           color: color,
// //           fontSize: 12,
// //           fontWeight: FontWeight.bold,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // /// Conversation tile widget
// // class _ConversationTile extends StatelessWidget {
// //   final Map<String, dynamic> conversation;
// //   final VoidCallback onTap;

// //   const _ConversationTile({
// //     required this.conversation,
// //     required this.onTap,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return ListTile(
// //       leading: CircleAvatar(
// //         backgroundImage: conversation['photo_url'] != null &&
// //                 conversation['photo_url'].toString().isNotEmpty
// //             ? NetworkImage(conversation['photo_url'])
// //             : null,
// //         child: conversation['photo_url'] == null ||
// //                 conversation['photo_url'].toString().isEmpty
// //             ? const Icon(Icons.person)
// //             : null,
// //       ),
// //       title: Text(conversation['full_name'] ?? 'Unknown'),
// //       subtitle: Text(conversation['bio']?.toString() ?? ''),
// //       onTap: onTap,
// //     );
// //   }
// // }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:et_learn/helpers/credits.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
// import 'package:et_learn/services/database_service.dart';
// import 'package:et_learn/authentication/auth.dart';
// import 'dart:math';

// /// Model for requests
// class RequestData {
//   final int id;
//   final int courseId;
//   final String learnerUid;
//   final String learnerName;
//   final String courseTitle;
//   final int creditCost;
//   final int durationMinutes;
//   final List<String> availableTimes;
//   final DateTime? scheduledTime;
//   final String? meetingLink;

//   const RequestData({
//     required this.id,
//     required this.courseId,
//     required this.learnerUid,
//     required this.learnerName,
//     required this.courseTitle,
//     required this.creditCost,
//     required this.durationMinutes,
//     required this.availableTimes,
//     this.scheduledTime,
//     this.meetingLink,
//   });
// }

// /// Inbox Screen
// class InboxScreen extends StatefulWidget {
//   const InboxScreen({super.key});

//   @override
//   State<InboxScreen> createState() => _InboxScreenState();
// }

// class _InboxScreenState extends State<InboxScreen> {
//   bool isRequestsTab = true;
//   List<RequestData> requests = [];
//   bool loadingRequests = true;
//   final supabase = Supabase.instance.client;
//   final DatabaseService _dbService = DatabaseService();
//   final Auth _auth = Auth();

//   @override
//   void initState() {
//     super.initState();
//     _loadCredits();
//     _loadRequests();
//   }

//   /// Load user's credits
//   Future<void> _loadCredits() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final data = await supabase
//           .from('users')
//           .select('credits')
//           .eq('uid', user.uid)
//           .maybeSingle();

//       if (data is Map<String, dynamic>) {
//         totalCreditsNotifier.value = data['credits'] ?? 0;
//       }
//     } catch (e) {
//       debugPrint('Error loading credits: $e');
//     }
//   }

//   /// Load demo or real requests
//   Future<void> _loadRequests() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     setState(() => loadingRequests = true);

//     try {
//       final mentorRequests = await _dbService.getMentorRequests(user.uid);

//       final parsed = mentorRequests.map((req) {
//         final course = req['courses'] as Map<String, dynamic>?;
//         final learner = req['users'] as Map<String, dynamic>?;
//         final available =
//             (req['available_times'] as List?)
//                 ?.map((e) => e.toString())
//                 .toList() ??
//             [];

//         return RequestData(
//           id: (req['id'] as num).toInt(),
//           courseId: (req['course_id'] as num).toInt(),
//           learnerUid: req['learner_uid'] as String,
//           learnerName: learner?['full_name']?.toString() ?? 'Student',
//           courseTitle: course?['title']?.toString() ?? 'Course',
//           creditCost: course?['credit_cost'] as int? ?? 0,
//           durationMinutes: course?['duration_minutes'] as int? ?? 0,
//           availableTimes: available,
//           scheduledTime: req['scheduled_time'] != null
//               ? DateTime.tryParse(req['scheduled_time'].toString())
//               : null,
//         );
//       }).toList();

//       // Keep the demo as a fallback preview when there are no real requests
//       final newRequests = parsed.isNotEmpty
//           ? parsed
//           : [
//               const RequestData(
//                 id: 0,
//                 courseId: 0,
//                 learnerUid: 'demo',
//                 learnerName: 'Demo Student',
//                 courseTitle: 'Flutter Basics',
//                 creditCost: 50,
//                 durationMinutes: 60,
//                 availableTimes: ['Now +5 sec'],
//               ),
//             ];

//       if (mounted) {
//         setState(() {
//           requests = newRequests;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading requests: $e');
//     }

//     if (mounted) {
//       setState(() => loadingRequests = false);
//     }
//   }

//   /// Accept a request, pick a slot, and start a meeting
//   Future<void> _acceptRequest(RequestData request) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       final scheduledAt = await _pickTimeSlot(request);
//       if (scheduledAt == null) return;

//       if (request.id != 0) {
//         await _dbService.acceptCourseRequest(
//           request.id,
//           request.learnerUid,
//           request.courseId,
//         );
//       }

//       final password = _generateMeetingPassword();
//       await _startVideoMeeting(request, scheduledAt, password);
//       await _notifyLearner(request, scheduledAt, password);
//       await _loadRequests();

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Request accepted! Meeting starting. Password: $password',
//           ),
//           duration: const Duration(seconds: 6),
//         ),
//       );
//     } catch (e) {
//       debugPrint('Error accepting request: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//     }
//   }

//   /// Let mentor pick a time slot from the student-provided list or scheduled time.
//   Future<DateTime?> _pickTimeSlot(RequestData request) async {
//     final options = <String>[];
//     options.addAll(request.availableTimes);
//     if (request.scheduledTime != null) {
//       options.add(request.scheduledTime!.toIso8601String());
//     }

//     if (options.isEmpty) return DateTime.now();

//     return showModalBottomSheet<DateTime>(
//       context: context,
//       builder: (ctx) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ...options.map(
//               (slot) => ListTile(
//                 title: Text(slot),
//                 onTap: () {
//                   Navigator.pop(ctx, DateTime.tryParse(slot) ?? DateTime.now());
//                 },
//               ),
//             ),
//             ListTile(
//               title: const Text('Start now'),
//               onTap: () => Navigator.pop(ctx, DateTime.now()),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// Start meeting and show meeting link
//   Future<void> _startVideoMeeting(
//     RequestData request,
//     DateTime startAt,
//     String password,
//   ) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     final roomName =
//         'ETLearn_${request.courseId}_${DateTime.now().millisecondsSinceEpoch}';
//     final meetingLink = 'https://meet.jit.si/$roomName';

//     final wait = startAt.difference(DateTime.now());
//     if (wait > Duration.zero) {
//       final capped = wait < const Duration(minutes: 15) ? wait : Duration.zero;
//       if (capped > Duration.zero) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Starting meeting at ${startAt.toLocal()} (${capped.inMinutes} min)',
//               ),
//             ),
//           );
//         }
//         await Future.delayed(capped);
//       }
//     }

//     await JitsiMeetWrapper.joinMeeting(
//       options: JitsiMeetingOptions(
//         roomNameOrUrl: roomName,
//         userDisplayName: user.displayName ?? 'Mentor',
//         configOverrides: {'requireDisplayName': true, 'roomPassword': password},
//       ),
//     );

//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Meeting link: $meetingLink | Password: $password'),
//         duration: const Duration(seconds: 8),
//       ),
//     );
//   }

//   String _generateMeetingPassword() {
//     const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
//     final rand = Random.secure();
//     return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
//   }

//   Future<void> _notifyLearner(
//     RequestData request,
//     DateTime scheduledAt,
//     String password,
//   ) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final roomName =
//           'ETLearn_${request.courseId}_${DateTime.now().millisecondsSinceEpoch}';
//       final meetingLink = 'https://meet.jit.si/$roomName';
//       final whenLabel = scheduledAt.toLocal().toString();

//       await _dbService.sendMessage(
//         senderUid: user.uid,
//         receiverUid: request.learnerUid,
//         content:
//             'Your session for ${request.courseTitle} is scheduled at $whenLabel. Join: $meetingLink Password: $password',
//         courseId: request.courseId,
//       );
//     } catch (e) {
//       debugPrint('Failed to notify learner: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F8FE),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: ValueListenableBuilder<int>(
//           valueListenable: totalCreditsNotifier,
//           builder: (context, totalCredits, _) {
//             return Text(
//               'Inbox',
//               style: const TextStyle(
//                 color: Color(0xFF202244),
//                 fontFamily: 'Jost',
//                 fontSize: 21,
//                 fontWeight: FontWeight.w600,
//               ),
//             );
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           children: [
//             const SizedBox(height: 16),
//             // Tabs
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => isRequestsTab = false),
//                     child: _TabButton(title: 'Chat', selected: !isRequestsTab),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => isRequestsTab = true),
//                     child: _TabButton(
//                       title: 'Requests',
//                       selected: isRequestsTab,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // Content
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Color(0x14000000),
//                       blurRadius: 10,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: isRequestsTab
//                     ? (loadingRequests
//                           ? const Center(child: CircularProgressIndicator())
//                           : requests.isEmpty
//                           ? const Center(
//                               child: Text(
//                                 'No pending requests',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             )
//                           : RefreshIndicator(
//                               onRefresh: _loadRequests,
//                               child: ListView(
//                                 children: requests
//                                     .map(
//                                       (req) => RequestTile(
//                                         request: req,
//                                         onAccept: () => _acceptRequest(req),
//                                         onDeny: () async {
//                                           await _dbService.rejectCourseRequest(
//                                             req.id,
//                                           );
//                                           setState(() {
//                                             requests.remove(req);
//                                           });
//                                           ScaffoldMessenger.of(
//                                             context,
//                                           ).showSnackBar(
//                                             SnackBar(
//                                               content: Text(
//                                                 'Denied ${req.learnerName}, requester notified.',
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     )
//                                     .toList(),
//                               ),
//                             ))
//                     : const Center(
//                         child: Text(
//                           'Chat screen here...',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Tab button used in the inbox header.
// class _TabButton extends StatelessWidget {
//   final String title;
//   final bool selected;

//   const _TabButton({required this.title, required this.selected});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 48,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: selected ? const Color(0xFF167F71) : const Color(0xFFE8F1FF),
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: selected ? Colors.white : const Color(0xFF202244),
//           fontFamily: 'Mulish',
//           fontSize: 15,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     );
//   }
// }

// /// Shows a single request with Accept/Deny buttons.
// class RequestTile extends StatelessWidget {
//   final RequestData request;
//   final VoidCallback onAccept;
//   final VoidCallback onDeny;

//   const RequestTile({
//     super.key,
//     required this.request,
//     required this.onAccept,
//     required this.onDeny,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final scheduledLabel = request.scheduledTime != null
//         ? 'Scheduled: ${request.scheduledTime!.toLocal()}'
//         : null;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             request.learnerName,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF202244),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${request.courseTitle} • ${(request.durationMinutes ~/ 60)}h ${(request.durationMinutes % 60)}m • ${request.creditCost} credits',
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF545454),
//             ),
//           ),
//           if (request.availableTimes.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Text(
//                 'Preferred times: ${request.availableTimes.join(', ')}',
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF0961F5),
//                 ),
//               ),
//             ),
//           if (scheduledLabel != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 2),
//               child: Text(
//                 scheduledLabel,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF167F71),
//                 ),
//               ),
//             ),
//           if (request.meetingLink != null) ...[
//             const SizedBox(height: 4),
//             SelectableText(
//               'Meeting: ${request.meetingLink}',
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF0961F5),
//               ),
//             ),
//           ],
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: onAccept,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF167F71),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Accept',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: onDeny,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFF44336),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Deny',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:et_learn/helpers/credits.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model for requests
class RequestData {
  final String id;
  final String name;
  final String course;
  final String duration;
  final int coins;
  final List<String> availableTimes;
  final String? meetingLink; // optional

  const RequestData({
    required this.id,
    required this.name,
    required this.course,
    required this.duration,
    required this.coins,
    required this.availableTimes,
    this.meetingLink,
  });
}

/// Inbox Screen
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool isRequestsTab = true;
  List<RequestData> requests = [];
  final supabase = Supabase.instance.client;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadCredits();
    _loadRequests();
  }

  /// Load user's credits
  Future<void> _loadCredits() async {
    try {
      final data = await supabase
          .from('users')
          .select('credits')
          .eq('uid', uid)
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
    final List<RequestData> loadedRequests = [
      const RequestData(
        id: 'demo1',
        name: 'Demo Student',
        course: 'Flutter Basics',
        duration: '1 Hr',
        coins: 50,
        availableTimes: ['Now +5 sec'],
      ),
    ];

    setState(() {
      requests = loadedRequests;
    });
  }

  /// Add coins after meeting
  Future<void> _addCoins(int coinsToAdd) async {
    try {
      final data = await supabase
          .from('users')
          .select('credits')
          .eq('uid', uid)
          .maybeSingle();

      int currentCredits = totalCreditsNotifier.value;
      if (data is Map<String, dynamic>) {
        currentCredits = data['credits'] ?? currentCredits;
      }

      final newCredits = currentCredits + coinsToAdd;

      await supabase
          .from('users')
          .update({'credits': newCredits})
          .eq('uid', uid);

      totalCreditsNotifier.value = newCredits;
    } catch (e) {
      debugPrint('Error adding coins: $e');
    }
  }

  /// Start meeting and show meeting link
  Future<void> _startDemoMeeting(RequestData request) async {
    final roomName =
        'ETLearn_${request.name}_${DateTime.now().millisecondsSinceEpoch}';
    final meetingLink = 'https://meet.jit.si/$roomName';

    // Update UI to show link
    final updatedRequest = RequestData(
      id: request.id,
      name: request.name,
      course: request.course,
      duration: request.duration,
      coins: request.coins,
      availableTimes: request.availableTimes,
      meetingLink: meetingLink,
    );

    setState(() {
      requests.remove(request);
      requests.insert(0, updatedRequest); // show updated tile
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Meeting link ready: $meetingLink')));

    // Short delay before starting meeting
    await Future.delayed(const Duration(seconds: 2));

    await JitsiMeetWrapper.joinMeeting(
      options: JitsiMeetingOptions(
        roomNameOrUrl: roomName,
        userDisplayName: 'Teacher',
      ),
    );

    // Add coins after meeting ends
    await _addCoins(request.coins);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meeting ended. Coins (${request.coins}) credited!'),
      ),
    );
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
                    ? requests.isEmpty
                          ? const Center(
                              child: Text(
                                'No pending requests',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView(
                              children: requests
                                  .map(
                                    (req) => RequestTile(
                                      request: req,
                                      onAccept: () => _startDemoMeeting(req),
                                      onDeny: () {
                                        setState(() {
                                          requests.remove(req);
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
          Text(
            request.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202244),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${request.course} • ${request.duration} • ${request.coins} coins',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF545454),
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
