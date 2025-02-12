import 'dart:math';
import '../models/sudoku_cell.dart';

class SudokuResult {
  final List<List<SudokuCell>> puzzle;
  final List<List<int>> solution;

  SudokuResult(this.puzzle, this.solution);
}

class SudokuGenerator {
  final Random _random = Random();

  GeneratorResult generate(int difficulty) {
    List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
    _fillDiagonal(solution);
    _solveSudoku(solution);

    // Create puzzle by removing numbers from solution
    List<List<SudokuCell>> puzzle = List.generate(
      9,
      (i) => List.generate(
        9,
        (j) => SudokuCell(value: null),
      ),
    );

    // Number of cells to keep based on difficulty (0=Easy, 1=Medium, 2=Hard)
    int cellsToKeep;
    switch (difficulty) {
      case 0: // Easy
        cellsToKeep = 50;
        break;
      case 1: // Medium
        cellsToKeep = 35;
        break;
      case 2: // Hard
        cellsToKeep = 25;
        break;
      default:
        cellsToKeep = 35;
    }

    // Remove numbers while ensuring unique solution
    List<Point<int>> allCells = [];
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        allCells.add(Point(i, j));
      }
    }
    allCells.shuffle(_random);

    // Keep only the number of cells we want
    for (int i = 0; i < cellsToKeep; i++) {
      var point = allCells[i];
      puzzle[point.x][point.y] = SudokuCell(
        value: solution[point.x][point.y],
        isInitial: true,
      );
    }

    return GeneratorResult(puzzle: puzzle, solution: solution);
  }

  void _fillDiagonal(List<List<int>> grid) {
    for (int box = 0; box < 9; box += 3) {
      List<int> nums = List.generate(9, (i) => i + 1)..shuffle(_random);
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          grid[box + i][box + j] = nums[i * 3 + j];
        }
      }
    }
  }

  bool _solveSudoku(List<List<int>> grid) {
    int row = -1;
    int col = -1;
    bool isEmpty = false;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] == 0) {
          row = i;
          col = j;
          isEmpty = true;
          break;
        }
      }
      if (isEmpty) break;
    }

    if (!isEmpty) return true;

    List<int> nums = List.generate(9, (i) => i + 1)..shuffle(_random);
    for (int num in nums) {
      if (_isSafe(grid, row, col, num)) {
        grid[row][col] = num;
        if (_solveSudoku(grid)) return true;
        grid[row][col] = 0;
      }
    }
    return false;
  }

  bool _isSafe(List<List<int>> grid, int row, int col, int num) {
    // Check row
    for (int x = 0; x < 9; x++) {
      if (grid[row][x] == num) return false;
    }

    // Check column
    for (int x = 0; x < 9; x++) {
      if (grid[x][col] == num) return false;
    }

    // Check 3x3 box
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i + startRow][j + startCol] == num) return false;
      }
    }

    return true;
  }
}

class GeneratorResult {
  final List<List<SudokuCell>> puzzle;
  final List<List<int>> solution;

  const GeneratorResult({
    required this.puzzle,
    required this.solution,
  });
}
