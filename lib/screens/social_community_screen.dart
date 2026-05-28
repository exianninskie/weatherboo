import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../services/weather_service.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';

class SocialCommunityScreen extends StatefulWidget {
  const SocialCommunityScreen({super.key});

  @override
  State<SocialCommunityScreen> createState() => _SocialCommunityScreenState();
}

class _SocialCommunityScreenState extends State<SocialCommunityScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _currentWeather;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentCity = 'New York';
  List<Map<String, dynamic>> _sharedMoments = [];
  List<Map<String, dynamic>> _communityPosts = [];
  List<Map<String, dynamic>> _weatherBuddies = [];
  final TextEditingController _momentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
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
      final currentWeather = await _weatherService.getCurrentWeather(targetCity);
      await _loadSharedMoments();
      await _loadCommunityPosts();
      await _loadWeatherBuddies();

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

  Future<void> _loadSharedMoments() async {
    final prefs = await SharedPreferences.getInstance();
    final momentsData = prefs.getStringList('shared_moments') ?? [];
    setState(() {
      _sharedMoments = momentsData.map((entry) {
        final parts = entry.split('|');
        return {
          'moment': parts[0],
          'weather': parts[1],
          'timestamp': DateTime.parse(parts[2]),
        };
      }).toList();
    });
  }

  Future<void> _loadCommunityPosts() async {
    // Simulated community posts based on weather
    final posts = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    posts.addAll([
      {
        'user': 'SunnySarah',
        'avatar': '🌸',
        'content': 'Perfect day for a picnic! The weather is absolutely lovely today!',
        'weather': 'clear',
        'likes': 24,
        'timestamp': now.subtract(const Duration(hours: 2)),
      },
      {
        'user': 'RainyRiley',
        'avatar': '🌧️',
        'content': 'Cozy coffee shop vibes while it rains outside. Best feeling ever!',
        'weather': 'rain',
        'likes': 18,
        'timestamp': now.subtract(const Duration(hours: 4)),
      },
      {
        'user': 'CloudyChris',
        'avatar': '☁️',
        'content': 'Overcast days are perfect for reading and relaxing indoors.',
        'weather': 'clouds',
        'likes': 31,
        'timestamp': now.subtract(const Duration(hours: 6)),
      },
    ]);

    setState(() {
      _communityPosts = posts;
    });
  }

  Future<void> _loadWeatherBuddies() async {
    // Simulated weather buddies
    final buddies = <Map<String, dynamic>>[];
    
    buddies.addAll([
      {
        'name': 'Alex',
        'avatar': '🎨',
        'activity': 'Indoor painting sessions on rainy days',
        'status': 'online',
        'sharedInterests': ['Art', 'Coffee', 'Reading'],
      },
      {
        'name': 'Jordan',
        'avatar': '🏃',
        'activity': 'Morning jogs when it\'s sunny',
        'status': 'away',
        'sharedInterests': ['Fitness', 'Nature', 'Photography'],
      },
      {
        'name': 'Taylor',
        'avatar': '📚',
        'activity': 'Book club meetups on cloudy days',
        'status': 'online',
        'sharedInterests': ['Books', 'Tea', 'Writing'],
      },
    ]);

    setState(() {
      _weatherBuddies = buddies;
    });
  }

  Future<void> _shareMoment() async {
    if (_momentController.text.trim().isEmpty) return;

    final weatherMain = _currentWeather?['weather'][0]['main'] as String? ?? 'clear';
    final momentText = _momentController.text.trim();
    final entry = '$momentText|$weatherMain|${DateTime.now().toIso8601String()}';
    
    final prefs = await SharedPreferences.getInstance();
    final momentsData = prefs.getStringList('shared_moments') ?? [];
    momentsData.add(entry);
    
    // Keep only last 20 entries
    if (momentsData.length > 20) {
      momentsData.removeAt(0);
    }
    
    await prefs.setStringList('shared_moments', momentsData);
    
    // Add to community posts at the top (newest)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    final userName = profile?['username'] ?? 'You';
    
    final newPost = {
      'user': userName,
      'avatar': '🌟',
      'content': momentText,
      'weather': weatherMain,
      'likes': 0,
      'timestamp': DateTime.now(),
    };
    
    setState(() {
      _communityPosts.insert(0, newPost);
    });
    
    _momentController.clear();
    await _loadSharedMoments();
  }

  String _getWeatherCondition(String? weatherMain) {
    if (weatherMain == null) return 'clear';

    final condition = weatherMain.toLowerCase();
    final conditionMapping = {
      'clear sky': 'clear', 'clear': 'clear',
      'few clouds': 'clouds', 'scattered clouds': 'clouds', 'broken clouds': 'clouds',
      'overcast clouds': 'clouds', 'clouds': 'clouds', 'cloud': 'clouds',
      'light rain': 'rain', 'moderate rain': 'rain', 'heavy intensity rain': 'rain',
      'very heavy rain': 'rain', 'extreme rain': 'rain', 'freezing rain': 'rain',
      'light intensity shower rain': 'rain', 'shower rain': 'rain',
      'heavy intensity shower rain': 'rain', 'ragged shower rain': 'rain', 'rain': 'rain',
      'light intensity drizzle': 'drizzle', 'drizzle': 'drizzle',
      'heavy intensity drizzle': 'drizzle', 'light intensity drizzle rain': 'drizzle',
      'drizzle rain': 'drizzle', 'heavy intensity drizzle rain': 'drizzle',
      'shower rain and drizzle': 'drizzle', 'heavy shower rain and drizzle': 'drizzle',
      'shower drizzle': 'drizzle',
      'thunderstorm with light rain': 'thunderstorm', 'thunderstorm with rain': 'thunderstorm',
      'thunderstorm with heavy rain': 'thunderstorm', 'light thunderstorm': 'thunderstorm',
      'heavy thunderstorm': 'thunderstorm', 'ragged thunderstorm': 'thunderstorm',
      'thunderstorm with light drizzle': 'thunderstorm', 'thunderstorm with drizzle': 'thunderstorm',
      'thunderstorm with heavy drizzle': 'thunderstorm', 'thunderstorm': 'thunderstorm',
      'light snow': 'snow', 'heavy snow': 'snow', 'sleet': 'snow',
      'light shower sleet': 'snow', 'shower sleet': 'snow', 'rain and snow': 'snow',
      'light rain and snow': 'snow', 'light shower snow': 'snow', 'shower snow': 'snow',
      'heavy shower snow': 'snow', 'snow': 'snow',
      'mist': 'mist', 'smoke': 'mist', 'haze': 'mist', 'dust': 'mist',
      'fog': 'mist', 'sand': 'mist', 'ash': 'mist', 'squall': 'mist', 'tornado': 'mist',
    };

    return conditionMapping[condition] ?? condition;
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
            const Icon(Icons.error_outline, size: 64, color: AppColors.sakuraDeep),
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
    final displayTemp = temperatureUnit == 'Fahrenheit' ? (temp * 9/5 + 32).round() : temp.round();
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

  Widget _buildWeatherSharingCard() {
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
                  child: Icon(Icons.share_outlined, size: 28, color: AppColors.sakura),
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
                        style: AppTypography.body(13, color: AppColors.textMuted),
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
            if (_sharedMoments.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Your Shared Moments',
                style: AppTypography.headline(16),
              ),
              const SizedBox(height: 12),
              ..._sharedMoments.take(3).map((moment) => Padding(
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
                            moment['moment'] as String,
                            style: AppTypography.body(14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_getWeatherIcon(moment['weather'] as String)} ${_formatDate(moment['timestamp'] as DateTime)}',
                            style: AppTypography.body(12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
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
                  child: Icon(Icons.groups_outlined, size: 28, color: AppColors.sky),
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
                        style: AppTypography.body(13, color: AppColors.textMuted),
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
                              Text(
                                post['user'] as String,
                                style: AppTypography.body(14, weight: FontWeight.w600),
                              ),
                              Text(
                                _formatDate(post['timestamp'] as DateTime),
                                style: AppTypography.body(11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
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
                        Icon(Icons.favorite_outlined, size: 16, color: AppColors.sakura),
                        const SizedBox(width: 4),
                        Text(
                          '${post['likes']}',
                          style: AppTypography.body(12, color: AppColors.textMuted),
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
                  child: Icon(Icons.diversity_3_outlined, size: 28, color: AppColors.lavender),
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
                        style: AppTypography.body(13, color: AppColors.textMuted),
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
              children: activities.map((activity) => Chip(
                label: Text(
                  activity,
                  style: AppTypography.body(12),
                ),
                backgroundColor: AppColors.lavender.withValues(alpha: 0.15),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Weather Buddies',
              style: AppTypography.headline(16),
            ),
            const SizedBox(height: 12),
            ..._weatherBuddies.map((buddy) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      buddy['avatar'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                buddy['name'] as String,
                                style: AppTypography.body(14, weight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: buddy['status'] == 'online' ? AppColors.mint : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            buddy['activity'] as String,
                            style: AppTypography.body(12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: (buddy['sharedInterests'] as List<String>)
                                .map((interest) => Chip(
                                      label: Text(
                                        interest,
                                        style: AppTypography.body(10),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () {
                        // TODO: Implement chat functionality
                      },
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
