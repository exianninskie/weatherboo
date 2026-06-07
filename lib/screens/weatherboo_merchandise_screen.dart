import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';
import '../utils/routes.dart';

class WeatherbooMerchandiseScreen extends StatelessWidget {
  const WeatherbooMerchandiseScreen({super.key});

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
              Text('Weatherboo Merchandise', style: AppTypography.headline(20)),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.pushNamed(context, Routes.cart);
              },
            ),
          ],
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
                          Icon(Icons.shopping_bag_rounded,
                              size: 64, color: AppColors.sky),
                          const SizedBox(height: 16),
                          Text(
                            'Weatherboo Merchandise',
                            style: AppTypography.headline(24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Explore our curated collection of Weatherboo apparel, accessories, and gifts designed to match your weather mood.',
                            style: AppTypography.body(14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProductCard(
                    title: 'Weathery Tee',
                    description:
                        'Soft pastel tee with weather motif and comfy fit.',
                    price: '29',
                    color: AppColors.sakura,
                  ),
                  const SizedBox(height: 16),
                  _buildProductCard(
                    title: 'Cozy Cloud Hoodie',
                    description:
                        'Perfect for cool, misty mornings and cozy evenings.',
                    price: '39',
                    color: AppColors.lavender,
                  ),
                  const SizedBox(height: 16),
                  _buildProductCard(
                    title: 'Sky Tote',
                    description:
                        'Sunny tote bag for carrying your favorite weather journal.',
                    price: '19',
                    color: AppColors.sky,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String description,
    required String price,
    required Color color,
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      Icon(Icons.shopping_bag_outlined, size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.headline(18)),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style:
                            AppTypography.body(13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price, style: AppTypography.headline(18)),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
