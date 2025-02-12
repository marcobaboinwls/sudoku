import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.undo,
            onPressed: gameState.canUndo ? gameState.undo : null,
            label: 'Undo',
          ),
          _ControlButton(
            icon: FontAwesomeIcons.eraser,
            onPressed: () {
              if (gameState.selectedRow != null &&
                  gameState.selectedCol != null) {
                gameState.makeMove(0);
              }
            },
            label: 'Erase',
          ),
          _ControlButton(
            icon: Icons.edit_outlined,
            onPressed: () => gameState.toggleNotesMode(),
            isActive: gameState.isNotesMode,
            label: 'Notes',
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _ControlButton(
                icon: Icons.lightbulb_outline,
                onPressed: gameState.hints > 0 ? gameState.useHint : null,
                isActive: false,
                label: 'Hint',
              ),
              if (gameState.hints > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${gameState.hints}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final String label;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              icon,
              color: isActive ? Colors.blue : Colors.grey[600],
              size: 28,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
