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
  Future<Map<String, dynamic>?> signUp(String email, String password, String displayName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
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
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);
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
        await _supabase.storage.from('profile_pictures').uploadBinary(fileName, bytes);
      } else if (imageFile is File) {
        await _supabase.storage.from('profile_pictures').upload(fileName, imageFile);
      }
      
      final imageUrl = _supabase.storage.from('profile_pictures').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
  
  // Save weather preferences
  Future<bool> saveWeatherPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      await _supabase
          .from('profiles')
          .update(preferences)
          .eq('id', userId);
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
}
