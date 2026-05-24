import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'cute_cloud_avatar.dart';

class InteractiveAvatar extends StatefulWidget {
  final VoidCallback? onTap;
  final String? initialMessage;
  final bool initiallyVisible;

  const InteractiveAvatar({
    super.key,
    this.onTap,
    this.initialMessage,
    this.initiallyVisible = true,
  });

  @override
  InteractiveAvatarState createState() => InteractiveAvatarState();
}

class InteractiveAvatarState extends State<InteractiveAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isVisible = true;
  String? _currentMessage;
  bool _showSpeechBubble = false;
  
  // Drag functionality
  double _positionX = 0;
  double _positionY = 0;
  double _startX = 0;
  double _startY = 0;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.initiallyVisible;
    _currentMessage = widget.initialMessage;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _showChatDialog();

    _animationController.reset();
    _animationController.forward();

    widget.onTap?.call();
  }

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ChatDialog(
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void setMessage(String message) {
    setState(() {
      _currentMessage = message;
      _showSpeechBubble = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSpeechBubble = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 100 + _positionY,
      right: 20 + _positionX,
      child: GestureDetector(
        onPanStart: (details) {
          _startX = details.globalPosition.dx;
          _startY = details.globalPosition.dy;
        },
        onPanUpdate: (details) {
          setState(() {
            _positionX -= details.globalPosition.dx - _startX;
            _positionY -= details.globalPosition.dy - _startY;
            _startX = details.globalPosition.dx;
            _startY = details.globalPosition.dy;
          });
        },
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_showSpeechBubble && _currentMessage != null)
                    _buildSpeechBubble(),
                  const SizedBox(height: 8),
                  _buildAvatarContainer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _currentMessage!,
        style: AppTypography.body(14),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildAvatarContainer() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.sakura.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CuteCloudAvatar(size: 120),
    );
  }
}

class FloatingAvatarOverlay extends StatefulWidget {
  final Widget child;
  final String? initialMessage;
  final bool initiallyVisible;

  const FloatingAvatarOverlay({
    super.key,
    required this.child,
    this.initialMessage,
    this.initiallyVisible = true,
  });

  @override
  State<FloatingAvatarOverlay> createState() => _FloatingAvatarOverlayState();
}

class _FloatingAvatarOverlayState extends State<FloatingAvatarOverlay> {
  final GlobalKey<InteractiveAvatarState> _avatarKey = GlobalKey();

  void toggleAvatar() {
    _avatarKey.currentState?.toggleVisibility();
  }

  void showAvatarMessage(String message) {
    _avatarKey.currentState?.setMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          InteractiveAvatar(
            key: _avatarKey,
            initialMessage: widget.initialMessage,
            initiallyVisible: widget.initiallyVisible,
          ),
        ],
      ),
    );
  }
}

class _ChatDialog extends StatefulWidget {
  final VoidCallback onClose;

  const _ChatDialog({required this.onClose});

  @override
  State<_ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<_ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello! 👋 I\'m Weatherboo, your weather assistant!',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isUser: true,
      ));
      _messageController.clear();

      // Simulate avatar response
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              text: _getRandomResponse(),
              isUser: false,
            ));
          });
        }
      });
    });
  }

  String _getRandomResponse() {
    final responses = [
      'Thanks for your message! ☁️',
      'The weather is sunny today, stay positive!',
      'How can I help you?',
      'Don\'t forget to bring an umbrella if it rains! ☔',
      'Have a great day!',
      'I\'m here to help you!',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.sakura,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CuteCloudAvatar(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chat with Weatherboo',
                      style: AppTypography.headline(16, color: Colors.white, weight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            // Messages
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _messages[index];
                  },
                ),
              ),
            ),
            // Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.sakura,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.sakura : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text(
          text,
          style: AppTypography.body(14, color: isUser ? Colors.white : AppColors.text),
        ),
      ),
    );
  }
}
