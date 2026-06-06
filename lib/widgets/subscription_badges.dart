import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubscriptionBadge extends StatelessWidget {
  final String plan;
  final double size;

  const SubscriptionBadge({
    super.key,
    required this.plan,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath;

    switch (plan.toLowerCase()) {
      case 'platinum':
        imagePath = 'assets/images/Weatherboo - Badge - Platinum.png';
        break;
      case 'gold':
        imagePath = 'assets/images/Weatherboo - Badge - Gold.png';
        break;
      case 'silver':
        imagePath = 'assets/images/Weatherboo - Badge - Silver.png';
        break;
      default:
        imagePath = 'assets/images/Weatherboo - Badge - Silver.png';
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.5),
      ),
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
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
