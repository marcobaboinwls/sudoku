import 'package:flutter/material.dart';
import '../providers/game_state.dart';
import 'package:provider/provider.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width to calculate button size
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate button size (leaving some padding)
    final buttonSize =
        (screenWidth - 64) / 9; // 64 accounts for the container padding

    return Container(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 32.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          9,
          (index) => NumberButton(
            number: index + 1,
            size: buttonSize,
          ),
        ),
      ),
    );
  }
}

class NumberButton extends StatelessWidget {
  final int number;
  final double size;

  const NumberButton({
    super.key,
    required this.number,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        onPressed: () {
          context.read<GameState>().makeMove(number);
        },
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            '$number',
            style: TextStyle(
              color: const Color(0xFF1A237E),
              fontSize: size * 0.9,
              height: 1.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
