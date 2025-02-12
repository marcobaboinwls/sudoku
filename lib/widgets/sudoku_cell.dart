import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import 'animated_number.dart';

class SudokuCell extends StatelessWidget {
  final int row;
  final int col;

  const SudokuCell({
    super.key,
    required this.row,
    required this.col,
  });

  bool _isInSameHouse(
      int selectedRow, int selectedCol, int currentRow, int currentCol) {
    if ((currentRow ~/ 3 == selectedRow ~/ 3) &&
        (currentCol ~/ 3 == selectedCol ~/ 3)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        if (gameState.board.isEmpty) return const SizedBox();

        final cell = gameState.board[row][col];
        final isSelected =
            gameState.selectedRow == row && gameState.selectedCol == col;
        final isHighlighted = gameState.selectedRow != null &&
            gameState.selectedCol != null &&
            (row == gameState.selectedRow! ||
                col == gameState.selectedCol! ||
                _isInSameHouse(
                    gameState.selectedRow!, gameState.selectedCol!, row, col));
        final isError = cell.value != null &&
            !cell.isInitial &&
            cell.value != gameState.solution[row][col];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => gameState.selectCell(row, col),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: (col + 1) % 3 == 0 || col == 8 ? 1.0 : 0.5,
                  color: (col + 1) % 3 == 0 || col == 8
                      ? Colors.black
                      : Colors.grey[400]!,
                ),
                bottom: BorderSide(
                  width: (row + 1) % 3 == 0 || row == 8 ? 1.0 : 0.5,
                  color: (row + 1) % 3 == 0 || row == 8
                      ? Colors.black
                      : Colors.grey[400]!,
                ),
                left: BorderSide(
                  width: col % 3 == 0 || col == 0 ? 1.0 : 0.5,
                  color: col % 3 == 0 || col == 0
                      ? Colors.black
                      : Colors.grey[400]!,
                ),
                top: BorderSide(
                  width: row % 3 == 0 || row == 0 ? 1.0 : 0.5,
                  color: row % 3 == 0 || row == 0
                      ? Colors.black
                      : Colors.grey[400]!,
                ),
              ),
              color: isSelected
                  ? Colors.blue.withAlpha(76)
                  : isHighlighted
                      ? Colors.blue.withAlpha(25)
                      : Colors.white,
            ),
            child: cell.value != null
                ? Center(
                    child: AnimatedNumber(
                      number: cell.value!,
                      row: row,
                      col: col,
                      isError: isError,
                      isInitial: cell.isInitial,
                    ),
                  )
                : cell.annotations.isNotEmpty
                    ? GridView.count(
                        crossAxisCount: 3,
                        padding: const EdgeInsets.all(2),
                        children: List.generate(9, (index) {
                          final number = index + 1;
                          return Center(
                            child: cell.annotations.contains(number)
                                ? Text(
                                    '$number',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                    ),
                                  )
                                : null,
                          );
                        }),
                      )
                    : null,
          ),
        );
      },
    );
  }
}
