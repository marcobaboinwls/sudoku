import 'package:flutter/material.dart';
import '../models/sudoku_cell.dart';
import '../utils/sudoku_generator.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/victory_dialog.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class Move {
  final int row;
  final int col;
  final int? oldValue;
  final int newValue;

  Move({
    required this.row,
    required this.col,
    required this.oldValue,
    required this.newValue,
  });
}

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
  final Random _random = Random();
  bool _isGameWon = false;
  bool get isGameWon => _isGameWon;
  SharedPreferences? _prefs;

  GameState() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _highScore = _prefs?.getInt('best_time') ?? 0;
    notifyListeners();
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
    notifyListeners();
  }

  void resetTimer() {
    _seconds = 0;
    notifyListeners();
  }

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

  void startNewGame(int difficulty) {
    final generator = SudokuGenerator();
    final result = generator.generate(difficulty);
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

  void _handleVictory() {
    pauseTimer();
    isNewHighScore = _highScore == 0 || _seconds < _highScore;
    if (isNewHighScore) {
      _highScore = _seconds;
      _prefs?.setInt('best_time', _highScore);
    }
    setGameWon();

    final context = navigatorKey.currentContext;
    if (context != null) {
      Future.microtask(() {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const VictoryDialog(),
          );
        }
      });
    }
  }

  void setGameWon() {
    _isGameWon = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get remainingHints => hints;

  void setDifficulty(int difficulty) {
    notifyListeners();
  }

  void resumeGame() {
    if (hasOngoingGame) {
      startTimer();
      notifyListeners();
    }
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
      _handleVictory();
    }

    notifyListeners();
  }

  void useHint() {
    if (hints <= 0) return;

    // Find a random unfilled cell if no cell is selected or selected cell is filled
    if (selectedRow == null ||
        selectedCol == null ||
        board[selectedRow!][selectedCol!].value != null) {
      final unfilledCells = <Point<int>>[];
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (board[i][j].value == null) {
            unfilledCells.add(Point(i, j));
          }
        }
      }
      if (unfilledCells.isNotEmpty) {
        final randomCell = unfilledCells[_random.nextInt(unfilledCells.length)];
        selectedRow = randomCell.x;
        selectedCol = randomCell.y;
      } else {
        return; // No unfilled cells left
      }
    }

    if (selectedRow != null && selectedCol != null) {
      if (board[selectedRow!][selectedCol!].value == null) {
        board[selectedRow!][selectedCol!] = SudokuCell(
          value: solution[selectedRow!][selectedCol!],
          isInitial: false,
        );
        hints--;
        _checkVictory();
        notifyListeners();
      }
    }
  }

  void undo() {
    if (history.isNotEmpty) {
      final lastState = history.removeLast();
      board = lastState;
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

  void clearGame() {
    hasOngoingGame = false;
    board = [];
    solution = [];
    pauseTimer();
    resetTimer();

    final context = navigatorKey.currentContext;
    if (context != null && _mistakes >= 3) {
      Future.microtask(() {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const GameOverDialog(),
          );
        }
      });
    }
    notifyListeners();
  }

  bool get canUndo => history.isNotEmpty;

  void _checkVictory() {
    if (_isBoardComplete()) {
      _handleVictory();
    }
  }
}
