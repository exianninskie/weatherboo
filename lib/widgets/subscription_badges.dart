import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubscriptionBadge extends StatelessWidget {
  final String plan;
  final double size;

  const SubscriptionBadge({
    super.key,
    required this.plan,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    switch (plan.toLowerCase()) {
      case 'platinum':
        iconData = Icons.workspace_premium_outlined;
        color = AppColors.sakura;
        break;
      case 'gold':
        iconData = Icons.emoji_events_outlined;
        color = AppColors.lavender;
        break;
      case 'silver':
        iconData = Icons.star_outline;
        color = AppColors.sky;
        break;
      default:
        iconData = Icons.star_outline;
        color = AppColors.sky;
    }

    return Container(
      padding: EdgeInsets.all(size * 0.3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.5),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        iconData,
        size: size,
        color: color,
      ),
    );
  }
}

class PlatinumBadge extends StatelessWidget {
  final double size;

  const PlatinumBadge({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SubscriptionBadge(plan: 'Platinum', size: size);
  }
}

class GoldBadge extends StatelessWidget {
  final double size;

  const GoldBadge({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SubscriptionBadge(plan: 'Gold', size: size);
  }
}

class SilverBadge extends StatelessWidget {
  final double size;

  const SilverBadge({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SubscriptionBadge(plan: 'Silver', size: size);
  }
}
