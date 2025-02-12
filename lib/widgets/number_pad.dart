import 'package:flutter/material.dart';
import '../providers/game_state.dart';
import 'package:provider/provider.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
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
          (index) => NumberButton(number: index + 1),
        ),
      ),
    );
  }
}

class NumberButton extends StatelessWidget {
  final int number;

  const NumberButton({
    super.key,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: () {
          context.read<GameState>().makeMove(number);
        },
        child: Text(
          '$number',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
