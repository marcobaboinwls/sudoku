import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class DifficultyDialog extends StatelessWidget {
  const DifficultyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeOutCubic,
        ).drive(Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        )),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DifficultyButton(
                label: 'Easy',
                difficulty: 0,
                color: Colors.blue,
                onPressed: () {
                  final gameState = context.read<GameState>();
                  gameState.setDifficulty(0);
                  Navigator.of(context).pop(0);
                },
              ),
              const Divider(height: 1),
              _DifficultyButton(
                label: 'Medium',
                difficulty: 1,
                color: Colors.blue,
                onPressed: () {
                  final gameState = context.read<GameState>();
                  gameState.setDifficulty(1);
                  Navigator.of(context).pop(1);
                },
              ),
              const Divider(height: 1),
              _DifficultyButton(
                label: 'Hard',
                difficulty: 2,
                color: Colors.blue,
                onPressed: () {
                  final gameState = context.read<GameState>();
                  gameState.setDifficulty(2);
                  Navigator.of(context).pop(2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final int difficulty;
  final Color color;
  final VoidCallback? onPressed;

  const _DifficultyButton({
    required this.label,
    required this.difficulty,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
