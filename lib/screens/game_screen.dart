import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/sudoku_cell.dart';
import '../widgets/control_bar.dart';
import '../widgets/number_pad.dart';
import '../providers/daily_challenges_state.dart';

class GameScreen extends StatefulWidget {
  final bool isNewGame;
  final int difficulty;
  final bool isDailyChallenge;

  const GameScreen({
    super.key,
    this.isNewGame = true,
    this.difficulty = 1,
    this.isDailyChallenge = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.isNewGame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GameState>().startNewGame(widget.difficulty);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GameState>().resumeGame();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<GameState>().pauseTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final gameState = context.read<GameState>();
    if (state == AppLifecycleState.paused) {
      gameState.pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      gameState.resumeGame();
    }
  }

  void _onGameWon() async {
    if (widget.isDailyChallenge) {
      final dailyChallengesState = context.read<DailyChallengesState>();
      await dailyChallengesState
          .markChallengeAsCompleted(dailyChallengesState.selectedDay!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add this listener
    context.watch<GameState>().addListener(() {
      if (context.read<GameState>().isGameWon) {
        _onGameWon();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Consumer<GameState>(
          builder: (context, gameState, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => Icon(
                Icons.favorite,
                color: index < gameState.remainingLives
                    ? Colors.red
                    : Colors.grey[400],
                size: 24,
              ),
            ),
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Consumer<GameState>(
                builder: (context, gameState, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      gameState.timerText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          top: 8.0,
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                child: Consumer<GameState>(
                  builder: (context, gameState, _) => GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                      childAspectRatio: 1,
                    ),
                    itemCount: 81,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      int row = index ~/ 9;
                      int col = index % 9;
                      return SudokuCell(row: row, col: col);
                    },
                  ),
                ),
              ),
            ),
            const Spacer(),
            const ControlBar(),
            const Spacer(),
            const NumberPad(),
          ],
        ),
      ),
    );
  }
}
