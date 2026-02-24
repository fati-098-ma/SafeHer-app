import 'package:flutter/material.dart';

class SOSButton extends StatefulWidget {
  final Function onActivate;

  const SOSButton({super.key, required this.onActivate, required int size});

  @override
  _SOSButtonState createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_isPressed) {
      widget.onActivate();
    }
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isPressed ? 140 : 120,
        height: _isPressed ? 140 : 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.red,
              Colors.red[800]!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: _isPressed ? 20 : 10,
              spreadRadius: _isPressed ? 5 : 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: null, // Disable tap, only long press
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emergency, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                const Text('SOS', style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                )),
                if (_isPressed) ...[
                  const SizedBox(height: 4),
                  const Text('Release to send',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w300
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}