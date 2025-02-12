import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class AnimatedNumber extends StatefulWidget {
  final int number;
  final bool isError;
  final bool isInitial;
  final int row;
  final int col;

  const AnimatedNumber({
    super.key,
    required this.number,
    required this.row,
    required this.col,
    this.isError = false,
    this.isInitial = false,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  int? lastNumber;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.red.withAlpha(0),
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isAnimating = false;
        if (mounted) {
          context.read<GameState>().clearCell(widget.row, widget.col);
        }
      }
    });

    lastNumber = widget.number;
    if (widget.isError && !isAnimating) {
      _playErrorAnimation();
    }
  }

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError && !isAnimating && widget.number != lastNumber) {
      lastNumber = widget.number;
      _playErrorAnimation();
    }
  }

  void _playErrorAnimation() {
    isAnimating = true;
    _controller.reset();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Text(
          '${widget.number}',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w500,
            color: widget.isError
                ? _colorAnimation.value
                : const Color.fromARGB(215, 0, 0, 0),
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
