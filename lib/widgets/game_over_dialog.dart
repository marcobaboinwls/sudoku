import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Over'),
      content: const Text('You ran out of lives!'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('Return to Home'),
        ),
      ],
    );
  }
}
