import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';
import '../providers/user_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cartItems = [];

  String _getUserSubscriptionPlan() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.getSubscriptionPlan();
  }

  bool _isCreator() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    final displayName = profile?['display_name']?.toString().toLowerCase() ?? '';
    final email = userProvider.email?.toString().toLowerCase() ?? '';
    return displayName.contains('ninskie') || email == 'tlive4444@gmail.com';
  }

  bool _canPurchaseItem(String itemTier) {
    final userPlan = _getUserSubscriptionPlan();
    final isCreator = _isCreator();
    
    // Creator can purchase all items
    if (isCreator) return true;
    
    // Subscription hierarchy: platinum > gold > silver > none
    final tierHierarchy = {
      'platinum': 3,
      'gold': 2,
      'silver': 1,
      'none': 0,
    };
    
    final userTierLevel = tierHierarchy[userPlan] ?? 0;
    final itemTierLevel = tierHierarchy[itemTier] ?? 0;
    
    return userTierLevel >= itemTierLevel;
  }

  bool _hasRestrictedItems() {
    for (final item in _cartItems) {
      final itemTier = item['tier'] as String? ?? 'silver';
      if (!_canPurchaseItem(itemTier)) {
        return true;
      }
    }
    return false;
  }

  List<Map<String, dynamic>> _getRestrictedItems() {
    final restricted = <Map<String, dynamic>>[];
    for (final item in _cartItems) {
      final itemTier = item['tier'] as String? ?? 'silver';
      if (!_canPurchaseItem(itemTier)) {
        restricted.add(item);
      }
    }
    return restricted;
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
          title: Text('Shopping Cart', style: AppTypography.headline(20)),
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
                          Icon(Icons.shopping_cart_rounded,
                              size: 64, color: AppColors.sakura),
                          const SizedBox(height: 16),
                          Text(
                            'Your Shopping Cart',
                            style: AppTypography.headline(24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _cartItems.isEmpty
                                ? 'Your cart is empty. Add some weatherboo merchandise!'
                                : 'You have ${_cartItems.length} item${_cartItems.length == 1 ? '' : 's'} in your cart.',
                            style: AppTypography.body(14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_cartItems.isEmpty)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 16),
                            Text(
                              'No items yet',
                              style: AppTypography.headline(18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Browse our merchandise collection to add items to your cart.',
                              style: AppTypography.body(14,
                                  color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._cartItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Column(
                        children: [
                          _buildCartItem(
                            title: item['title'] as String,
                            description: item['description'] as String,
                            price: item['price'] as String,
                            color: item['color'] as Color,
                            quantity: item['quantity'] as int,
                            onQuantityChange: (newQuantity) {
                              setState(() {
                                if (newQuantity > 0) {
                                  _cartItems[index]['quantity'] = newQuantity;
                                } else {
                                  _cartItems.removeAt(index);
                                }
                              });
                            },
                            onRemove: () {
                              setState(() {
                                _cartItems.removeAt(index);
                              });
                            },
                          ),
                          if (index < _cartItems.length - 1)
                            const SizedBox(height: 16),
                        ],
                      );
                    }),
                  if (_cartItems.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal',
                                    style: AppTypography.headline(16)),
                                Text('\$${_calculateTotal()}',
                                    style: AppTypography.headline(16)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Shipping',
                                    style: AppTypography.body(14,
                                        color: AppColors.textMuted)),
                                Text('Free',
                                    style: AppTypography.body(14,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total',
                                    style: AppTypography.headline(18,
                                        weight: FontWeight.bold)),
                                Text('\$${_calculateTotal()}',
                                    style: AppTypography.headline(18,
                                        weight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _hasRestrictedItems()
                                    ? null
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('Checkout coming soon!')),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasRestrictedItems()
                                      ? AppColors.textMuted
                                      : null,
                                ),
                                child: Text(
                                  _hasRestrictedItems()
                                      ? 'Upgrade to Purchase'
                                      : 'Proceed to Checkout',
                                ),
                              ),
                            ),
                            if (_hasRestrictedItems()) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.sakura.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.sakura),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.lock_outline, 
                                            size: 16, 
                                            color: AppColors.sakura),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Subscription Required',
                                          style: AppTypography.headline(14,
                                              color: AppColors.sakura),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Some items in your cart require a higher subscription tier. Please upgrade your plan to purchase these items.',
                                      style: AppTypography.body(12,
                                          color: AppColors.textMuted),
                                    ),
                                    const SizedBox(height: 8),
                                    ..._getRestrictedItems().map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: AppColors.sakura,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${item['title']} (${item['tier']})',
                                              style: AppTypography.body(11,
                                                  color: AppColors.textMuted),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/subscription');
                                        },
                                        icon: const Icon(Icons.upgrade, size: 16),
                                        label: Text(
                                          'Upgrade Subscription',
                                          style: AppTypography.body(12,
                                              color: AppColors.sakura),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required String title,
    required String description,
    required String price,
    required Color color,
    required int quantity,
    required Function(int) onQuantityChange,
    required VoidCallback onRemove,
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
                  child: Icon(Icons.shopping_bag_outlined, size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.headline(16)),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTypography.body(12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text('\$$price', style: AppTypography.headline(16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => onQuantityChange(quantity - 1),
                      iconSize: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.textMuted),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quantity.toString(),
                        style: AppTypography.headline(16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => onQuantityChange(quantity + 1),
                      iconSize: 20,
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(
                    'Remove',
                    style: AppTypography.body(12, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotal() {
    double total = 0;
    for (final item in _cartItems) {
      final price = double.tryParse(item['price'] as String) ?? 0;
      final quantity = item['quantity'] as int;
      total += price * quantity;
    }
    return total.toStringAsFixed(2);
  }
}
