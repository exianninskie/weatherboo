import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/behind_the_boo_screen.dart';
import 'screens/creators_corner_screen.dart';
import 'screens/outfit_lifestyle_screen.dart';
import 'screens/mood_motivation_screen.dart';
import 'screens/social_community_screen.dart';
import 'screens/selfcare_wellness_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/merchandise_screen.dart';
import 'screens/weatherboo_merchandise_screen.dart';
import 'providers/user_provider.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const WeatherbooApp());
}

class WeatherbooApp extends StatelessWidget {
  const WeatherbooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Weatherboo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.kawaii,
        initialRoute: Routes.login,
        routes: {
          Routes.login: (context) => const LoginScreen(),
          Routes.signup: (context) => const SignupScreen(),
          Routes.home: (context) => const HomeScreen(),
          Routes.profile: (context) => const ProfileScreen(),
          Routes.behindTheBoo: (context) => const BehindTheBooScreen(),
          Routes.creatorsCorner: (context) => const CreatorsCornerScreen(),
          Routes.outfitLifestyle: (context) => const OutfitLifestyleScreen(),
          Routes.moodMotivation: (context) => const MoodMotivationScreen(),
          Routes.socialCommunity: (context) => const SocialCommunityScreen(),
          Routes.selfCareWellness: (context) => const SelfCareWellnessScreen(),
          Routes.subscription: (context) => const SubscriptionScreen(),
          Routes.merchandise: (context) => const MerchandiseScreen(),
          Routes.weatherbooMerchandise: (context) =>
              const WeatherbooMerchandiseScreen(),
        },
      ),
    );
  }
}
