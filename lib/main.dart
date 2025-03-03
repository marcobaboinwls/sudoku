import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_state.dart';
import 'providers/daily_challenges_state.dart';
import 'widgets/sudoku_cell.dart';
import 'widgets/number_pad.dart';
import 'widgets/control_bar.dart';
import 'widgets/difficulty_dialog.dart';
import 'package:flutter/services.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameState()),
          ChangeNotifierProvider(create: (_) => DailyChallengesState()),
        ],
        child: const MainApp(),
      ),
    );
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: GameState.navigatorKey,
      home: const HomeScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(),
                    const Text(
                      'Wild Sudoku',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2B4C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Best Time',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Colors.amber, size: 32),
                        const SizedBox(width: 8),
                        Consumer<GameState>(
                          builder: (context, gameState, _) => Text(
                            gameState.bestTimeText,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Consumer<GameState>(
                      builder: (context, gameState, _) => Column(
                        children: [
                          if (gameState.hasOngoingGame)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const GameScreen(isNewGame: false)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: const Text(
                                'Continue Game',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (gameState.hasOngoingGame)
                            const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final difficulty =
                            await Navigator.of(context).push<int>(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const DifficultyDialog(),
                            transitionDuration: const Duration(
                                milliseconds: 300), // Reduced from 500ms
                            reverseTransitionDuration: const Duration(
                                milliseconds: 300), // Same for closing
                            opaque: false,
                            barrierDismissible: true,
                            barrierColor: Colors.black54,
                          ),
                        );

                        if (difficulty != null) {
                          if (!context.mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                isNewGame: true,
                                difficulty: difficulty,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: const Text(
                        'New Game',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final bool isNewGame;
  final int difficulty;

  const GameScreen({
    super.key,
    this.isNewGame = true,
    this.difficulty = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (isNewGame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GameState>().startNewGame(difficulty);
      });
    }

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
                    )),
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
