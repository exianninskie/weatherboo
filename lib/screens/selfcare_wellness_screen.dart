import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';

class SelfCareWellnessScreen extends StatelessWidget {
  const SelfCareWellnessScreen({super.key});

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
          title:
              Text('Self-Care & Wellness', style: AppTypography.headline(20)),
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
                          Icon(Icons.self_improvement_outlined,
                              size: 64, color: AppColors.sakura),
                          const SizedBox(height: 16),
                          Text(
                            'Self-Care & Wellness',
                            style: AppTypography.headline(24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Weather-based self-care reminders, wellness tips, and gratitude journaling.',
                            style: AppTypography.body(14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.spa_outlined,
                    title: 'Weather-Based Self-Care Reminders',
                    subtitle:
                        'Skincare, hydration, and wellness tips for today.',
                    color: AppColors.sakura,
                    items: const [
                      'Apply lightweight SPF and antioxidants on sunny days.',
                      'Boost hydration with a hydrating mist when the air is dry.',
                      'Choose warming herbal tea for cool or rainy weather.',
                    ],
                    actionLinks: const [
                      _EcommerceLink(
                        label: 'Amazon',
                        url: 'https://www.amazon.com',
                      ),
                      _EcommerceLink(
                        label: 'eBay',
                        url: 'https://www.ebay.com',
                      ),
                      _EcommerceLink(
                        label: 'Alibaba',
                        url: 'https://www.alibaba.com',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.edit_note_outlined,
                    title: 'Gratitude Journal with Weather',
                    subtitle:
                        'Journal entries with weather context for reflection.',
                    color: AppColors.lavender,
                    items: const [
                      'Note how the weather shaped your mood today.',
                      'Write one thing you enjoyed about today’s sky.',
                      'Capture a weather moment you are grateful for.',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.music_note_outlined,
                    title: 'Weather-Based Playlists',
                    subtitle: 'Music suggestions matching the weather vibe.',
                    color: AppColors.sky,
                    items: const [
                      'Sunny days: upbeat, bright songs to lift your energy.',
                      'Rainy moments: mellow, cozy playlists for calm reflection.',
                      'Cloudy afternoons: chilled indie or ambient rhythms.',
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<String> items,
    List<_EcommerceLink>? actionLinks,
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
            if (actionLinks != null && actionLinks.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: actionLinks.map(
                    (link) {
                      return SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => _openUrl(context, link.url),
                          child: Text(link.label),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open website. Please try again later.'),
      ),
    );
  }
}

class _EcommerceLink {
  const _EcommerceLink({required this.label, required this.url});

  final String label;
  final String url;
}
