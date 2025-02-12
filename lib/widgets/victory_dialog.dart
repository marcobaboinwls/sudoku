import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class VictoryDialog extends StatelessWidget {
  const VictoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You completed the puzzle!'),
            const SizedBox(height: 8),
            Text('Time: ${gameState.timerText}'),
            if (gameState.isNewHighScore)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'New High Score!',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameState.clearGame();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
