import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart' show XFile;

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign in user
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user?.toJson();
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up user
  Future<Map<String, dynamic>?> signUp(
      String email, String password, String displayName,
      {String? defaultCity}) async {
    try {
      final data = {'display_name': displayName};
      if (defaultCity != null) {
        data['default_city'] = defaultCity;
      }
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response.user?.toJson();
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();
      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _supabase.from('profiles').update(data).eq('id', userId);
      return true;
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update user email
  Future<void> updateUserEmail(String newEmail) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(String userId, dynamic imageFile) async {
    try {
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Handle web platform differently
      if (imageFile is XFile) {
        final bytes = await imageFile.readAsBytes();
        await _supabase.storage
            .from('profile_pictures')
            .uploadBinary(fileName, bytes);
      } else if (imageFile is File) {
        await _supabase.storage
            .from('profile_pictures')
            .upload(fileName, imageFile);
      }

      final imageUrl =
          _supabase.storage.from('profile_pictures').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Save weather preferences
  Future<bool> saveWeatherPreferences(
      String userId, Map<String, dynamic> preferences) async {
    try {
      await _supabase.from('profiles').update(preferences).eq('id', userId);
      return true;
    } catch (e) {
      throw Exception('Failed to save weather preferences: $e');
    }
  }

  // Get weather preferences
  Future<Map<String, dynamic>?> getWeatherPreferences(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('default_city, temperature_unit, notifications_enabled')
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to get weather preferences: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamCommunityPosts() {
    return _supabase
        .from('community_posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .execute();
  }

  Future<bool> createCommunityPost({
    required String userId,
    required String displayName,
    required String avatar,
    required String content,
    required String weather,
  }) async {
    try {
      await _supabase.from('community_posts').insert({
        'user_id': userId,
        'display_name': displayName,
        'avatar': avatar,
        'content': content,
        'weather': weather,
        'likes': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to create community post: $e');
    }
  }

  Future<bool> deleteCommunityPost(String postId) async {
    try {
      await _supabase.from('community_posts').delete().eq('id', postId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete community post: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamOnlineUsers() {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('is_online', true)
        .order('display_name', ascending: true)
        .execute();
  }

  Future<bool> setUserPresence(String userId, bool isOnline) async {
    try {
      await _supabase.from('profiles').update({
        'is_online': isOnline,
        'last_online': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return true;
    } catch (e) {
      throw Exception('Failed to update user presence: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamBuddyComments() {
    return _supabase
        .from('buddy_comments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .execute();
  }

  Future<bool> createBuddyComment({
    required String recipientId,
    required String authorId,
    required String authorName,
    required String text,
    String? replyToText,
  }) async {
    try {
      final commentData = {
        'recipient_id': recipientId,
        'author_id': authorId,
        'author_name': authorName,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      };

      if (replyToText != null) {
        commentData['reply_to_text'] = replyToText;
      }

      await _supabase.from('buddy_comments').insert(commentData);
      return true;
    } catch (e) {
      throw Exception('Failed to post buddy comment: $e');
    }
  }

  Future<bool> deleteBuddyComment(String commentId) async {
    try {
      await _supabase.from('buddy_comments').delete().eq('id', commentId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete buddy comment: $e');
    }
  }

  Future<Map<String, String?>> getProfilePictureUrls(
      List<String> userIds) async {
    if (userIds.isEmpty) return {};

    try {
      final response = await _supabase
          .from('profiles')
          .select('id, profile_picture_url')
          .filter('id', 'in', userIds);
      final result = <String, String?>{};
      for (final profile in (response as List<dynamic>)) {
        final id = profile['id'] as String?;
        final url = profile['profile_picture_url'] as String?;
        if (id != null) {
          result[id] = url;
        }
      }
      return result;
    } catch (e) {
      throw Exception('Failed to load profile picture URLs: $e');
    }
  }
}
