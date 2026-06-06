import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';
import '../widgets/subscription_badges.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingAvatarOverlay(
      initialMessage: 'Halo! ?? Welcome to Weatherboo!',
      initiallyVisible: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),        
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(decoration: AppTheme.appBarGradient), 
          title: Text('Subscription', style: AppTypography.headline(20)),
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
                          Icon(Icons.subscriptions_outlined,
                              size: 64, color: AppColors.sakura),
                          const SizedBox(height: 16),
                          Text(
                            'Choose Your Weatherboo Plan',
                            style: AppTypography.headline(24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pick a plan to enjoy Weatherboo merchandise, Discord access, and creator meetups.',
                            style: AppTypography.body(14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    title: 'Platinum USD 50 (monthly)',
                    price: '',
                    color: AppColors.sakura,
                    features: const [
                      'Exclusive access to private Weatherboo Discord server',
                      'Priority selection of Weatherboo merchandise',
                      'VIP invitations to online/offline creator meetups',
                      'Early access to new features and community events',
                      'Special recognition in Weatherboo community',
                    ],
                    buttonLabel: 'Choose Platinum',
                    onButtonTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Platinum subscription selected.')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    title: 'Gold USD 30 (monthly)',
                    price: '',
                    color: AppColors.lavender,
                    features: const [
                      'Standard selection of Weatherboo merchandise',
                      'Access to Weatherboo community updates and seasonal offers',
                      'Invitations to select online community events',
                    ],
                    buttonLabel: 'Choose Gold',
                    onButtonTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gold subscription selected.')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    title: 'Silver USD 15 (monthly)',
                    price: '',
                    color: AppColors.sky,
                    features: const [
                      'Basic Weatherboo merchandise selection',
                      'Access to Weatherboo community updates',
                      'Participation in public community discussions',
                    ],
                    buttonLabel: 'Choose Silver',
                    onButtonTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Silver subscription selected.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required Color color,
    required List<String> features,
    required String buttonLabel,
    required VoidCallback onButtonTap,
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
                SubscriptionBadge(
                  plan: title.contains('Platinum')
                      ? 'Platinum'
                      : title.contains('Gold')
                          ? 'Gold'
                          : 'Silver',
                  size: 64,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.headline(18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
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
                      child: Text(feature, style: AppTypography.body(14)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonTap,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}