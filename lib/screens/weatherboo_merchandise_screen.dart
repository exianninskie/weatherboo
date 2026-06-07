import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';
import '../utils/routes.dart';
import '../providers/user_provider.dart';

class WeatherbooMerchandiseScreen extends StatelessWidget {
  final String? subscriptionTier;
  
  const WeatherbooMerchandiseScreen({super.key, this.subscriptionTier});

  bool _isCreator(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    final displayName = profile?['display_name']?.toString().toLowerCase() ?? '';
    return displayName.contains('ninskie');
  }

  List<Map<String, dynamic>> _getFilteredProducts(BuildContext context) {
    final isCreator = _isCreator(context);
    
    final allProducts = [
      {
        'title': 'Limited-Run Tote Bag',
        'description': 'Limited-run tote bags with unique designs',
        'price': '25',
        'color': AppColors.sakura,
        'tier': 'platinum',
      },
      {
        'title': 'Seasonal Bundle',
        'description': 'Seasonal bundles with limited edition packaging',
        'price': '59',
        'color': AppColors.sakura,
        'tier': 'platinum',
      },
      {
        'title': 'Early Access Capsule',
        'description': 'Early access to capsule collections',
        'price': '45',
        'color': AppColors.sakura,
        'tier': 'platinum',
      },
      {
        'title': 'Weatherboo Gift Items',
        'description': 'Weatherboo gift items perfect for friends and yourself',
        'price': '35',
        'color': AppColors.sakura,
        'tier': 'platinum',
      },
      {
        'title': 'Premium Exclusive Merchandise',
        'description': 'Premium exclusive merchandise',
        'price': '49',
        'color': AppColors.sakura,
        'tier': 'platinum',
      },
      {
        'title': 'Special Edition Collectibles',
        'description': 'Special edition collectibles',
        'price': '39',
        'color': AppColors.sakura,
        'tier': 'platinum',
      },
      {
        'title': 'Weathery Tee',
        'description': 'Soft pastel tee with weather motif',
        'price': '29',
        'color': AppColors.lavender,
        'tier': 'gold',
      },
      {
        'title': 'Cozy Cloud Hoodie',
        'description': 'Cozy hoodies for cool, misty mornings',
        'price': '39',
        'color': AppColors.lavender,
        'tier': 'gold',
      },
      {
        'title': 'Weather Beanies',
        'description': 'Cozy beanies for misty weather',
        'price': '22',
        'color': AppColors.lavender,
        'tier': 'gold',
      },
      {
        'title': 'Soft Pastel Tees',
        'description': 'Handpicked designs inspired by weather moods',
        'price': '27',
        'color': AppColors.lavender,
        'tier': 'gold',
      },
      {
        'title': 'Standard Apparel Items',
        'description': 'Standard apparel items',
        'price': '32',
        'color': AppColors.lavender,
        'tier': 'gold',
      },
      {
        'title': 'Sky Tote',
        'description': 'Sunny tote bag for carrying your favorite weather journal',
        'price': '19',
        'color': AppColors.sky,
        'tier': 'silver',
      },
      {
        'title': 'Weather-themed Stickers',
        'description': 'Weather-themed stickers for everyday joy',
        'price': '8',
        'color': AppColors.sky,
        'tier': 'silver',
      },
      {
        'title': 'Standard Tote Bags',
        'description': 'Standard tote bags with weather motifs',
        'price': '15',
        'color': AppColors.sky,
        'tier': 'silver',
      },
      {
        'title': 'Basic Weather Accessories',
        'description': 'Basic weather accessories',
        'price': '12',
        'color': AppColors.sky,
        'tier': 'silver',
      },
    ];

    // Creator sees all products
    if (isCreator) return allProducts;
    
    if (subscriptionTier == null) return allProducts;

    final tierHierarchy = {'platinum': 3, 'gold': 2, 'silver': 1};
    final userTier = tierHierarchy[subscriptionTier?.toLowerCase()] ?? 1;

    return allProducts.where((product) {
      final productTier = tierHierarchy[product['tier'] as String] ?? 1;
      return productTier <= userTier;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts(context);
    
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
                            subscriptionTier != null
                                ? 'Browse ${subscriptionTier!.toUpperCase()} tier merchandise collection'
                                : 'Explore our curated collection of Weatherboo apparel, accessories, and gifts designed to match your weather mood.',
                            style: AppTypography.body(14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...filteredProducts.map((product) => Column(
                    children: [
                      _buildProductCard(
                        title: product['title'] as String,
                        description: product['description'] as String,
                        price: product['price'] as String,
                        color: product['color'] as Color,
                      ),
                      const SizedBox(height: 16),
                    ],
                  )),
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
