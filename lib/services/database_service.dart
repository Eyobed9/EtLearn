import 'package:supabase_flutter/supabase_flutter.dart';

/// Database service for courses, mentors, requests, enrollments, messages
class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ========== Courses ==========

  /// Get all courses with creator info
  Future<List<Map<String, dynamic>>> getAllCourses({int limit = 100}) async {
    final response = await _supabase
        .from('courses')
        .select('''
          id,
          creator_uid,
          title,
          subject,
          description,
          thumbnail_url,
          duration_minutes,
          level,
          credit_cost,
          created_at,
          users!courses_creator_uid_fkey (
            uid,
            full_name,
            photo_url,
            bio
          )
        ''')
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get featured courses (latest courses, limited)
  Future<List<Map<String, dynamic>>> getFeaturedCourses({int limit = 6}) async {
    return getAllCourses(limit: limit);
  }

  /// Get course by ID
  Future<Map<String, dynamic>?> getCourseById(int courseId) async {
    final response = await _supabase
        .from('courses')
        .select('''
          id,
          creator_uid,
          title,
          subject,
          description,
          thumbnail_url,
          duration_minutes,
          level,
          credit_cost,
          created_at,
          users!courses_creator_uid_fkey (
            uid,
            full_name,
            photo_url,
            bio
          )
        ''')
        .eq('id', courseId)
        .maybeSingle();

    return response;
  }

  /// Search courses by title or subject
  Future<List<Map<String, dynamic>>> searchCourses(String query) async {
    final response = await _supabase
        .from('courses')
        .select('''
          id,
          creator_uid,
          title,
          subject,
          description,
          thumbnail_url,
          duration_minutes,
          level,
          credit_cost,
          created_at,
          users!courses_creator_uid_fkey (
            uid,
            full_name,
            photo_url
          )
        ''')
        .or('title.ilike.%$query%,subject.ilike.%$query%')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get courses created by a user
  Future<List<Map<String, dynamic>>> getCoursesByCreator(String creatorUid) async {
    final response = await _supabase
        .from('courses')
        .select('''
          id,
          creator_uid,
          title,
          subject,
          description,
          thumbnail_url,
          duration_minutes,
          level,
          credit_cost,
          created_at
        ''')
        .eq('creator_uid', creatorUid)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get courses enrolled by a user
  Future<List<Map<String, dynamic>>> getEnrolledCourses(String learnerUid) async {
    final response = await _supabase
        .from('enrollments')
        .select('''
          id,
          course_id,
          enrolled_at,
          progress_percentage,
          status,
          courses (
            id,
            creator_uid,
            title,
            subject,
            description,
            thumbnail_url,
            duration_minutes,
            level,
            credit_cost,
            users!courses_creator_uid_fkey (
              uid,
              full_name,
              photo_url
            )
          )
        ''')
        .eq('learner_uid', learnerUid)
        .order('enrolled_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ========== Users/Mentors ==========

  /// Get all users/mentors
  Future<List<Map<String, dynamic>>> getAllMentors({int limit = 100}) async {
    final response = await _supabase
        .from('users')
        .select('uid, email, full_name, photo_url, bio, skills, subjects_teach, credits')
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get featured mentors (users with courses, limited)
  Future<List<Map<String, dynamic>>> getFeaturedMentors({int limit = 6}) async {
    // Get users who have created courses
    final response = await _supabase
        .from('users')
        .select('''
          uid,
          email,
          full_name,
          photo_url,
          bio,
          skills,
          subjects_teach,
          credits
        ''')
        .limit(limit);

    final mentors = List<Map<String, dynamic>>.from(response);
    
    // Filter to only include mentors who have created at least one course
    final mentorsWithCourses = <Map<String, dynamic>>[];
    for (final mentor in mentors) {
      final courses = await getCoursesByCreator(mentor['uid'] as String);
      if (courses.isNotEmpty) {
        mentorsWithCourses.add(mentor);
      }
      if (mentorsWithCourses.length >= limit) break;
    }

    return mentorsWithCourses;
  }

  /// Search mentors by name or skills
  Future<List<Map<String, dynamic>>> searchMentors(String query) async {
    final response = await _supabase
        .from('users')
        .select('uid, email, full_name, photo_url, bio, skills, subjects_teach, credits')
        .or('full_name.ilike.%$query%,bio.ilike.%$query%')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get mentor profile by UID
  Future<Map<String, dynamic>?> getMentorProfile(String mentorUid) async {
    final response = await _supabase
        .from('users')
        .select('uid, email, full_name, photo_url, bio, skills, subjects_teach, credits, created_at')
        .eq('uid', mentorUid)
        .maybeSingle();

    return response;
  }

  /// Search both courses and mentors
  Future<Map<String, List<Map<String, dynamic>>>> searchAll(String query) async {
    final courses = await searchCourses(query);
    final mentors = await searchMentors(query);
    return {
      'courses': courses,
      'mentors': mentors,
    };
  }

  // ========== Course Requests ==========

  /// Create a course request
  Future<Map<String, dynamic>> createCourseRequest({
    required int courseId,
    required String learnerUid,
    required String mentorUid,
  }) async {
    final response = await _supabase
        .from('course_requests')
        .insert({
          'course_id': courseId,
          'learner_uid': learnerUid,
          'mentor_uid': mentorUid,
          'status': 'pending',
        })
        .select()
        .single();

    return response;
  }

  /// Get course requests for a mentor (incoming requests)
  Future<List<Map<String, dynamic>>> getMentorRequests(String mentorUid) async {
    final response = await _supabase
        .from('course_requests')
        .select('''
          id,
          course_id,
          learner_uid,
          mentor_uid,
          status,
          created_at,
          updated_at,
          courses (
            id,
            title,
            subject,
            credit_cost,
            duration_minutes
          ),
          users!course_requests_learner_uid_fkey (
            uid,
            full_name,
            photo_url
          )
        ''')
        .eq('mentor_uid', mentorUid)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get course requests sent by a learner (outgoing requests)
  Future<List<Map<String, dynamic>>> getLearnerRequests(String learnerUid) async {
    final response = await _supabase
        .from('course_requests')
        .select('''
          id,
          course_id,
          learner_uid,
          mentor_uid,
          status,
          created_at,
          updated_at,
          courses (
            id,
            title,
            subject,
            credit_cost,
            duration_minutes,
            users!courses_creator_uid_fkey (
              uid,
              full_name,
              photo_url
            )
          )
        ''')
        .eq('learner_uid', learnerUid)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Accept a course request
  Future<void> acceptCourseRequest(int requestId, String learnerUid, int courseId) async {
    // Update request status
    await _supabase
        .from('course_requests')
        .update({'status': 'accepted', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', requestId);
    
    // Create enrollment
    await _supabase.from('enrollments').insert({
      'course_id': courseId,
      'learner_uid': learnerUid,
      'status': 'in_progress',
      'enrolled_at': DateTime.now().toIso8601String(),
    });
  }

  /// Reject a course request
  Future<void> rejectCourseRequest(int requestId) async {
    await _supabase
        .from('course_requests')
        .update({'status': 'rejected', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', requestId);
  }

  // ========== Messages ==========

  /// Get messages between two users
  Future<List<Map<String, dynamic>>> getMessages({
    required String userId1,
    required String userId2,
    int? courseId,
  }) async {
    final query = _supabase
        .from('messages')
        .select('''
          id,
          sender_uid,
          receiver_uid,
          course_id,
          content,
          created_at,
          users!messages_sender_uid_fkey (
            uid,
            full_name,
            photo_url
          )
        ''')
        .or('and(sender_uid.eq.$userId1,receiver_uid.eq.$userId2),and(sender_uid.eq.$userId2,receiver_uid.eq.$userId1)');

    final response = courseId != null
        ? await query.eq('course_id', courseId).order('created_at', ascending: true)
        : await query.order('created_at', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Send a message
  Future<Map<String, dynamic>> sendMessage({
    required String senderUid,
    required String receiverUid,
    required String content,
    int? courseId,
  }) async {
    final response = await _supabase
        .from('messages')
        .insert({
          'sender_uid': senderUid,
          'receiver_uid': receiverUid,
          'content': content,
          'course_id': courseId,
        })
        .select()
        .single();

    return response;
  }

  /// Get conversations for a user
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    // Get distinct conversation partners
    final sentMessages = await _supabase
        .from('messages')
        .select('receiver_uid, created_at')
        .eq('sender_uid', userId)
        .order('created_at', ascending: false);

    final receivedMessages = await _supabase
        .from('messages')
        .select('sender_uid, created_at')
        .eq('receiver_uid', userId)
        .order('created_at', ascending: false);

    // Combine and get unique user IDs
    final userIds = <String>{};
    for (final msg in sentMessages) {
      userIds.add(msg['receiver_uid'] as String);
    }
    for (final msg in receivedMessages) {
      userIds.add(msg['sender_uid'] as String);
    }

    // Get user info for each conversation partner
    final conversations = <Map<String, dynamic>>[];
    for (final uid in userIds) {
      final user = await getMentorProfile(uid);
      if (user != null) {
        conversations.add(user);
      }
    }

    return conversations;
  }

  // ========== User Profile ==========

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final response = await _supabase
        .from('users')
        .select('uid, email, full_name, photo_url, bio, skills, subjects_teach, credits, created_at')
        .eq('uid', uid)
        .maybeSingle();

    return response;
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    await _supabase
        .from('users')
        .update({
          ...updates,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('uid', uid);
  }

  /// Get user credits
  Future<int> getUserCredits(String uid) async {
    final response = await _supabase
        .from('users')
        .select('credits')
        .eq('uid', uid)
        .maybeSingle();

    return (response?['credits'] as int?) ?? 0;
  }
}
