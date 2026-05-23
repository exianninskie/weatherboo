import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomLogo extends StatelessWidget {
  final double size;
  final bool showFull;

  const CustomLogo({
    super.key,
    this.size = 200,
    this.showFull = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 0.6,
          height: size * 0.6,
          decoration: AppTheme.logoGradient,
          child: Center(
            child: Icon(
              Icons.cloud_queue_rounded,
              size: size * 0.34,
              color: AppColors.onPrimary,
            ),
          ),
        ),
        if (showFull) ...[
          SizedBox(height: size * 0.1),
          Image.asset(
            'assets/images/Background.png',
            width: size * 0.8,
            height: size * 0.2,
            fit: BoxFit.contain,
          ),
          SizedBox(height: size * 0.04),
          Text(
            'kawaii forecasts, just for you',
            style: AppTypography.brandSubtitle(size * 0.075),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
