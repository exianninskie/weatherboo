import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../services/supabase_service.dart';
import '../services/weather_service.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';
import '../widgets/user_role_badge.dart';

class SocialCommunityScreen extends StatefulWidget {
  const SocialCommunityScreen({super.key});

  @override
  State<SocialCommunityScreen> createState() => _SocialCommunityScreenState();
}

class _SocialCommunityScreenState extends State<SocialCommunityScreen> {
  final WeatherService _weatherService = WeatherService();
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic>? _currentWeather;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentCity = 'New York';
  List<Map<String, dynamic>> _communityPosts = [];
  List<Map<String, dynamic>> _weatherBuddies = [];
  final Map<String, List<Map<String, dynamic>>> _buddyComments = {};
  final Map<String, String?> _commentAuthorAvatars = {};
  final Map<String, String?> _communityPostAuthorAvatars = {};
  StreamSubscription<List<Map<String, dynamic>>>? _communityPostsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _onlineBuddiesSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _buddyCommentsSubscription;
  final TextEditingController _momentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _communityPostsSubscription?.cancel();
    _onlineBuddiesSubscription?.cancel();
    _buddyCommentsSubscription?.cancel();
    _setUserPresence(false);
    _momentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    final targetCity = profile?['default_city'] ?? 'New York';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentCity = targetCity;
    });

    try {
      final currentWeather =
          await _weatherService.getCurrentWeather(targetCity);
      await _setUserPresence(true);
      _subscribeCommunityPosts();
      _subscribeOnlineBuddies();
      _subscribeBuddyComments();

      if (mounted) {
        setState(() {
          _currentWeather = currentWeather;
          _isLoading = false;
        });
        debugPrint('Weather loaded for $targetCity: $currentWeather');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        debugPrint('Error loading data: $e');
      }
    }
  }

  void _subscribeCommunityPosts() {
    _communityPostsSubscription?.cancel();
    _communityPostsSubscription =
        _supabaseService.streamCommunityPosts().listen((posts) async {
      final currentUserId =
          Provider.of<UserProvider>(context, listen: false).userId;
      final currentUserName = _currentUserDisplayName();

      final formattedPosts = posts.map((post) {
        final createdAt = post['created_at'];
        final postUserId = post['user_id'] as String?;
        return {
          ...post,
          'created_at':
              createdAt is String ? DateTime.parse(createdAt) : createdAt,
          'timestamp':
              createdAt is String ? DateTime.parse(createdAt) : createdAt,
          'user': postUserId == currentUserId
              ? currentUserName
              : post['display_name'] ?? 'Weatherboo user',
        };
      }).toList();

      final authorIds = formattedPosts
          .map((post) => post['user_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      Map<String, String?> postAuthorAvatars = {};
      if (authorIds.isNotEmpty) {
        try {
          postAuthorAvatars =
              await _supabaseService.getProfilePictureUrls(authorIds);
        } catch (e) {
          debugPrint('Failed to load community post author avatars: $e');
        }
      }

      if (mounted) {
        setState(() {
          _communityPostAuthorAvatars
            ..clear()
            ..addAll(postAuthorAvatars);
          _communityPosts = formattedPosts.map((post) {
            final userId = post['user_id'] as String?;
            return {
              ...post,
              'avatarUrl': userId != null ? postAuthorAvatars[userId] : null,
            };
          }).toList();
        });
      }
    }, onError: (error) {
      debugPrint('Community posts stream error: $error');
    });
  }

  void _subscribeOnlineBuddies() {
    _onlineBuddiesSubscription?.cancel();
    _onlineBuddiesSubscription =
        _supabaseService.streamOnlineUsers().listen((profiles) {
      final currentUserId =
          Provider.of<UserProvider>(context, listen: false).userId;
      final currentUserName = _currentUserDisplayName();
      final buddies = profiles.map((profile) {
        final isCurrentUser = profile['id'] == currentUserId;
        final displayName = profile['display_name'] as String?;
        final email = profile['email'] as String?;
        return {
          'id': profile['id'] as String?,
          'name': isCurrentUser
              ? currentUserName
              : displayName ?? email?.split('@').first ?? 'Weather Buddy',
          'avatarUrl': profile['profile_picture_url'] as String?,
          'avatar': profile['profile_picture_url'] != null ? '👤' : '☁️',
          'activity':
              profile['bio'] ?? 'Loves weather chats and checking the sky',
          'status': profile['is_online'] == true ? 'Online' : 'Away',
          'sharedInterests': <String>['Weather', 'Nature', 'Friends'],
        };
      }).toList();

      buddies.sort((a, b) {
        if (a['id'] == currentUserId) return -1;
        if (b['id'] == currentUserId) return 1;
        final nameA = (a['name'] as String?) ?? '';
        final nameB = (b['name'] as String?) ?? '';
        return nameA.compareTo(nameB);
      });

      setState(() {
        _weatherBuddies = buddies;
      });
    }, onError: (error) {
      debugPrint('Online buddies stream error: $error');
    });
  }

  void _subscribeBuddyComments() {
    _buddyCommentsSubscription?.cancel();
    _buddyCommentsSubscription =
        _supabaseService.streamBuddyComments().listen((comments) async {
      final grouped = <String, List<Map<String, String>>>{};
      final authorIds = <String>{};
      final currentUserId =
          Provider.of<UserProvider>(context, listen: false).userId;
      final currentUserName = _currentUserDisplayName();

      for (final comment in comments) {
        final recipientId = comment['recipient_id'] as String?;
        final authorId = comment['author_id'] as String?;
        if (recipientId == null || authorId == null) {
          continue;
        }

        grouped.putIfAbsent(recipientId, () => []).add({
          'id': comment['id']?.toString() ?? '',
          'authorId': authorId,
          'author': authorId == currentUserId
              ? currentUserName
              : comment['author_name'] as String? ?? 'Weatherboo user',
          'text': comment['text'] as String? ?? '',
          'timestamp': comment['created_at'] as String? ?? '',
          'replyToText': comment['reply_to_text'] as String? ?? '',
        });
        authorIds.add(authorId);
      }

      for (final commentsForBuddy in grouped.values) {
        commentsForBuddy.sort((a, b) {
          final aTime = _parseTimestamp(a['timestamp']);
          final bTime = _parseTimestamp(b['timestamp']);
          return bTime.compareTo(aTime);
        });
      }

      try {
        final avatarUrls =
            await _supabaseService.getProfilePictureUrls(authorIds.toList());
        if (mounted) {
          setState(() {
            _commentAuthorAvatars
              ..clear()
              ..addAll(avatarUrls);
            _buddyComments
              ..clear()
              ..addAll(grouped);
          });
        }
      } catch (e) {
        debugPrint('Failed to load author avatars: $e');
        if (mounted) {
          setState(() {
            _buddyComments
              ..clear()
              ..addAll(grouped);
          });
        }
      }
    }, onError: (error) {
      debugPrint('Buddy comments stream error: $error');
    });
  }

  Future<void> _setUserPresence(bool isOnline) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    if (userId == null) return;

    try {
      await _supabaseService.setUserPresence(userId, isOnline);
    } catch (e) {
      debugPrint('Failed to update presence: $e');
    }
  }

  Future<void> _shareMoment() async {
    if (_momentController.text.trim().isEmpty) return;

    final weatherMain =
        _currentWeather?['weather'][0]['main'] as String? ?? 'clear';
    final momentText = _momentController.text.trim();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    final userId = userProvider.userId;
    final displayName = profile?['display_name'] ??
        (userProvider.email?.split('@').first ?? 'Weatherboo user');

    if (userId == null) return;

    try {
      await _supabaseService.createCommunityPost(
        userId: userId,
        displayName: displayName,
        avatar: '🌟',
        content: momentText,
        weather: weatherMain,
      );
      _momentController.clear();
    } catch (e) {
      debugPrint('Failed to create community post: $e');
    }
  }

  String _getWeatherCondition(String? weatherMain) {
    if (weatherMain == null) return 'clear';

    final condition = weatherMain.toLowerCase();
    final conditionMapping = {
      'clear sky': 'clear',
      'clear': 'clear',
      'few clouds': 'clouds',
      'scattered clouds': 'clouds',
      'broken clouds': 'clouds',
      'overcast clouds': 'clouds',
      'clouds': 'clouds',
      'cloud': 'clouds',
      'light rain': 'rain',
      'moderate rain': 'rain',
      'heavy intensity rain': 'rain',
      'very heavy rain': 'rain',
      'extreme rain': 'rain',
      'freezing rain': 'rain',
      'light intensity shower rain': 'rain',
      'shower rain': 'rain',
      'heavy intensity shower rain': 'rain',
      'ragged shower rain': 'rain',
      'rain': 'rain',
      'light intensity drizzle': 'drizzle',
      'drizzle': 'drizzle',
      'heavy intensity drizzle': 'drizzle',
      'light intensity drizzle rain': 'drizzle',
      'drizzle rain': 'drizzle',
      'heavy intensity drizzle rain': 'drizzle',
      'shower rain and drizzle': 'drizzle',
      'heavy shower rain and drizzle': 'drizzle',
      'shower drizzle': 'drizzle',
      'thunderstorm with light rain': 'thunderstorm',
      'thunderstorm with rain': 'thunderstorm',
      'thunderstorm with heavy rain': 'thunderstorm',
      'light thunderstorm': 'thunderstorm',
      'heavy thunderstorm': 'thunderstorm',
      'ragged thunderstorm': 'thunderstorm',
      'thunderstorm with light drizzle': 'thunderstorm',
      'thunderstorm with drizzle': 'thunderstorm',
      'thunderstorm with heavy drizzle': 'thunderstorm',
      'thunderstorm': 'thunderstorm',
      'light snow': 'snow',
      'heavy snow': 'snow',
      'sleet': 'snow',
      'light shower sleet': 'snow',
      'shower sleet': 'snow',
      'rain and snow': 'snow',
      'light rain and snow': 'snow',
      'light shower snow': 'snow',
      'shower snow': 'snow',
      'heavy shower snow': 'snow',
      'snow': 'snow',
      'mist': 'mist',
      'smoke': 'mist',
      'haze': 'mist',
      'dust': 'mist',
      'fog': 'mist',
      'sand': 'mist',
      'ash': 'mist',
      'squall': 'mist',
      'tornado': 'mist',
    };

    return conditionMapping[condition] ?? condition;
  }

  String _getWeatherUsernamePrefix(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return 'Sunny';
      case 'clouds':
      case 'cloudy':
        return 'Cloudy';
      case 'rain':
      case 'drizzle':
        return 'Rainy';
      case 'snow':
        return 'Snowy';
      case 'thunderstorm':
        return 'Stormy';
      case 'mist':
      case 'fog':
      case 'haze':
        return 'Misty';
      default:
        return 'Weather';
    }
  }

  String _formatCommunityUsername(String rawUsername, String weatherMain) {
    if (rawUsername == 'You') return _currentUserDisplayName();
    final prefix = _getWeatherUsernamePrefix(weatherMain);
    final lowerUsername = rawUsername.toLowerCase();
    if (lowerUsername.startsWith(prefix.toLowerCase())) {
      return rawUsername;
    }
    return '$prefix$rawUsername';
  }

  String _formatCommentText(String? text, String? replyToText) {
    if (replyToText != null && replyToText.isNotEmpty) {
      return '$replyToText > $text';
    }
    return text ?? '';
  }

  Future<void> _confirmDeleteBuddyComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _supabaseService.deleteBuddyComment(commentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: $e')),
        );
      }
    }
  }

  Future<void> _showBuddyCommentSheet(Map<String, dynamic> buddy) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Comment on ${buddy['name']}',
                  style: AppTypography.headline(18)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Write a kind comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lavender,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  final profile = userProvider.userProfile;
                  final userId = userProvider.userId;
                  final recipientId = buddy['id'] as String?;
                  final authorName = profile?['display_name'] ??
                      (userProvider.email?.split('@').first ??
                          'Weatherboo user');
                  if (userId != null && recipientId != null) {
                    _supabaseService.createBuddyComment(
                      recipientId: recipientId,
                      authorId: userId,
                      authorName: authorName,
                      text: text,
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Post Comment'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showReplyCommentSheet(
    String threadRecipientId,
    String recipientName,
    String originalCommentText,
  ) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reply to $recipientName',
                  style: AppTypography.headline(18)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  originalCommentText,
                  style: AppTypography.body(12, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Write a reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lavender,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  final profile = userProvider.userProfile;
                  final userId = userProvider.userId;
                  final authorName = profile?['display_name'] ??
                      (userProvider.email?.split('@').first ??
                          'Weatherboo user');
                  if (userId != null) {
                    _supabaseService.createBuddyComment(
                      recipientId: threadRecipientId,
                      authorId: userId,
                      authorName: authorName,
                      text: text,
                      replyToText: originalCommentText,
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Post Reply'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAllBuddyCommentsSheet(
    Map<String, dynamic> buddy,
    List<Map<String, dynamic>> comments,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('All comments with ${buddy['name']}',
                  style: AppTypography.headline(18)),
              const SizedBox(height: 12),
              ...comments.map((comment) {
                final commentId = comment['id'] as String? ?? '';
                final authorId = comment['authorId'];
                final currentUserId =
                    Provider.of<UserProvider>(context, listen: false).userId;
                final authorAvatarUrl = authorId == currentUserId
                    ? Provider.of<UserProvider>(context, listen: false)
                        .profilePictureUrl
                    : _commentAuthorAvatars[authorId ?? ''];
                final authorName = _resolveAuthorName(
                  comment['author'] as String?,
                  authorId as String?,
                );
                final timestamp = comment['timestamp'];
                final dateText = timestamp != null && timestamp.isNotEmpty
                    ? _formatDate(_parseTimestamp(timestamp))
                    : '';
                final isCurrentUserCard = buddy['id'] == currentUserId;
                final isOwnMessage = authorId == currentUserId;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lavender.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.surfaceElevated,
                            backgroundImage: authorAvatarUrl != null
                                ? NetworkImage(authorAvatarUrl)
                                : null,
                            child: authorAvatarUrl == null
                                ? Text(
                                    authorName.isNotEmpty
                                        ? authorName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.sakuraDeep,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        authorName,
                                        style: AppTypography.body(12,
                                            weight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    UserRoleBadge(
                                      displayName: authorName,
                                      profilePictureUrl: authorAvatarUrl,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCommentText(comment['text'] as String?,
                                      comment['replyToText'] as String?),
                                  style: AppTypography.body(12),
                                ),
                                if (dateText.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    dateText,
                                    style: AppTypography.body(11,
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isCurrentUserCard || isOwnMessage) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isOwnMessage)
                              TextButton.icon(
                                onPressed: commentId.isNotEmpty
                                    ? () =>
                                        _confirmDeleteBuddyComment(commentId)
                                    : null,
                                icon: const Icon(Icons.delete, size: 16),
                                label: Text(
                                  'Delete',
                                  style:
                                      AppTypography.body(12, color: Colors.red),
                                ),
                              ),
                            if (isCurrentUserCard) ...[
                              if (isOwnMessage) const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  final threadRecipientId =
                                      buddy['id'] as String?;
                                  if (authorId != null &&
                                      threadRecipientId != null) {
                                    _showReplyCommentSheet(
                                      threadRecipientId,
                                      authorName,
                                      comment['text'] ?? '',
                                    );
                                  }
                                },
                                icon: const Icon(Icons.reply, size: 16),
                                label: Text(
                                  'Reply',
                                  style: AppTypography.body(12,
                                      color: AppColors.sky),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic>? _latestSharedMoment() {
    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).userId;
    if (currentUserId == null) return null;

    for (final post in _communityPosts) {
      if (post['user_id'] == currentUserId) return post;
    }
    return null;
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  List<Map<String, dynamic>> _getBuddyComments(String buddyId) {
    return _buddyComments[buddyId] ?? [];
  }

  List<Map<String, dynamic>> _sortedWeatherBuddies() {
    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).userId;
    final sorted = List<Map<String, dynamic>>.from(_weatherBuddies);

    sorted.sort((a, b) {
      if (a['id'] == currentUserId && b['id'] != currentUserId) {
        return -1;
      }
      if (b['id'] == currentUserId && a['id'] != currentUserId) {
        return 1;
      }

      final aComments = _buddyComments[a['id'] as String? ?? ''] ?? [];
      final bComments = _buddyComments[b['id'] as String? ?? ''] ?? [];
      final aLatest = aComments.isNotEmpty
          ? _parseTimestamp(aComments.first['timestamp'])
          : DateTime.fromMillisecondsSinceEpoch(0);
      final bLatest = bComments.isNotEmpty
          ? _parseTimestamp(bComments.first['timestamp'])
          : DateTime.fromMillisecondsSinceEpoch(0);

      final timestampCompare = bLatest.compareTo(aLatest);
      if (timestampCompare != 0) return timestampCompare;

      final nameA = (a['name'] as String?) ?? '';
      final nameB = (b['name'] as String?) ?? '';
      return nameA.compareTo(nameB);
    });

    return sorted.take(3).toList();
  }

  Future<void> _confirmDeleteCommunityPost(String postId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _supabaseService.deleteCommunityPost(postId);
    } catch (e) {
      debugPrint('Failed to delete community post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to delete post. Please try again.')),
        );
      }
    }
  }

  List<String> _getWeatherBasedActivities(String weatherCondition) {
    switch (weatherCondition) {
      case 'clear':
        return [
          '🏖️ Beach day',
          '🧺 Picnic in the park',
          '🚶 Outdoor walk',
          '📸 Photography',
          '🎾 Outdoor sports',
        ];
      case 'rain':
      case 'drizzle':
        return [
          '☕ Cozy café visit',
          '📚 Book club meetup',
          '🎨 Indoor painting',
          '🎬 Movie marathon',
          '🍳 Cooking together',
        ];
      case 'snow':
        return [
          '⛷️ Skiing trip',
          '☕ Hot chocolate date',
          '🏠 Indoor game night',
          '❄️ Building snowman',
          '📖 Reading by fireplace',
        ];
      case 'clouds':
        return [
          '🌳 Park visit',
          '🏛️ Museum trip',
          '☕ Café hopping',
          '🛍️ Shopping',
          '📸 Urban photography',
        ];
      default:
        return [
          '☕ Coffee meet',
          '🚶 Casual walk',
          '📚 Study session',
          '🎮 Gaming night',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingAvatarOverlay(
      initialMessage: 'Halo! 👋 Welcome to Weatherboo!',
      initiallyVisible: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(decoration: AppTheme.appBarGradient),
          title: Text('Social & Community', style: AppTypography.headline(20)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: KawaiiBackground(
          child: ResponsiveCenter(
            padding: const EdgeInsets.fromLTRB(16, 250, 16, 16),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppColors.sakuraDeep),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: AppTypography.headline(20),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTypography.body(14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentWeather == null) {
      return Center(
        child: Text(
          'No weather data available',
          style: AppTypography.body(16),
        ),
      );
    }

    final temp = _currentWeather!['main']['temp'] as double;
    final weatherMain = _currentWeather!['weather'][0]['main'] as String;
    final weatherCondition = _getWeatherCondition(weatherMain);

    final activities = _getWeatherBasedActivities(weatherCondition);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeatherHeader(temp, weatherMain),
          const SizedBox(height: 24),
          _buildOnlineUsersRow(),
          const SizedBox(height: 24),
          _buildWeatherSharingCard(),
          const SizedBox(height: 20),
          _buildCommunityVibesCard(),
          const SizedBox(height: 20),
          _buildWeatherBuddyCard(activities),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWeatherHeader(double temp, String weatherMain) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;
    final temperatureUnit = profile?['temperature_unit'] ?? 'Celsius';
    final displayTemp = temperatureUnit == 'Fahrenheit'
        ? (temp * 9 / 5 + 32).round()
        : temp.round();
    final tempUnit = temperatureUnit == 'Fahrenheit' ? '°F' : '°C';

    return Card(
      elevation: 4,
      color: Colors.black.withValues(alpha: 0.7),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.sakura.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.sakura.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _getWeatherIcon(weatherMain),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentCity,
                    style: AppTypography.headline(18, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$displayTemp$tempUnit • ${weatherMain[0].toUpperCase()}${weatherMain.substring(1)}',
                    style: AppTypography.body(14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineUsersRow() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.wifi, size: 28, color: AppColors.mint),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Online Weather Buddies',
                        style: AppTypography.headline(18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Everyone online right now',
                        style:
                            AppTypography.body(13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (_weatherBuddies.isEmpty)
              Center(
                child: Text(
                  'No online buddies available yet.',
                  style: AppTypography.body(14, color: AppColors.textMuted),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _weatherBuddies.map((buddy) {
                    final status = buddy['status'] as String? ?? 'Online';
                    final avatarUrl = buddy['avatarUrl'] as String?;
                    final name = buddy['name'] as String? ?? 'Buddy';
                    final statusColor = status.toLowerCase() == 'online'
                        ? AppColors.mint
                        : AppColors.textMuted;

                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.surfaceElevated,
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null
                                ? Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : 'W',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.sakuraDeep,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 72,
                            child: Text(
                              name,
                              style: AppTypography.body(12),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status,
                            style: AppTypography.body(11, color: statusColor),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'thunderstorm':
        return '⛈️';
      case 'drizzle':
        return '🌦️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  String _currentUserDisplayName() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final displayName = userProvider.userProfile?['display_name'] as String?;
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final email = userProvider.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Weatherboo user';
  }

  String _resolveAuthorName(String? authorName, String? authorId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.userId;
    if (authorId != null && authorId == currentUserId) {
      return _currentUserDisplayName();
    }

    if (authorName != null && authorName.isNotEmpty && authorName != 'You') {
      return authorName;
    }

    return 'Weatherboo user';
  }

  Widget _buildWeatherSharingCard() {
    final latestUserPost = _latestSharedMoment();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.sakura.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.share_outlined,
                      size: 28, color: AppColors.sakura),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wholesome Weather Sharing',
                        style: AppTypography.headline(18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Share cute weather moments with friends',
                        style:
                            AppTypography.body(13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            TextField(
              controller: _momentController,
              decoration: InputDecoration(
                hintText: 'Share your weather moment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _shareMoment,
              icon: const Icon(Icons.send),
              label: const Text('Share Moment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sakura,
                foregroundColor: Colors.white,
              ),
            ),
            if (latestUserPost != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Your Latest Shared Moment',
                style: AppTypography.headline(16),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.sakura,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            latestUserPost['content'] as String,
                            style: AppTypography.body(14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_getWeatherIcon(latestUserPost['weather'] as String)} ${_formatDate(_parseTimestamp(latestUserPost['created_at']))}',
                            style: AppTypography.body(12,
                                color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityVibesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.sky.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.groups_outlined,
                      size: 28, color: AppColors.sky),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Vibes',
                        style: AppTypography.headline(18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'See how others enjoy the weather',
                        style:
                            AppTypography.body(13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ..._communityPosts.take(3).map((post) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.sky.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post['avatar'] as String,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _formatCommunityUsername(
                                              post['user'] as String,
                                              post['weather'] as String),
                                          style: AppTypography.body(14,
                                              weight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      UserRoleBadge(
                                        displayName: post['user'] as String,
                                        profilePictureUrl:
                                            post['avatarUrl'] as String?,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _formatDate(post['timestamp'] as DateTime),
                                    style: AppTypography.body(11,
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            if (post['user_id'] ==
                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .userId) ...[
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: AppColors.sakuraDeep,
                                tooltip: 'Delete post',
                                onPressed: () => _confirmDeleteCommunityPost(
                                    post['id'] as String),
                              ),
                            ],
                            Text(
                              '${_getWeatherIcon(post['weather'] as String)}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post['content'] as String,
                          style: AppTypography.body(14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.favorite_outlined,
                                size: 16, color: AppColors.sakura),
                            const SizedBox(width: 4),
                            Text(
                              '${post['likes']}',
                              style: AppTypography.body(12,
                                  color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherBuddyCard(List<String> activities) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lavender.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.diversity_3_outlined,
                      size: 28, color: AppColors.lavender),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather Buddy System',
                        style: AppTypography.headline(18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connect for weather-based activities',
                        style:
                            AppTypography.body(13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Suggested Activities Today',
              style: AppTypography.headline(16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activities
                  .map((activity) => Chip(
                        label: Text(
                          activity,
                          style: AppTypography.body(12),
                        ),
                        backgroundColor:
                            AppColors.lavender.withValues(alpha: 0.15),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Weather Buddies',
              style: AppTypography.headline(16),
            ),
            const SizedBox(height: 12),
            ..._sortedWeatherBuddies().map((buddy) {
              final comments = _getBuddyComments(buddy['id'] as String? ?? '');
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lavender.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.surfaceElevated,
                            backgroundImage: buddy['avatarUrl'] != null
                                ? NetworkImage(buddy['avatarUrl'] as String)
                                : null,
                            child: buddy['avatarUrl'] == null
                                ? Text(
                                    (buddy['name'] as String).isNotEmpty
                                        ? (buddy['name'] as String)[0]
                                            .toUpperCase()
                                        : 'W',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.sakuraDeep,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              buddy['name'] as String,
                                              style: AppTypography.body(14,
                                                  weight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          UserRoleBadge(
                                            displayName:
                                                buddy['name'] as String,
                                            profilePictureUrl:
                                                buddy['avatarUrl'] as String?,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: buddy['status'] == 'online'
                                            ? AppColors.mint
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  buddy['activity'] as String,
                                  style: AppTypography.body(12,
                                      color: AppColors.textMuted),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: (buddy['sharedInterests']
                                          as List<String>)
                                      .map((interest) => Chip(
                                            label: Text(
                                              interest,
                                              style: AppTypography.body(10),
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 0),
                                            backgroundColor: AppColors.lavender
                                                .withValues(alpha: 0.12),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (buddy['id'] !=
                              Provider.of<UserProvider>(context, listen: false)
                                  .userId) ...[
                            TextButton.icon(
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: Text(
                                'Comment',
                                style: AppTypography.body(12),
                              ),
                              onPressed: () => _showBuddyCommentSheet(buddy),
                            ),
                            if (comments.isNotEmpty) ...[
                              const SizedBox(width: 12),
                            ],
                          ],
                          if (comments.isNotEmpty)
                            Text(
                              '${comments.length} comment${comments.length > 1 ? 's' : ''}',
                              style: AppTypography.body(12,
                                  color: AppColors.textMuted),
                            ),
                        ],
                      ),
                      if (comments.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...comments.take(1).map((comment) {
                          final commentId = comment['id'] as String? ?? '';
                          final authorId = comment['authorId'];
                          final currentUserId =
                              Provider.of<UserProvider>(context, listen: false)
                                  .userId;
                          final authorAvatarUrl = authorId == currentUserId
                              ? Provider.of<UserProvider>(context,
                                      listen: false)
                                  .profilePictureUrl
                              : _commentAuthorAvatars[authorId ?? ''];
                          final authorName = _resolveAuthorName(
                            comment['author'] as String?,
                            authorId as String?,
                          );
                          final timestamp = comment['timestamp'];
                          final dateText =
                              timestamp != null && timestamp.isNotEmpty
                                  ? _formatDate(_parseTimestamp(timestamp))
                                  : '';
                          final isCurrentUserCard =
                              buddy['id'] == currentUserId;
                          final isOwnMessage = authorId == currentUserId;

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.lavender.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          AppColors.surfaceElevated,
                                      backgroundImage: authorAvatarUrl != null
                                          ? NetworkImage(authorAvatarUrl)
                                          : null,
                                      child: authorAvatarUrl == null
                                          ? Text(
                                              authorName.isNotEmpty
                                                  ? authorName[0].toUpperCase()
                                                  : 'U',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.sakuraDeep,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  authorName,
                                                  style: AppTypography.body(12,
                                                      weight: FontWeight.w600),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              UserRoleBadge(
                                                displayName: authorName,
                                                profilePictureUrl:
                                                    authorAvatarUrl,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatCommentText(
                                                comment['text'] as String?,
                                                comment['replyToText']
                                                    as String?),
                                            style: AppTypography.body(12),
                                          ),
                                          if (dateText.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              dateText,
                                              style: AppTypography.body(11,
                                                  color: AppColors.textMuted),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (isCurrentUserCard || isOwnMessage) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isOwnMessage)
                                        TextButton.icon(
                                          onPressed: commentId.isNotEmpty
                                              ? () =>
                                                  _confirmDeleteBuddyComment(
                                                      commentId)
                                              : null,
                                          icon: const Icon(Icons.delete,
                                              size: 16),
                                          label: Text(
                                            'Delete',
                                            style: AppTypography.body(12,
                                                color: Colors.red),
                                          ),
                                        ),
                                      if (isCurrentUserCard) ...[
                                        if (isOwnMessage)
                                          const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () {
                                            final threadRecipientId =
                                                buddy['id'] as String?;
                                            if (authorId != null &&
                                                threadRecipientId != null) {
                                              _showReplyCommentSheet(
                                                threadRecipientId,
                                                authorName,
                                                comment['text'] ?? '',
                                              );
                                            }
                                          },
                                          icon:
                                              const Icon(Icons.reply, size: 16),
                                          label: Text(
                                            'Reply',
                                            style: AppTypography.body(12,
                                                color: AppColors.sky),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                        if (comments.length > 1)
                          TextButton(
                            onPressed: () =>
                                _showAllBuddyCommentsSheet(buddy, comments),
                            child: Text(
                              'View all comments',
                              style:
                                  AppTypography.body(12, color: AppColors.sky),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
