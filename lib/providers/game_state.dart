import 'package:flutter/material.dart';
import '../models/sudoku_cell.dart';
import '../utils/sudoku_generator.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/victory_dialog.dart';
import 'dart:async';

class GameState extends ChangeNotifier {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static const initialHints = 90;
  List<List<SudokuCell>> board = [];
  List<List<int>> solution = [];
  int lives = 3;
  bool isNotesMode = false;
  List<List<List<SudokuCell>>> history = [];
  int? selectedRow;
  int? selectedCol;
  int hints = initialHints;
  bool hasOngoingGame = false;
  Timer? _timer;
  int _seconds = 0;
  int _mistakes = 0;
  int get mistakes => _mistakes;
  int get remainingLives => 3 - _mistakes;
  int _highScore = 0;
  bool isNewHighScore = false;
  int _currentDifficulty = 0;

  String get timerText {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String get bestTimeText {
    if (_highScore == 0) return '';
    int minutes = _highScore ~/ 60;
    int remainingSeconds = _highScore % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      notifyListeners();
    });
  }

  void pauseTimer() {
    _timer?.cancel();
  }

  void resetTimer() {
    _seconds = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setDifficulty(int difficulty) {
    _currentDifficulty = difficulty;
    notifyListeners();
  }

  void startNewGame(int difficulty) {
    final generator = SudokuGenerator();
    final result = generator.generate(_currentDifficulty);
    board = result.puzzle;
    solution = result.solution;
    _mistakes = 0;
    lives = 3;
    hints = initialHints;
    isNotesMode = false;
    history = [];
    hasOngoingGame = true;
    selectedRow = null;
    selectedCol = null;
    resetTimer();
    startTimer();
    notifyListeners();
  }

  bool _isBoardComplete() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j].value != solution[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  void _cleanupNotes(int row, int col, int number) {
    // Clean same row
    for (int c = 0; c < 9; c++) {
      if (c != col) {
        var annotations = List<int>.from(board[row][c].annotations);
        annotations.remove(number);
        board[row][c] = board[row][c].copyWith(annotations: annotations);
      }
    }

    // Clean same column
    for (int r = 0; r < 9; r++) {
      if (r != row) {
        var annotations = List<int>.from(board[r][col].annotations);
        annotations.remove(number);
        board[r][col] = board[r][col].copyWith(annotations: annotations);
      }
    }

    // Clean same 3x3 box
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (r != row || c != col) {
          var annotations = List<int>.from(board[r][c].annotations);
          annotations.remove(number);
          board[r][c] = board[r][c].copyWith(annotations: annotations);
        }
      }
    }
  }

  void makeMove(int number) {
    if (selectedRow == null || selectedCol == null) return;
    if (board[selectedRow!][selectedCol!].isInitial) return;

    // Only check for mistakes when not in notes mode
    if (!isNotesMode &&
        number != 0 &&
        number != solution[selectedRow!][selectedCol!]) {
      _mistakes++;
      notifyListeners();
      if (_mistakes >= 3) {
        clearGame();
        Future.microtask(() => showDialog(
              context: navigatorKey.currentContext!,
              barrierDismissible: false,
              builder: (_) => const GameOverDialog(),
            ));
        return;
      }
    }

    // Save current state for undo
    history.add(List.generate(
        9, (i) => List.generate(9, (j) => board[i][j].copyWith())));

    if (number == 0) {
      board[selectedRow!][selectedCol!] = board[selectedRow!][selectedCol!]
          .copyWith(value: null, annotations: []);
      notifyListeners();
      return;
    }

    if (isNotesMode) {
      var annotations =
          List<int>.from(board[selectedRow!][selectedCol!].annotations);
      if (annotations.contains(number)) {
        annotations.remove(number);
      } else {
        annotations.add(number);
      }
      board[selectedRow!][selectedCol!] =
          board[selectedRow!][selectedCol!].copyWith(annotations: annotations);
    } else {
      board[selectedRow!][selectedCol!] =
          board[selectedRow!][selectedCol!].copyWith(value: number);

      // Only clean up notes if the move is correct
      if (number == solution[selectedRow!][selectedCol!]) {
        _cleanupNotes(selectedRow!, selectedCol!, number);
      }
    }

    if (_isBoardComplete()) {
      pauseTimer();
      isNewHighScore = _highScore == 0 || _seconds < _highScore;
      if (isNewHighScore) {
        _highScore = _seconds;
      }
      Future.microtask(() => showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: false,
            builder: (_) => const VictoryDialog(),
          ));
    }

    notifyListeners();
  }

  void undo() {
    if (history.isNotEmpty) {
      board = history.removeLast();
      notifyListeners();
    }
  }

  void toggleNotesMode() {
    isNotesMode = !isNotesMode;
    notifyListeners();
  }

  void selectCell(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void clearCell(int row, int col) {
    if (!board[row][col].isInitial) {
      board[row][col] = board[row][col].copyWith(value: null);
      notifyListeners();
    }
  }

  void useHint() {
    if (selectedRow == null || selectedCol == null || hints <= 0) return;

    final correctValue = solution[selectedRow!][selectedCol!];
    // Check if cell is already correct
    if (board[selectedRow!][selectedCol!].value == correctValue) return;

    board[selectedRow!][selectedCol!] = SudokuCell(
      value: correctValue,
      isInitial: true,
    );
    hints--;

    // Clean up notes after using hint
    _cleanupNotes(selectedRow!, selectedCol!, correctValue);

    if (_isBoardComplete()) {
      pauseTimer();
      isNewHighScore = _highScore == 0 || _seconds < _highScore;
      if (isNewHighScore) {
        _highScore = _seconds;
      }
      Future.microtask(() => showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: false,
            builder: (_) => const VictoryDialog(),
          ));
    }

    notifyListeners();
  }

  void clearGame() {
    hasOngoingGame = false;
    board = [];
    pauseTimer();
    resetTimer();
    notifyListeners();
  }

  bool get canUndo => history.isNotEmpty;
}
