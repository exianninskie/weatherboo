import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';

class MerchandiseScreen extends StatelessWidget {
  const MerchandiseScreen({super.key});

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
                  _buildFeatureCard(
                    icon: Icons.palette_outlined,
                    title: 'Seasonal Collections',
                    subtitle:
                        'Handpicked designs inspired by sunny, rainy, and cozy weather moods.',
                    color: AppColors.sakura,
                    items: const [
                      'Soft pastel tees with weather-themed motifs.',
                      'Cozy hoodies and beanies for cool, misty mornings.',
                      'Limited-run tote bags and stickers for everyday joy.',
                    ],
                    actionLabel: 'Browse Collection',
                    onActionTap: () {
                      Navigator.pushNamed(
                          context, Routes.weatherbooMerchandise);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    icon: Icons.local_offer_outlined,
                    title: 'Exclusive Drops',
                    subtitle:
                        'Special merchandise releases for Weatherboo members.',
                    color: AppColors.lavender,
                    items: const [
                      'Early access to capsule collections for subscribers.',
                      'Seasonal bundles with limited edition packaging.',
                      'Weatherboo gift items perfect for friends and yourself.',
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<String> items,
    String? actionLabel,
    VoidCallback? onActionTap,
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
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: color),
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
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item, style: AppTypography.body(14)),
                    ),
                  ],
                ),
              ),
            ),
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onActionTap,
                  child: Text(actionLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
