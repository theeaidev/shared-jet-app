import 'package:flutter/material.dart';

class SwipeButton extends StatefulWidget {
  final VoidCallback onSwipe;
  final String text;

  const SwipeButton({super.key, required this.onSwipe, required this.text});

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _position = 0.0;
  bool _isFinished = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        if (maxWidth > 320) maxWidth = 320;
        final double maxPosition = maxWidth - 60; // 60 is the button width

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0), // offset for visual balance
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _position,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        if (_isFinished) return;
                        setState(() {
                          _position += details.delta.dx;
                          if (_position < 0) {
                            _position = 0;
                          } else if (_position >= maxPosition) {
                            _position = maxPosition;
                            _isFinished = true;
                            widget.onSwipe();
                          }
                        });
                      },
                      onPanEnd: (details) {
                        if (!_isFinished) {
                          setState(() {
                            _position = 0;
                          });
                        }
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
