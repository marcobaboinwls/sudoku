import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_state.dart';
import 'widgets/sudoku_cell.dart';
import 'widgets/number_pad.dart';
import 'widgets/control_bar.dart';
import 'widgets/difficulty_dialog.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const MainApp(),
    ),
  );
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<GameState>(
            builder: (context, gameState, child) => Column(
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
                if (gameState.hasOngoingGame) const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final difficulty = await Navigator.of(context).push<int>(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
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
                          builder: (_) => ChangeNotifierProvider.value(
                            value: gameState..startNewGame(difficulty),
                            child: const GameScreen(),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BottomNavItem(
                      icon: Icons.home,
                      label: 'Main',
                      isSelected: true,
                    ),
                    _BottomNavItem(
                      icon: Icons.calendar_today,
                      label: 'Daily Challenges',
                    ),
                    _BottomNavItem(
                      icon: Icons.person,
                      label: 'Me',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class GameScreen extends StatelessWidget {
  final bool isNewGame;

  const GameScreen({
    super.key,
    this.isNewGame = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isNewGame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GameState>().startNewGame(1);
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
