import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../services/weather_service.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';

class MoodMotivationScreen extends StatefulWidget {
  const MoodMotivationScreen({super.key});

  @override
  State<MoodMotivationScreen> createState() => _MoodMotivationScreenState();
}

class _MoodMotivationScreenState extends State<MoodMotivationScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _currentWeather;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentCity = 'New York';
  String? _dailyQuote;
  List<Map<String, dynamic>> _moodHistory = [];
  int? _selectedMood;
  List<String> _completedRoutineItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
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
      await _loadMoodHistory();
      await _loadDailyQuote();
      await _loadRoutineProgress();

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

  Future<void> _loadMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final moodData = prefs.getStringList('mood_history') ?? [];
    setState(() {
      _moodHistory = moodData.map((entry) {
        final parts = entry.split('|');
        return {
          'mood': int.parse(parts[0]),
          'weather': parts[1],
          'timestamp': DateTime.parse(parts[2]),
        };
      }).toList();
    });
  }

  Future<void> _loadDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastQuoteDate = prefs.getString('last_quote_date');
    final storedQuote = prefs.getString('daily_quote');

    if (lastQuoteDate != today.toIso8601String().split('T')[0] ||
        storedQuote == null) {
      final quotes = _getMotivationalQuotes();
      final randomQuote = quotes[today.day % quotes.length];
      await prefs.setString('daily_quote', randomQuote);
      await prefs.setString(
          'last_quote_date', today.toIso8601String().split('T')[0]);
      setState(() {
        _dailyQuote = randomQuote;
      });
    } else {
      setState(() {
        _dailyQuote = storedQuote;
      });
    }
  }

  Future<void> _loadRoutineProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final completedItems = prefs.getStringList('routine_$today') ?? [];
    setState(() {
      _completedRoutineItems = completedItems;
    });
  }

  Future<void> _saveMood(int moodValue) async {
    final prefs = await SharedPreferences.getInstance();
    final weatherMain =
        _currentWeather?['weather'][0]['main'] as String? ?? 'clear';
    final entry = '$moodValue|$weatherMain|${DateTime.now().toIso8601String()}';

    final moodData = prefs.getStringList('mood_history') ?? [];
    moodData.add(entry);

    // Keep only last 30 entries
    if (moodData.length > 30) {
      moodData.removeAt(0);
    }

    await prefs.setStringList('mood_history', moodData);
    await _loadMoodHistory();

    setState(() {
      _selectedMood = moodValue;
    });
  }

  Future<void> _toggleRoutineItem(String item) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final completedItems = prefs.getStringList('routine_$today') ?? [];

    if (completedItems.contains(item)) {
      completedItems.remove(item);
    } else {
      completedItems.add(item);
    }

    await prefs.setStringList('routine_$today', completedItems);
    setState(() {
      _completedRoutineItems = completedItems;
    });
  }

  String _getTemperatureRange(double tempCelsius) {
    if (tempCelsius < 5) return 'cold';
    if (tempCelsius < 15) return 'cool';
    if (tempCelsius < 25) return 'mild';
    return 'hot';
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

  List<String> _getMotivationalQuotes() {
    return [
      "Every day is a new beginning. Take a deep breath and start again.",
      "You are capable of amazing things. Believe in yourself!",
      "Small steps lead to big changes. Keep moving forward.",
      "Your potential is endless. Go out there and shine!",
      "Today is a gift. Make the most of every moment.",
      "You are stronger than you think. Keep pushing forward.",
      "Embrace the journey, not just the destination.",
      "Your attitude determines your direction. Stay positive!",
      "Success is not final, failure is not fatal. Keep going!",
      "You have the power to change your story. Start today!",
      "Be the energy you want to attract. Spread positivity!",
      "Every challenge is an opportunity in disguise. Seize it!",
      "Your mindset shapes your reality. Think big!",
      "Progress, not perfection. Celebrate every win!",
      "You are worthy of happiness and success. Claim it!",
    ];
  }

  List<String> _getWeatherAffirmations(String weatherCondition) {
    switch (weatherCondition) {
      case 'clear':
        return [
          "☀️ The sun is shining, and so are you!",
          "☀️ Today is your day to radiate positivity!",
          "☀️ Let the sunshine fill your heart with joy!",
          "☀️ Bright days ahead for a bright soul like you!",
          "☀️ You glow like the morning sun!",
        ];
      case 'clouds':
        return [
          "☁️ Even cloudy days have silver linings.",
          "☁️ Find peace in the calm of overcast skies.",
          "☁️ Your inner light shines through any clouds.",
          "☁️ Clouds pass, but your strength remains.",
          "☁️ Embrace the cozy comfort of cloudy days.",
        ];
      case 'rain':
        return [
          "🌧️ Rain washes away the old to make way for the new.",
          "🌧️ Growth happens in the rain. You're blooming!",
          "🌧️ Let the rain nourish your soul and spirit.",
          "🌧️ After rain comes the rainbow. Stay hopeful!",
          "🌧️ You weather any storm with grace.",
        ];
      case 'snow':
        return [
          "❄️ Like snowflakes, you are unique and beautiful.",
          "❄️ Fresh starts fall softly like snow.",
          "❄️ Your potential is as limitless as snowfall.",
          "❄️ Find beauty in life's quiet moments.",
          "❄️ You bring warmth to the coldest days.",
        ];
      case 'thunderstorm':
        return [
          "⛈️ Your strength is louder than any thunder.",
          "⛈️ Weather the storm and emerge stronger.",
          "⛈️ Even the darkest storms pass. You've got this!",
          "⛈️ Lightning strikes of inspiration await you.",
          "⛈️ You are unshakeable in any storm.",
        ];
      case 'mist':
        return [
          "🌫️ Find clarity within when the world is foggy.",
          "🌫️ Your vision cuts through any mist.",
          "🌫️ Mystery and magic await in the mist.",
          "🌫️ Navigate uncertainty with confidence.",
          "🌫️ Your inner compass always guides you true.",
        ];
      default:
        return [
          "🌤️ Whatever the weather, you weather it well!",
          "🌤️ Adaptability is your superpower.",
          "🌤️ Find beauty in every kind of day.",
          "🌤️ You thrive in any condition.",
          "🌤️ The weather changes, but your worth doesn't.",
        ];
    }
  }

  List<String> _getMorningRoutine(String tempRange, String weatherCondition) {
    final routine = <String>[];

    // Universal morning items
    routine.addAll([
      '🌅 Wake up with gratitude',
      '💧 Drink a glass of water',
      '🧘 Stretch or meditate for 5 minutes',
    ]);

    // Weather-specific additions
    switch (weatherCondition) {
      case 'clear':
        routine.addAll([
          '☀️ Get 10 minutes of sunlight',
          '🚶 Take a morning walk outside',
        ]);
        break;
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        routine.addAll([
          '☕ Enjoy a warm beverage indoors',
          '📚 Read something inspiring',
          '🎵 Listen to uplifting music',
        ]);
        break;
      case 'snow':
        routine.addAll([
          '🧣 Dress warmly before going out',
          '☕ Start with a hot drink',
          '🏠 Create a cozy morning space',
        ]);
        break;
      case 'clouds':
        routine.addAll([
          '🌤️ Open curtains for natural light',
          '📝 Write down 3 things you\'re grateful for',
        ]);
        break;
      case 'mist':
        routine.addAll([
          '🧘 Practice mindfulness',
          '📖 Read something calming',
        ]);
        break;
    }

    // Temperature-based additions
    switch (tempRange) {
      case 'cold':
      case 'cool':
        routine.add('🧣 Layer up for comfort');
        break;
      case 'hot':
        routine.add('🧴 Apply sunscreen if heading out');
        break;
    }

    return routine;
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
          title: Text('Mood & Motivation', style: AppTypography.headline(20)),
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
    final tempRange = _getTemperatureRange(temp);
    final weatherCondition = _getWeatherCondition(weatherMain);

    final weatherAffirmations = _getWeatherAffirmations(weatherCondition);
    final morningRoutine = _getMorningRoutine(tempRange, weatherCondition);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeatherHeader(temp, weatherMain),
          const SizedBox(height: 24),
          _buildDailyHypeCard(),
          const SizedBox(height: 20),
          _buildWeatherAffirmationCard(weatherAffirmations),
          const SizedBox(height: 20),
          _buildMoodTrackerCard(),
          const SizedBox(height: 20),
          _buildMorningRoutineCard(morningRoutine),
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

  Widget _buildDailyHypeCard() {
    return _buildFeatureCard(
      icon: Icons.auto_awesome_outlined,
      title: 'Daily Hype Message',
      subtitle: 'Your personalized motivation for today',
      color: AppColors.sakura,
      content: _dailyQuote ?? 'Loading your daily inspiration...',
      isQuote: true,
      shareText: _dailyQuote ?? 'Loading your daily inspiration...',
    );
  }

  Widget _buildWeatherAffirmationCard(List<String> affirmations) {
    final randomAffirmation =
        affirmations[DateTime.now().day % affirmations.length];
    return _buildFeatureCard(
      icon: Icons.wb_sunny_outlined,
      title: 'Weather Affirmation',
      subtitle: 'Positive energy for today\'s weather',
      color: AppColors.sky,
      content: randomAffirmation,
      isQuote: true,
      shareText: randomAffirmation,
    );
  }

  Widget _buildMoodTrackerCard() {
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
                  child: Icon(Icons.sentiment_satisfied_alt_outlined,
                      size: 28, color: AppColors.lavender),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood Tracker',
                        style: AppTypography.headline(18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'How are you feeling today?',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodButton(1, '😢', AppColors.sakuraDeep),
                _buildMoodButton(2, '😕', Colors.orange),
                _buildMoodButton(3, '😐', Colors.yellow),
                _buildMoodButton(4, '🙂', AppColors.sky),
                _buildMoodButton(5, '😄', AppColors.sakura),
              ],
            ),
            if (_moodHistory.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recent moods: ${_moodHistory.length} entries',
                style: AppTypography.body(12, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(int value, String emoji, Color color) {
    final isSelected = _selectedMood == value;
    return GestureDetector(
      onTap: () => _saveMood(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  Widget _buildMorningRoutineCard(List<String> routineItems) {
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
                  child: Icon(Icons.wb_twilight_outlined,
                      size: 28, color: AppColors.mint),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morning Routine',
                        style: AppTypography.headline(18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Weather-aware checklist for today',
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
            ...routineItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _toggleRoutineItem(item),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _completedRoutineItems.contains(item)
                                ? AppColors.mint
                                : Colors.transparent,
                            border: Border.all(
                              color: _completedRoutineItems.contains(item)
                                  ? AppColors.mint
                                  : Colors.grey.withValues(alpha: 0.4),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _completedRoutineItems.contains(item)
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTypography.body(
                              14,
                              color: _completedRoutineItems.contains(item)
                                  ? Colors.grey
                                  : null,
                            ).copyWith(
                              decoration: _completedRoutineItems.contains(item)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
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

  String _appendWatermark(String text) {
    return '$text\n\nshared with love by Weatherboo';
  }

  Future<void> _shareToPlatform(String platform, String message) async {
    final text = _appendWatermark(message);
    if (!mounted) return;

    switch (platform) {
      case 'x':
        final encodedText = Uri.encodeComponent(text);
        final urls = [
          Uri.parse('twitter://post?message=$encodedText'),
          Uri.parse('https://x.com/intent/tweet?text=$encodedText'),
          Uri.parse('https://twitter.com/intent/tweet?text=$encodedText'),
        ];

        for (final uri in urls) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Unable to open X. Please install the app or try again later.')),
        );
        break;
      case 'instagram':
        final clipboardData = ClipboardData(text: text);
        await Clipboard.setData(clipboardData);
        final uri = Uri.parse('instagram://app');

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Message copied to clipboard. Paste it into Instagram.')),
          );
          return;
        }

        const fallbackUrl = 'https://www.instagram.com/';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(Uri.parse(fallbackUrl),
              mode: LaunchMode.externalApplication);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Instagram caption copied to clipboard. Open Instagram and paste it there.')),
        );
        break;
      default:
        break;
    }
  }

  Widget _buildShareActions(String message) {
    final userProvider = Provider.of<UserProvider>(context);
    if (!userProvider.isLoggedIn) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share to X'),
              onPressed: () => _shareToPlatform('x', message),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('Share to Instagram'),
              onPressed: () => _shareToPlatform('instagram', message),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String content,
    bool isQuote = false,
    String? shareText,
  }) {
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
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headline(18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content,
                style: AppTypography.body(15).copyWith(
                  fontStyle: isQuote ? FontStyle.italic : FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (shareText != null) _buildShareActions(shareText),
          ],
        ),
      ),
    );
  }
}
