import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_challenges_state.dart';
import 'game_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav_bar.dart';

class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> {
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
                    const SizedBox(height: 20),
                    const Text(
                      'Daily Challenges',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.black, size: 32),
                          onPressed: () => context
                              .read<DailyChallengesState>()
                              .previousMonth(),
                        ),
                        const Icon(
                          Icons.emoji_events,
                          size: 200,
                          color: Colors.amber,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right,
                              color: Colors.black, size: 32),
                          onPressed: () =>
                              context.read<DailyChallengesState>().nextMonth(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer<DailyChallengesState>(
                      builder: (context, state, _) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(state.currentMonth),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                              Text(
                                ' ${state.getCompletedDaysCount()}/${state.getDaysInMonth()}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Consumer<DailyChallengesState>(
                          builder: (context, state, _) {
                            final firstDayOfMonth = DateTime(
                              state.currentMonth.year,
                              state.currentMonth.month,
                              1,
                            );
                            final firstWeekdayOfMonth = firstDayOfMonth.weekday;
                            final adjustedFirstWeekday =
                                (firstWeekdayOfMonth + 6) % 7;

                            // Calculate total number of weeks needed
                            final daysInMonth = state.getDaysInMonth();
                            final totalDays =
                                adjustedFirstWeekday + daysInMonth;
                            final numberOfWeeks = ((totalDays - 1) ~/ 7) + 1;
                            final totalCells = (numberOfWeeks + 1) *
                                7; // +1 for weekday headers

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final availableHeight = constraints.maxHeight -
                                    32; // Account for padding
                                final cellSize = (availableHeight) /
                                    6; // Divide by 6 to allow for 5 rows of days + header

                                return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    mainAxisSpacing: 2,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 1,
                                    mainAxisExtent: cellSize,
                                  ),
                                  itemCount: totalCells,
                                  itemBuilder: (context, index) {
                                    if (index < 7) {
                                      final weekdays = [
                                        'S',
                                        'M',
                                        'T',
                                        'W',
                                        'T',
                                        'F',
                                        'S'
                                      ];
                                      return Center(
                                        child: Text(
                                          weekdays[index],
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }

                                    if (index < 7 + adjustedFirstWeekday) {
                                      return Container(); // Empty space for days before month starts
                                    }

                                    final day =
                                        index - 7 - adjustedFirstWeekday + 1;
                                    if (day > daysInMonth) {
                                      return Container(); // Empty space for days after month ends
                                    }

                                    final date = DateTime(
                                      state.currentMonth.year,
                                      state.currentMonth.month,
                                      day,
                                    );
                                    final isToday = state.isToday(date);
                                    final isPast = state.isPastDay(date);
                                    final isSelected =
                                        state.isSelectedDay(date);

                                    return FutureBuilder<bool>(
                                      future: state.isCompleted(date),
                                      builder: (context, snapshot) {
                                        final isCompleted =
                                            snapshot.data ?? false;

                                        return GestureDetector(
                                          onTap: (!isPast && !isToday)
                                              ? null
                                              : () => state.selectDay(date),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: isCompleted
                                                  ? const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 20,
                                                    )
                                                  : Text(
                                                      '$day',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: (!isPast &&
                                                                !isToday)
                                                            ? Colors.grey[300]
                                                            : isSelected
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87,
                                                        fontWeight: isToday
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Consumer<DailyChallengesState>(
                      builder: (context, state, _) => Container(
                        width: double.infinity,
                        height: 50,
                        margin: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 32,
                        ),
                        child: ElevatedButton(
                          onPressed: state.selectedDay == null
                              ? null
                              : () async {
                                  if (!mounted) return;
                                  final isCompleted = await state
                                      .isCompleted(state.selectedDay!);
                                  if (!mounted) return;
                                  if (isCompleted) return;

                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const GameScreen(
                                          isNewGame: true,
                                          difficulty: 1,
                                          isDailyChallenge: true,
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: state.selectedDay == null
                              ? const Text('Select a Day',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white))
                              : FutureBuilder<bool>(
                                  future: state.isCompleted(state.selectedDay!),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data == true
                                          ? 'Completed'
                                          : 'Play',
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}
