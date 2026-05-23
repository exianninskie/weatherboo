import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class UserProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  bool _isLoggedIn = false;
  String? _userId;
  String? _email;
  String? _profilePictureUrl;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get email => _email;
  String? get profilePictureUrl => _profilePictureUrl;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Sign in user
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _supabaseService.signIn(email, password);
      if (response != null) {
        _isLoggedIn = true;
        _userId = response['id'];
        _email = response['email'];
        await _loadUserProfile();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up user
  Future<bool> signUp(String email, String password, String displayName, {String? defaultCity}) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _supabaseService.signUp(email, password, displayName, defaultCity: defaultCity);
      if (response != null) {
        _isLoggedIn = true;
        _userId = response['id'];
        _email = response['email'];
        await _loadUserProfile();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out user
  Future<void> signOut() async {
    _setLoading(true);
    _error = null;
    
    try {
      await _supabaseService.signOut();
      _isLoggedIn = false;
      _userId = null;
      _email = null;
      _profilePictureUrl = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load current user from Supabase auth
  Future<void> loadCurrentUser({bool forceReload = false}) async {
    final currentUser = _supabaseService.currentUser;
    if (currentUser == null) {
      _isLoggedIn = false;
      notifyListeners();
      return;
    }

    _isLoggedIn = true;
    _userId = currentUser.id;
    _email = currentUser.email;

    if (!forceReload && _userProfile != null) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      await _loadUserProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile() async {
    if (_userId == null) return;
    
    try {
      final profile = await _supabaseService.getUserProfile(_userId!);
      _userProfile = profile;
      _profilePictureUrl = profile?['profile_picture_url'];
      notifyListeners();
    } catch (e) {
      // If profile doesn't exist, create it
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        try {
          final success = await _supabaseService.updateUserProfile(_userId!, {
            'display_name': _email?.split('@')[0] ?? 'User',
            'email': _email,
            'default_city': 'New York',
            'temperature_unit': 'Celsius',
            'notifications_enabled': true,
            'last_online': DateTime.now().toIso8601String(),
          });
          if (success) {
            final newProfile = await _supabaseService.getUserProfile(_userId!);
            _userProfile = newProfile;
            notifyListeners();
          }
        } catch (createError) {
          _error = createError.toString();
          notifyListeners();
        }
      } else {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _supabaseService.updateUserProfile(_userId!, data);
      if (success) {
        _userProfile = {...?_userProfile, ...data};
        notifyListeners();
        await _loadUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user email
  Future<bool> updateEmail(String newEmail) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _supabaseService.updateUserEmail(newEmail);
      _email = newEmail;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload profile picture from file
  Future<bool> uploadProfilePicture(dynamic imageFile) async {
    _setLoading(true);
    _error = null;
    
    try {
      final imageUrl = await _supabaseService.uploadProfilePicture(_userId!, imageFile);
      if (imageUrl != null) {
        final success = await _supabaseService.updateUserProfile(_userId!, {
          'profile_picture_url': imageUrl,
        });
        if (success) {
          _profilePictureUrl = imageUrl;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update last online timestamp
  Future<void> updateLastOnline() async {
    if (_userId == null) return;
    
    try {
      await _supabaseService.updateUserProfile(_userId!, {
        'last_online': DateTime.now().toIso8601String(),
      });
      if (_userProfile != null) {
        _userProfile = {..._userProfile!, 'last_online': DateTime.now().toIso8601String()};
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for online status updates
    }
  }

  // Get online status text based on last_online timestamp
  String getOnlineStatus() {
    final lastOnline = _userProfile?['last_online'];
    if (lastOnline == null) return 'online';
    
    try {
      final lastOnlineTime = DateTime.parse(lastOnline);
      final now = DateTime.now();
      final difference = now.difference(lastOnlineTime);
      
      if (difference.inMinutes < 5) {
        return 'online';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return 'last online recently';
      }
    } catch (e) {
      return 'online';
    }
  }

  // Check if user is currently online (within 5 minutes)
  bool get isOnline {
    final lastOnline = _userProfile?['last_online'];
    if (lastOnline == null) return true;
    
    try {
      final lastOnlineTime = DateTime.parse(lastOnline);
      final now = DateTime.now();
      final difference = now.difference(lastOnlineTime);
      return difference.inMinutes < 5;
    } catch (e) {
      return true;
    }
  }
}
