import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';
import '../providers/user_provider.dart';
import 'weatherboo_merchandise_screen.dart';

class MerchandiseScreen extends StatefulWidget {
  const MerchandiseScreen({super.key});

  @override
  State<MerchandiseScreen> createState() => _MerchandiseScreenState();
}

class _MerchandiseScreenState extends State<MerchandiseScreen> {
  String _getUserSubscriptionPlan() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    return profile?['subscription_plan']?.toString().toLowerCase() ?? 'silver';
  }

  bool _isCreator() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    final displayName = profile?['display_name']?.toString().toLowerCase() ?? '';
    final email = userProvider.email?.toString().toLowerCase() ?? '';
    return displayName.contains('ninskie') || email == 'tlive4444@gmail.com';
  }

  bool _canAccessMerch(String requiredPlan) {
    final userPlan = _getUserSubscriptionPlan();
    final isCreator = _isCreator();
    
    // Creator can access all merch
    if (isCreator) return true;
    
    // Regular access based on subscription tier
    final tierHierarchy = {'platinum': 3, 'gold': 2, 'silver': 1};
    final userTier = tierHierarchy[userPlan] ?? 1;
    final requiredTier = tierHierarchy[requiredPlan] ?? 1;
    
    return userTier >= requiredTier;
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
          title: Text('Merchandise', style: AppTypography.headline(20)),
        ),
        body: KawaiiBackground(
          child: ResponsiveCenter(
            padding: const EdgeInsets.fromLTRB(16, 250, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 64, color: AppColors.sky),
                          const SizedBox(height: 16),
                          Text(
                            'Weatherboo Merchandise',
                            style: AppTypography.headline(24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Shop weather-inspired apparel, accessories, and gifts designed for your mood and the season.',
                            style: AppTypography.body(14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMerchCard(
                    icon: Icons.lock_outline,
                    title: 'Exclusive Merch',
                    subtitle: 'Premium merchandise for Platinum subscribers',
                    color: AppColors.sakura,
                    requiredPlan: 'platinum',
                    items: const [
                      'Limited-run tote bags with unique designs',
                      'Seasonal bundles with limited edition packaging',
                      'Early access to capsule collections',
                      'Weatherboo gift items perfect for friends and yourself',
                      'Premium exclusive merchandise',
                      'Special edition collectibles',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMerchCard(
                    icon: Icons.lock_outline,
                    title: 'Standard Merch',
                    subtitle: 'Quality merchandise for Gold subscribers',
                    color: AppColors.lavender,
                    requiredPlan: 'gold',
                    items: const [
                      'Weathery Tee - Soft pastel tee with weather motif',
                      'Cozy Cloud Hoodie - Perfect for cool mornings',
                      'Weather Beanies - Cozy beanies for misty weather',
                      'Soft Pastel Tees - Handpicked weather-inspired designs',
                      'Standard apparel items',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMerchCard(
                    icon: Icons.lock_outline,
                    title: 'Basic Merch',
                    subtitle: 'Essential merchandise for Silver subscribers',
                    color: AppColors.sky,
                    requiredPlan: 'silver',
                    items: const [
                      'Sky Tote - Sunny tote bag for weather journal',
                      'Weather-themed stickers',
                      'Standard tote bags with weather motifs',
                      'Basic weather accessories',
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMerchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String requiredPlan,
    required List<String> items,
  }) {
    final canAccess = _canAccessMerch(requiredPlan);
    final isCreator = _isCreator();

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
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(canAccess ? Icons.lock_open : icon, size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.headline(18)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: AppTypography.body(13,
                              color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: canAccess ? color : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTypography.body(14,
                            color: canAccess ? null : AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAccess
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeatherbooMerchandiseScreen(
                              subscriptionTier: requiredPlan,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAccess ? color : AppColors.textMuted,
                  disabledBackgroundColor: AppColors.textMuted,
                ),
                child: Text(
                  canAccess ? 'Browse Collection' : 'Locked',
                  style: TextStyle(
                    color: canAccess ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
            if (isCreator && requiredPlan == 'platinum') ...[
              const SizedBox(height: 8),
              Text(
                'Creator Access',
                style: AppTypography.body(11, color: AppColors.sakura),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
