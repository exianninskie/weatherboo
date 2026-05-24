import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../services/weather_service.dart';
import '../widgets/responsive_center.dart';
import 'outfit_lifestyle_screen.dart';
import 'mood_motivation_screen.dart';
import 'social_community_screen.dart';
import 'selfcare_wellness_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecast;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentCity = 'New York';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
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
      final forecast = await _weatherService.get5DayForecast(targetCity);

      if (mounted) {
        setState(() {
          _currentWeather = currentWeather;
          _forecast = forecast;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getWeatherIcon(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(decoration: AppTheme.appBarGradient),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onSelected: (value) {
              switch (value) {
                case 'outfit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OutfitLifestyleScreen()),
                  );
                  break;
                case 'mood':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MoodMotivationScreen()),
                  );
                  break;
                case 'social':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SocialCommunityScreen()),
                  );
                  break;
                case 'selfcare':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SelfCareWellnessScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'outfit',
                child: Row(
                  children: [
                    Icon(Icons.checkroom_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Outfit & Lifestyle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mood',
                child: Row(
                  children: [
                    Icon(Icons.psychology_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Mood & Motivation'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'social',
                child: Row(
                  children: [
                    Icon(Icons.people_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Social & Community'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'selfcare',
                child: Row(
                  children: [
                    Icon(Icons.self_improvement_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Self-Care & Wellness'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: KawaiiBackground(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final profile = userProvider.userProfile;
            final temperatureUnit = profile?['temperature_unit'] ?? 'Celsius';

            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.sakuraDeep),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load weather',
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
                      onPressed: _loadWeather,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ResponsiveCenter(
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _loadWeather,
                                  child: Text(
                                    'Refresh',
                                    style: AppTypography.label(12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        _buildTodayWeatherCard(temperatureUnit),
                        const SizedBox(height: 32),
                        Text(
                          'Weekly Forecast',
                          style: AppTypography.headline(20, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        _buildWeeklyForecast(temperatureUnit),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTodayWeatherCard(String temperatureUnit) {
    if (_currentWeather == null) return const SizedBox();

    final temp = _currentWeather!['main']['temp'];
    final feelsLike = _currentWeather!['main']['feels_like'];
    final humidity = _currentWeather!['main']['humidity'];
    final windSpeed = _currentWeather!['wind']['speed'];
    final weatherMain = _currentWeather!['weather'][0]['main'];
    final weatherDescription = _currentWeather!['weather'][0]['description'];

    final displayTemp = temperatureUnit == 'Fahrenheit' ? (temp * 9/5 + 32).round() : temp.round();
    final displayFeelsLike = temperatureUnit == 'Fahrenheit' ? (feelsLike * 9/5 + 32).round() : feelsLike.round();
    final tempUnit = temperatureUnit == 'Fahrenheit' ? '°F' : '°C';

    return Card(
      elevation: 4,
      color: Colors.black.withValues(alpha: 0.7),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Today',
              style: AppTypography.body(14, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _currentCity,
              style: AppTypography.headline(24, color: Colors.white),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
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
                  style: const TextStyle(fontSize: 56),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$displayTemp$tempUnit',
              style: AppTypography.headline(56, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              weatherDescription[0].toUpperCase() + weatherDescription.substring(1),
              style: AppTypography.body(16, color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  icon: Icons.thermostat,
                  label: 'Feels Like',
                  value: '$displayFeelsLike°',
                ),
                _buildWeatherDetail(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '$humidity%',
                ),
                _buildWeatherDetail(
                  icon: Icons.air,
                  label: 'Wind',
                  value: '${windSpeed.toStringAsFixed(1)} m/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.label(12, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.body(14, weight: FontWeight.w600, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildWeeklyForecast(String temperatureUnit) {
    if (_forecast == null) return const SizedBox();

    final list = _forecast!['list'] as List;
    final dailyForecasts = <Map<String, dynamic>>[];

    for (var item in list) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dateStr = '${date.day}/${date.month}';
      
      if (!dailyForecasts.any((f) => f['dateStr'] == dateStr)) {
        dailyForecasts.add({
          'dateStr': dateStr,
          'day': _getDayName(date),
          'temp': item['main']['temp'],
          'weather': item['weather'][0]['main'],
        });
      }
      
      if (dailyForecasts.length >= 7) break;
    }

    final tempUnit = temperatureUnit == 'Fahrenheit' ? '°F' : '°C';

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dailyForecasts.length,
        itemBuilder: (context, index) {
          final forecast = dailyForecasts[index];
          final temp = forecast['temp'];
          final displayTemp = temperatureUnit == 'Fahrenheit' ? (temp * 9/5 + 32).round() : temp.round();

          return Card(
            elevation: 2,
            color: Colors.black.withValues(alpha: 0.7),
            margin: EdgeInsets.only(
              right: index < dailyForecasts.length - 1 ? 12 : 0,
            ),
            child: Container(
              width: 100,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    forecast['day'],
                    style: AppTypography.label(14, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getWeatherIcon(forecast['weather']),
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$displayTemp$tempUnit',
                    style: AppTypography.body(16, weight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final dayAfterTomorrow = now.add(const Duration(days: 2));

    if (date.day == now.day && date.month == now.month) {
      return 'Today';
    } else if (date.day == tomorrow.day && date.month == tomorrow.month) {
      return 'Tomorrow';
    } else if (date.day == dayAfterTomorrow.day && date.month == dayAfterTomorrow.month) {
      return 'In 2 days';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
