import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';
import '../utils/routes.dart';
import '../providers/user_provider.dart';
import '../services/supabase_service.dart';

class WeatherbooMerchandiseScreen extends StatefulWidget {
  final String? subscriptionTier;
  
  const WeatherbooMerchandiseScreen({super.key, this.subscriptionTier});

  @override
  State<WeatherbooMerchandiseScreen> createState() => _WeatherbooMerchandiseScreenState();
}

class _WeatherbooMerchandiseScreenState extends State<WeatherbooMerchandiseScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  bool _isCreator(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    final displayName = profile?['display_name']?.toString().toLowerCase() ?? '';
    final email = userProvider.email?.toString().toLowerCase() ?? '';
    return displayName.contains('ninskie') || email == 'tlive4444@gmail.com';
  }

  String _getUserSubscriptionPlan(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    return profile?['subscription_plan']?.toString().toLowerCase() ?? 'none';
  }

  bool _canAddToCart(BuildContext context) {
    final userPlan = _getUserSubscriptionPlan(context);
    final isCreator = _isCreator(context);
    
    // Creator can always add to cart
    if (isCreator) return true;
    
    // Only subscribers can add to cart
    return userPlan != 'none';
  }

  List<Map<String, dynamic>> _getFilteredProducts(BuildContext context) {
    // Initialize default products if empty and not loading
    if (_products.isEmpty && !_isLoading) {
      _products = [
      {
        'title': 'Limited-Run Tote Bag',
        'description': 'Limited-run tote bags with unique designs',
        'price': '25',
        'color': AppColors.sakura,
        'tier': 'platinum',
        'images': <String?>[],
      },
      {
        'title': 'Seasonal Bundle',
        'description': 'Seasonal bundles with limited edition packaging',
        'price': '59',
        'color': AppColors.sakura,
        'tier': 'platinum',
        'images': <String?>[],
      },
      {
        'title': 'Early Access Capsule',
        'description': 'Early access to capsule collections',
        'price': '45',
        'color': AppColors.sakura,
        'tier': 'platinum',
        'images': <String?>[],
      },
      {
        'title': 'Weatherboo Gift Items',
        'description': 'Weatherboo gift items perfect for friends and yourself',
        'price': '35',
        'color': AppColors.sakura,
        'tier': 'platinum',
        'images': <String?>[],
      },
      {
        'title': 'Premium Exclusive Merchandise',
        'description': 'Premium exclusive merchandise',
        'price': '49',
        'color': AppColors.sakura,
        'tier': 'platinum',
        'images': <String?>[],
      },
      {
        'title': 'Special Edition Collectibles',
        'description': 'Special edition collectibles',
        'price': '39',
        'color': AppColors.sakura,
        'tier': 'platinum',
        'images': <String?>[],
      },
      {
        'title': 'Weathery Tee',
        'description': 'Soft pastel tee with weather motif',
        'price': '29',
        'color': AppColors.lavender,
        'tier': 'gold',
        'images': <String?>[],
      },
      {
        'title': 'Cozy Cloud Hoodie',
        'description': 'Cozy hoodies for cool, misty mornings',
        'price': '39',
        'color': AppColors.lavender,
        'tier': 'gold',
        'images': <String?>[],
      },
      {
        'title': 'Weather Beanies',
        'description': 'Cozy beanies for misty weather',
        'price': '22',
        'color': AppColors.lavender,
        'tier': 'gold',
        'images': <String?>[],
      },
      {
        'title': 'Soft Pastel Tees',
        'description': 'Handpicked designs inspired by weather moods',
        'price': '27',
        'color': AppColors.lavender,
        'tier': 'gold',
        'images': <String?>[],
      },
      {
        'title': 'Standard Apparel Items',
        'description': 'Standard apparel items',
        'price': '32',
        'color': AppColors.lavender,
        'tier': 'gold',
        'images': <String?>[],
      },
      {
        'title': 'Sky Tote',
        'description': 'Sunny tote bag for carrying your favorite weather journal',
        'price': '19',
        'color': AppColors.sky,
        'tier': 'silver',
        'images': <String?>[],
      },
      {
        'title': 'Weather-themed Stickers',
        'description': 'Weather-themed stickers for everyday joy',
        'price': '8',
        'color': AppColors.sky,
        'tier': 'silver',
        'images': <String?>[],
      },
      {
        'title': 'Standard Tote Bags',
        'description': 'Standard tote bags with weather motifs',
        'price': '15',
        'color': AppColors.sky,
        'tier': 'silver',
        'images': <String?>[],
      },
      {
        'title': 'Basic Weather Accessories',
        'description': 'Basic weather accessories',
        'price': '12',
        'color': AppColors.sky,
        'tier': 'silver',
        'images': <String?>[],
      },
    ];
    }

    if (widget.subscriptionTier == null) return _products;

    // Filter to show ONLY products matching the specific tier, not hierarchy
    // This applies to both regular users and creator
    return _products.where((product) {
      final productTier = product['tier'] as String;
      return productTier == widget.subscriptionTier?.toLowerCase();
    }).toList();
  }

  Future<void> _uploadImage(int productIndex, int imageIndex) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final productId = _products[productIndex]['title'] as String;
        final imageUrl = await _supabaseService.uploadMerchandiseImage(productId, image);
        
        if (imageUrl != null) {
          setState(() {
            final images = _products[productIndex]['images'] as List<String?>;
            if (images.length < 2) {
              images.add(imageUrl);
            } else if (imageIndex < images.length) {
              images[imageIndex] = imageUrl;
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  Future<void> _deleteImage(int productIndex, int imageIndex) async {
    try {
      final images = _products[productIndex]['images'] as List<String?>;
      final imageUrl = images[imageIndex];
      
      if (imageUrl != null) {
        await _supabaseService.deleteMerchandiseImage(imageUrl);
      }
      
      setState(() {
        images[imageIndex] = null;
        images.removeWhere((img) => img == null);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: $e')),
      );
    }
  }

  void _updatePrice(int productIndex, String newPrice) {
    setState(() {
      _products[productIndex]['price'] = newPrice;
    });
  }

  Future<void> _saveMerchandiseItem(int productIndex) async {
    try {
      final product = Map<String, dynamic>.from(_products[productIndex]);
      
      // Convert Color object to hex string for database
      final color = product['color'] as Color;
      product['color'] = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
      
      await _supabaseService.saveMerchandiseItem(product);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merchandise item saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving merchandise item: $e')),
      );
    }
  }

  Future<void> _loadMerchandiseItems() async {
    try {
      final items = await _supabaseService.getMerchandiseItems();
      if (items.isNotEmpty) {
        setState(() {
          _products = items.map((item) {
            // Convert color string to Color object
            final colorString = item['color'] as String;
            Color color;
            if (colorString.startsWith('#')) {
              color = Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
            } else {
              // Default to AppColors.sky if parsing fails
              color = AppColors.sky;
            }
            item['color'] = color;
            return item;
          }).toList();
        });
      }
    } catch (e) {
      // If database is empty or error occurs, use default products
      print('Error loading merchandise items: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMerchandiseItems();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts(context);
    
    if (_isLoading) {
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
          ),
          body: KawaiiBackground(
            child: ResponsiveCenter(
              padding: const EdgeInsets.fromLTRB(16, 250, 16, 16),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    }
    
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
                            widget.subscriptionTier != null
                                ? 'Browse ${widget.subscriptionTier!.toUpperCase()} tier merchandise collection'
                                : 'Explore our curated collection of Weatherboo apparel, accessories, and gifts designed to match your weather mood.',
                            style: AppTypography.body(14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...filteredProducts.asMap().entries.map((entry) => Column(
                    children: [
                      _buildProductCard(
                        title: entry.value['title'] as String,
                        description: entry.value['description'] as String,
                        price: entry.value['price'] as String,
                        color: entry.value['color'] as Color,
                        images: entry.value['images'] as List<String?>,
                        productIndex: _products.indexOf(entry.value),
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
    required List<String?> images,
    required int productIndex,
  }) {
    final isCreator = _isCreator(context);
    final validImages = images.where((img) => img != null && img.isNotEmpty).toList();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images section
            if (validImages.isNotEmpty || isCreator) ...[
              if (validImages.length == 1)
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          validImages[0]!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              color: AppColors.textMuted.withOpacity(0.1),
                              child: Icon(Icons.broken_image, size: 48, color: AppColors.textMuted),
                            );
                          },
                        ),
                      ),
                    ),
                    if (isCreator)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _deleteImage(productIndex, 0),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              else if (validImages.length >= 2)
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                validImages[0]!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.textMuted.withOpacity(0.1),
                                    child: Icon(Icons.broken_image, size: 48, color: AppColors.textMuted),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (isCreator)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () => _deleteImage(productIndex, 0),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                validImages[1]!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.textMuted.withOpacity(0.1),
                                    child: Icon(Icons.broken_image, size: 48, color: AppColors.textMuted),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (isCreator)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () => _deleteImage(productIndex, 1),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (isCreator)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _uploadImage(productIndex, validImages.length),
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(validImages.isEmpty ? 'Add Image' : 'Add Second Image'),
                        ),
                      ),
                      if (validImages.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _saveMerchandiseItem(productIndex),
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
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
                if (isCreator)
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixText: '\$',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      controller: TextEditingController(text: price),
                      keyboardType: TextInputType.number,
                      onSubmitted: (newPrice) {
                        _updatePrice(productIndex, newPrice);
                      },
                    ),
                  )
                else
                  Text(price, style: AppTypography.headline(18)),
                if (!isCreator && _canAddToCart(context))
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Add to Cart'),
                  ),
                if (!isCreator && !_canAddToCart(context))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Subscribe to Purchase',
                      style: AppTypography.body(12, color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
